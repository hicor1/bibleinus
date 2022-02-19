import 'package:bible_in_us/bible/bible_controller.dart';
import 'package:bible_in_us/diary/diary_controller.dart';
import 'package:bible_in_us/diary/diary_write_srceen.dart';
import 'package:bible_in_us/general/general_controller.dart';
import 'package:bible_in_us/my/my_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:expandable/expandable.dart';


final MyCtr = Get.put(MyController());
final DiaryCtr = Get.put(DiaryController());
final GeneralCtr = Get.put(GeneralController());
final BibleCtr = Get.put(BibleController());

class DiaryViewPage extends StatelessWidget {
  const DiaryViewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainWidget();
  }
}

/* <서브위젯> 메인 위젯 정의 */
class MainWidget extends StatelessWidget {
  const MainWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    /* 메인 위젯 시작 */
    return GetBuilder<DiaryController>(
      /* GexX 객체 불러오기 */
        init: DiaryController(),
        builder: (_){
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  /*  작성한 일기기 하나도 없는 경우 */
                  if (DiaryCtr.diary_view_contents.length == 0)
                    TextButton(
                      child: Text("새로운 일기를 작성해보세요 !",
                        style: TextStyle(
                        decoration: TextDecoration.underline,
                        ),
                      ),
                      onPressed: (){
                        Get.to(() => DiaryWriteScreen());
                      },
                    )
                  else
                  /*  작성한 일기기 있는 경우 */
                  ListView.builder(
                      physics: const NeverScrollableScrollPhysics(), // 빌더 내부에서 별도로 스크롤 관리할지, 이게 활성화 된경우 전체 스크롤보다 해당 스크롤이 우선되므로 일단은 비활성화가 좋다
                      shrinkWrap: true, //"hassize" 같은 ㅈ같은 오류 방지
                      scrollDirection: Axis.vertical, // 수직(vertical)  수평(horizontal) 배열 선택
                      //controller: ,// 스크롤 조작이 필요하다면 할당 ㄱㄱ
                      itemCount: DiaryCtr.diary_view_contents.length,
                      itemBuilder: (context, index) {
                        var result = DiaryCtr.diary_view_contents[index]; // 결과 할당, 이런식으로 변수 선언 가능, 아래 위젯에서 활용 가능
                        /* 아래부터 컨테이너 반복 */
                        return Container(
                          padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /* 컨테이너 상단 식별 정보 */
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      /* 프로필 사진 */
                                      Container(
                                          margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                          width: 40.0,
                                          height: 40.0,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                  fit: BoxFit.fill,
                                                  image: NetworkImage("${MyCtr.photoURL}")
                                              )
                                          )
                                      ),
                                      /* 사회적 거리두기 */
                                      SizedBox(width: 15),
                                      /* 이름, 장소 */
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("${MyCtr.displayName}"),
                                          Text("${result['dirary_screen_address']}", style: TextStyle(color: Colors.grey)),
                                        ],
                                      )
                                    ],
                                  ),
                                  /* 옵션 버튼 */
                                  Row(
                                    children: [
                                      /* 경과시간 표기 */
                                      Text("${DiaryCtr.diary_view_timediffer[index]}", style: TextStyle(fontSize: 13, color: Colors.grey),),
                                      PopupMenuButton(
                                          icon: Icon(Icons.more_vert_sharp, size: GeneralCtr.Textsize*1.2, color: Colors.black54), // pop메뉴 아이콘
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(5)),
                                          padding: EdgeInsets.zero,
                                          tooltip: "추가기능",
                                          color: Colors.white, // pop메뉴 배경색
                                          elevation: 10,// pop메뉴 그림자
                                          onSelected: (value) {

                                          },

                                          /* 옵션 버튼 _ 하위 메뉴 스타일 */
                                          itemBuilder: (context) => [
                                            /*삭제*/
                                            PopupMenuItem(child: Row(children: [Icon(FontAwesome5.eraser, size: 20), Text(" 수정", style: TextStyle(fontSize: GeneralCtr.Textsize*0.9))]), value: "수정"),
                                            /*수정*/
                                            PopupMenuItem(child: Row(children: [Icon(FontAwesome.trash_empty, size: 20), Text(" 삭제", style: TextStyle(fontSize: GeneralCtr.Textsize*0.9))]), value: "삭제"),
                                          ]
                                      ),
                                    ],
                                  )
                                ],
                              ),

                              /* 사회적 거리두기 */
                              SizedBox(height: 15),
                              /* 제목 + 내용 */
                              ExpandablePanel(
                                theme: const ExpandableThemeData(
                                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                                ),
                                // 1. 제목
                                header: Text("[${result['dirary_screen_title']}]", style: TextStyle(fontWeight: FontWeight.bold)),
                                // 2. 내용 접었을 때
                                collapsed: Text("${result['dirary_screen_contents']}",
                                    maxLines:3, overflow: TextOverflow.ellipsis, softWrap: true,// 공간을 넘는 글자는 쩜쩜쩜(...)으로 표기한다.
                                    style: TextStyle(fontSize:15)
                                ),
                                // 3. 내용 펼쳤을 때
                                expanded:  SelectableText("${result['dirary_screen_contents']}",  style: TextStyle(fontSize:15)),
                              ),

                              /* 사회적 거리두기 */
                              SizedBox(height: 10),


                              ViewVerses(index: index),




                              /* 사회적 거리두기 */
                              SizedBox(height: 10),
                              /* 사진보여주기 */
                              if (result['choiced_image_file'].length>0)
                                GFCarousel(
                                //height: 330, // 고정사이즈 적용, 아래 페이저가 보이도록
                                pagination: true,
                                enableInfiniteScroll: false,
                                activeIndicator: GeneralCtr.MainColor,
                                passiveIndicator: Colors.grey.withOpacity(0.5),
                                pagerSize: 7.0,// 이미지 하단 페이지 인디케이터 크기
                                viewportFraction: 1.0, // 전.후 이미지 보여주기 ( 1.0이면 안보여줌 )
                                items: result['choiced_image_file'].map<Widget>(
                                      (url) {
                                    return Container(
                                      //padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                                      width: MediaQuery.of(context).size.width,
                                      margin: EdgeInsets.zero,
                                      child: ClipRRect(
                                        //borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                        child: Image.network(
                                          url,
                                          fit: BoxFit.fitWidth, // 높이제한이 있으므로 이미지가 뭉게지지 않기위해서는 높이에 맞춘다
                                        ),
                                      ),
                                    );
                                  },
                                ).toList(),
                                onPageChanged: (index) {
                                },
                              ),
                              SizedBox(height: 10),
                              /* 타임태그 */
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.fromLTRB(7, 3, 7, 1),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(color: Colors.grey, spreadRadius: 1),
                                      ],
                                    ),
                                    child:Text("# ${DiaryCtr.TimeTag[result['dirary_screen_timetag_index']]}"),
                                  )
                                ],
                              ),
                              /* 사회적 거리두기 */
                              SizedBox(height: 10),
                              Divider(thickness: 1)
                            ],
                          ),
                        ); // "=>"이 아닌 "{}"을 쓸때는 반드시 return을 써줘야한다!!
                      }
                  )
                ],
              )
            ),
          );
        }
    );
  }
}




//<서브위젯> 성경 카드 뿌려주기
/* 아래부터 선택한 성경 카드로 보여주기 *///https://docs.getwidget.dev/gf-carousel/
class ViewVerses extends StatelessWidget {
  const ViewVerses({Key? key, this.index}) : super(key: key);

  /* 일기 인덱스 받아오기 */
  final index;

  @override
  Widget build(BuildContext context) {
    return GFCarousel(
      height: 180,
      activeIndicator: GeneralCtr.MainColor,
      passiveIndicator: Colors.white,
      pagerSize: 7.0,// 이미지 하단 페이지 인디케이터 크기
      enableInfiniteScroll: true, // 무한스크롤
      viewportFraction: 0.8, // 전.후 이미지 보여주기 ( 1.0이면 안보여줌 )
      aspectRatio: 20, // 사진 비율
      enlargeMainPage: true, // 자동 확대
      pagination: true, // 이미지 하단 페이지 인디케이터 표시여부
      autoPlayInterval: Duration(milliseconds: 5000), // 자동 넘기기 주기(시간)
      autoPlay: true, // 자동 넘기기 on/off
      pauseAutoPlayOnTouch: Duration(milliseconds: 5000), // 클릭하면 자동넘기기 일시 정지

      /* 선택된 구절 갯수만큼 카드 만들어주기 */
      items: DiaryCtr.diary_view_contents[index]['dirary_screen_selected_verses_id'].map<Widget>(
            (id) {

          /* 필터링으로 구절정보 하나씩 가져오기 */
          var contents_data = DiaryCtr.diary_view_selected_contents_data.where((f)=>f["_id"]==id).toList();
          var diary_data = DiaryCtr.diary_view_contents[index];



          /* 성경 구절 카드에 담아서 보여주기 */
          /* 1. 정보가 "null"이 아니면, 구절 정보 담아서 보여준다 */
          return Container(
            decoration: BoxDecoration(
              color: DiaryCtr.ColorCode[diary_data['dirary_screen_color_index']].withOpacity(0.4), // 카드 색깔
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.fromLTRB(5, 0, 5, 0), // 좌우 카드끼리 간격 띄우기
            child: SingleChildScrollView(
                child: Column(
                  children: [
                    /* 사회적 거리두기 */
                    SizedBox(height: 20),
                    /* 구절정보 보여주기 */
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        /* 구절 정보 */
                        Text(" $index [${contents_data[0]['국문']}(${contents_data[0]['영문']}) ${contents_data[0]['cnum']}장 ${contents_data[0]['vnum']}절]"),
                      ],
                    ),

                    /* 성경 구절 메인 보여주기 */
                    ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      /* 성경 구절 담기 */
                      child: GFCard(
                        padding: EdgeInsets.fromLTRB(5, 5, 5, 5), // 하얀카드 안쪽 텍스트 패딩
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 25), // 컨테이너 자체 마진
                        boxFit: BoxFit.fitHeight,
                        /* 구절 내영 */
                        content: SelectableText('${contents_data[0][BibleCtr.Bible_choiced]}',style:TextStyle(height: 1.5)),
                      ),
                    ),
                  ],
                )
            ),
          );
        },
      ).toList(),
      onPageChanged: (index) {
        /* 카드 넘어갈때 이벤트 */
      },
    );
  }
}



