import 'dart:ui';

import 'package:bible_in_us/bible/bible_controller.dart';
import 'package:bible_in_us/diary/diary_component.dart';
import 'package:bible_in_us/diary/diary_controller.dart';
import 'package:bible_in_us/diary/diary_view_detail_screen.dart';
import 'package:bible_in_us/diary/diary_write_srceen.dart';
import 'package:bible_in_us/general/general_controller.dart';
import 'package:bible_in_us/my/my_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/modern_pictograms_icons.dart';
import 'package:fluttericon/typicons_icons.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:expandable/expandable.dart';
import 'package:hashtager/hashtager.dart';
import 'package:word_break_text/word_break_text.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';


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
              padding: EdgeInsets.fromLTRB(10, 2, 10, 0),
              child: Column(
                children: [
                  SizedBox(height: 5),
                  /* 검색창 + 그리드뷰 or 리스트뷰 선택 위젯 배치 */
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /* 검색창 */
                      SearchWidget(),
                      /* 그리드뷰 or 리스트뷰 선택 위젯 배치 */
                      ViewMode_select(),
                    ],
                  ),
                  /*  작성한 일기기 하나도 없는 경우 */
                  if (DiaryCtr.diary_view_contents_filtered.length == 0)
                    TextButton(
                      child: Text("새로운 일기를 작성해보세요 !",
                        style: TextStyle(
                        decoration: TextDecoration.underline,
                        ),
                      ),
                      onPressed: (){
                        DiaryCtr.select_NewOrModify("new"); // 신규 작성모드로 변경
                        Get.to(() => DiaryWriteScreen());
                      },
                    )
                  /*  ↓작성한 일기가 있는 경우↓ */
                  else

                  /* 사회적 거리두기 */
                  SizedBox(height: 10),
                  /* 뷰 선택에 따라 보여줄 뷰 변경(그리드뷰 or 리스트뷰) */
                  DiaryCtr.diary_view_ViewMode == "list" ? DiaryListView() : DiaryGridView()
                ],
              )
            ),
          );
        }
    );
  }
}
//<서브위젯> 그리드뷰 or 리스트뷰 선택 위젯 */
Widget ViewMode_select() {
  return
    Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        /* 그리드뷰 */
        IconButton(
          onPressed: (){
            /* 뷰 모드 체인지 이벤트 */
            DiaryCtr.ViewMode_change("grid");
          },
          icon: Icon(
              Typicons.th_large_outline,
              size: 20,
              color: DiaryCtr.diary_view_ViewMode == "grid" ? GeneralCtr.MainColor : Colors.grey
          ),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
        ),
        /* 사회적 거리두기 */
        SizedBox(width: 20),
        /* 리스트뷰 */
        IconButton(
          onPressed: (){
            /* 뷰 모드 체인지 이벤트 */
            DiaryCtr.ViewMode_change("list");
          },
          icon: Icon(
              Typicons.th_list_outline,
              size: 20,
              color: DiaryCtr.diary_view_ViewMode == "list" ? GeneralCtr.MainColor : Colors.grey
          ),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
        ),
        /* 사회적 거리두기 */
        SizedBox(width: 10)
      ],
    );
}


//<서브위젯> 일기 리스트 그리드 뷰(grid view)로 보여주기
Widget DiaryGridView() {
  return
    Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      /* 애니메이션 빌더로 감싸준다 (https://pub.dev/packages/flutter_staggered_animations)*/
      child: AnimationLimiter(
        child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, //1 개의 행에 보여줄 item 개수
              childAspectRatio: 0.9 / 1, //item 의 가로 1, 세로 2 의 비율
              mainAxisSpacing: 8, //수평 Padding
              crossAxisSpacing: 8, //수직 Padding
            ),
            physics: const NeverScrollableScrollPhysics(), // 빌더 내부에서 별도로 스크롤 관리할지, 이게 활성화 된경우 전체 스크롤보다 해당 스크롤이 우선되므로 일단은 비활성화가 좋다
            shrinkWrap: true, //"hassize" 같은 ㅈ같은 오류 방지
            scrollDirection: Axis.vertical, // 수직(vertical)  수평(horizontal) 배열 선택
            //controller: ,// 스크롤 조작이 필요하다면 할당 ㄱㄱ
            itemCount: DiaryCtr.diary_view_contents_filtered.length,
            itemBuilder: (context, index) {
              var result = DiaryCtr.diary_view_contents_filtered[index];
              /* 날짜 데이터를 보기좋게 재구성 */
              var date_temp = result['dirary_screen_selectedDate'].toDate();
              var date_format = "${date_temp.year}.${date_temp.month}.${date_temp.day}"; //date로 형식 변환
              var week_day = DiaryCtr.ConvertWeekday(date_temp.weekday);

              /* 아래부터 컨테이너 반복 */
              return AnimationConfiguration.staggeredGrid(
                position: index,
                duration: const Duration(milliseconds: 375),
                columnCount: index,
                child: SlideAnimation(
                  child: FadeInAnimation(
                    child: InkWell(
                      onTap: (){
                        /* 일기 컨테이너 클릭 시, 상세페이지로 이동 */
                        Get.to(() => DiaryViewDetailScreen(index: index));
                      },
                      child: Material(
                        color: DiaryCtr.ColorCode[result['dirary_screen_color_index']].withOpacity(0.3),
                        elevation: 0.0,
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              /* 이미지 + 경과시간 + 제목 + 내용 */
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /* 이미지 + 경과시간 */
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                          "${DiaryCtr.diary_view_timediffer[index]}",
                                          style: TextStyle(fontSize: GeneralCtr.fontsize_normal*0.8, color: Colors.grey)
                                      ),
                                      Image.asset(
                                        "assets/img/icons/emoticon/${DiaryCtr.EmoticonName[result['dirary_screen_emoticon_index']]}.png",
                                        height: GeneralCtr.fontsize_normal*0.8,
                                        width: GeneralCtr.fontsize_normal*0.8,
                                      ),
                                      SizedBox(width: 5),
                                    ],
                                  ),
                                  /* 제목 */
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        child: Text(
                                            "${result['dirary_screen_title']}",
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              //color: DiaryCtr.ColorCode[result['dirary_screen_color_index']],
                                                color: Colors.black,
                                                fontSize: GeneralCtr.fontsize_normal*1.1,
                                                fontWeight: FontWeight.bold)
                                        ),
                                      ),
                                    ],
                                  ),
                                  /* 38도선 */
                                  Divider(height: 10),
                                  /* 내용 */
                                  Text(
                                    "${result['dirary_screen_contents']}",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 5,
                                    softWrap: true,
                                    style: TextStyle(fontSize: GeneralCtr.fontsize_normal),
                                  ),
                                ],
                              ),
                              /* 날짜 + 시간 + 장소 + 날씨*/
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                      "$date_format($week_day) ${DiaryCtr.TimeTag[result['dirary_screen_timetag_index']]}",
                                      style: TextStyle(fontSize: GeneralCtr.fontsize_normal*0.7, color: Colors.black87)
                                  ),
                                  Image.asset(
                                    "assets/img/icons/weather/${DiaryCtr.WeatherName[result['dirary_screen_weather_index']]}.png",
                                    height: GeneralCtr.fontsize_normal*0.7,
                                    width: GeneralCtr.fontsize_normal*0.7,
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
        ),
      ),
    );
}


//<서브위젯> 일기 리스트 view로 보여주기
Widget DiaryListView(){
  return
  /* 애니메이션 빌더로 감싸준다 (https://pub.dev/packages/flutter_staggered_animations)*/
    AnimationLimiter(
      child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(), // 빌더 내부에서 별도로 스크롤 관리할지, 이게 활성화 된경우 전체 스크롤보다 해당 스크롤이 우선되므로 일단은 비활성화가 좋다
          shrinkWrap: true, //"hassize" 같은 ㅈ같은 오류 방지
          scrollDirection: Axis.vertical, // 수직(vertical)  수평(horizontal) 배열 선택
          //controller: ,// 스크롤 조작이 필요하다면 할당 ㄱㄱ
          itemCount: DiaryCtr.diary_view_contents_filtered.length,
          itemBuilder: (context, index) {
            var result = DiaryCtr.diary_view_contents_filtered[index]; // 결과 할당, 이런식으로 변수 선언 가능, 아래 위젯에서 활용 가능
            /* 아래부터 컨테이너 반복 */
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 200),
              child: SlideAnimation(
                verticalOffset: 100.0,
                child: FadeInAnimation(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /* 컨테이너 상단 식별 정보 */
                        ContentsHeader(context, result, index),

                        /* 해시태그 삽입 */
                        HashTagView(result),

                        /* 사회적 거리두기 */
                        SizedBox(height: 10),

                        /* 제목 + 내용 */
                        ExpandableNotifier( //컨테이너 마다 컨트롤러를 할당하기 위해 빌더를 쓴다 ㄱㄱㄱ https://pub.dev/packages/expandable/example
                            child:
                            Builder(
                              builder: (context){
                                // 빌더를 통해 각각의 위젯마다 독립된 컨트롤러 할당
                                var controller = ExpandableController.of(context, required: true)!;
                                return ExpandablePanel(
                                    theme: const ExpandableThemeData(headerAlignment: ExpandablePanelHeaderAlignment.center,),
                                    // 1. 제목
                                    header:
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("${result['dirary_screen_title']}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: GeneralCtr.fontsize_normal*1.1)),
                                        /* 사회적 거리두기 */
                                        SizedBox(height: 10)
                                      ],
                                    ),

                                    // 2. 내용 접었을 때
                                    collapsed: InkWell(
                                        onTap: (){
                                          /* 접었다 폈다 토글동작 */
                                          controller.toggle();
                                        },
                                        child:
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("${result['dirary_screen_contents']}",
                                                maxLines:3, overflow: TextOverflow.ellipsis, softWrap: true,// 공간을 넘는 글자는 쩜쩜쩜(...)으로 표기한다.
                                                style: TextStyle(fontSize:GeneralCtr.fontsize_normal)
                                            ),
                                            Text("..더 보기", style: TextStyle(color: Colors.grey,fontSize:GeneralCtr.fontsize_normal*0.9))

                                          ],
                                        )

                                    ),
                                    // 3. 내용 펼쳤을 때
                                    expanded:  Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        /* 일기 내용(본문, contents)보여주기 */
                                        InkWell(
                                            onTap: (){
                                              /* 접었다 폈다 토글동작 */
                                              controller.toggle();
                                            },
                                            child: Text("${result['dirary_screen_contents']}",  style: TextStyle(fontSize:GeneralCtr.fontsize_normal))
                                        ),
                                        /* 사회적 거리두기 */
                                        SizedBox(height: 10),
                                        /* 성경구절 보여주는 위젯 */
                                        ViewVerses(index: index),
                                      ],
                                    )

                                );
                              },
                            )
                        ),

                        //SizedBox(height: 10),
                        /* 사진보여주기 */
                        ViewPhoto(result: result),
                        /* 사회적 거리두기 */
                        SizedBox(height: 10),
                        /* 주소 */
                        Text("${result['dirary_screen_address']}",style: TextStyle(color: Colors.grey, fontSize: GeneralCtr.fontsize_normal*0.7)),
                        /* 사회적 거리두기 */
                        SizedBox(height: 10),
                        /* 38도선 */
                        Divider(thickness: 1)
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
      ),
    );
}


/* 리스트뷰에서 컨텐츠 최상단(#헤더) */
/* 컨테이너 상단 식별 정보 */
Widget ContentsHeader(context, result, index){
  /* 날짜 데이터를 보기좋게 재구성 */
  var date_temp = result['dirary_screen_selectedDate'].toDate();
  var date_format = "${date_temp.year}.${date_temp.month}.${date_temp.day}"; //date로 형식 변환
  var week_day = DiaryCtr.ConvertWeekday(date_temp.weekday);

  return
    Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /* 프로필 사진 */
        Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
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
        /* 1층 : 닉네임+이모지 - 수정시간 + 수정버튼*/
        /* 2층 : 지정날짜 / 주소 */
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /* 1층 : 닉네임+이모지 - 수정시간 + 수정버튼*/
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /* 닉네임+이모티콘*/
                  Row(
                    children: [
                      Text("${MyCtr.displayName}", style: TextStyle(fontSize: GeneralCtr.fontsize_normal)),
                      Image.asset(
                        "assets/img/icons/emoticon/${DiaryCtr.EmoticonName[result['dirary_screen_emoticon_index']]}.png",
                        height: GeneralCtr.fontsize_normal*0.8,
                        width: GeneralCtr.fontsize_normal*0.8,
                      ),
                    ],
                  ),
                  /* 수정시간 + 수정버튼 */
                  Row(
                    children: [
                      Text("${DiaryCtr.diary_view_timediffer[index]} 수정", style: TextStyle(fontSize: GeneralCtr.fontsize_normal*0.7, color: Colors.grey)),
                      PopupMenuButton(
                          child: Container(
                            height: 30,
                            width: 25,
                            alignment: Alignment.centerRight,
                            child: Icon(Icons.more_vert_sharp, size: GeneralCtr.fontsize_normal, color: Colors.black54),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          padding: EdgeInsets.zero,
                          tooltip: "추가기능",
                          color: Colors.white, // pop메뉴 배경색
                          elevation: 10,// pop메뉴 그림자
                          onSelected: (value) {
                            /* 옵션 버튼에 따른 동작 지정 */
                            switch(value){
                              case"수정": DiaryCtr.diary_modify_call(index); break;
                              case"삭제": Delete_check_Dialog(context, result.id, index);break;
                            }
                          },
                          /* 옵션 버튼 _ 하위 메뉴 스타일 */
                          itemBuilder: (context) => [
                            /*삭제*/
                            PopupMenuItem(child: Row(children: [Icon(FontAwesome5.eraser, size: GeneralCtr.fontsize_normal*0.7), Text(" 수정", style: TextStyle(fontSize: GeneralCtr.fontsize_normal*0.7))]), value: "수정"),
                            /*수정*/
                            PopupMenuItem(child: Row(children: [Icon(FontAwesome.trash_empty, size: GeneralCtr.fontsize_normal*0.7), Text(" 삭제", style: TextStyle(fontSize: GeneralCtr.fontsize_normal*0.7))]), value: "삭제"),
                          ]
                      ),
                    ],
                  ),
                ],
              ),
              /* 2층 : 지정날짜 / 주소 / 날씨*/
              Row(
                children: [
                  Text("$date_format($week_day) ${DiaryCtr.TimeTag[result['dirary_screen_timetag_index']]}", style: TextStyle(color: Colors.grey, fontSize: GeneralCtr.fontsize_normal*0.7)),
                  Image.asset(
                    "assets/img/icons/weather/${DiaryCtr.WeatherName[result['dirary_screen_weather_index']]}.png",
                    height: GeneralCtr.fontsize_normal*0.7,
                    width: GeneralCtr.fontsize_normal*0.7,
                  ),
                ],
              )

            ],
          ),
        ),
        /* 옵션 버튼 */
        Row(
          children: [

          ],
        )
      ],
    );
}


//<서브위젯> 성경 카드 위젯
/* 아래부터 선택한 성경 카드로 보여주기 *///https://docs.getwidget.dev/gf-carousel/
class ViewVerses extends StatelessWidget {
  const ViewVerses({Key? key, this.index}) : super(key: key);

  /* 일기 인덱스 받아오기 */
  final index;

  @override
  Widget build(BuildContext context) {
    return GFCarousel(
      height: 190,
      activeIndicator: GeneralCtr.MainColor,
      passiveIndicator: Colors.white,
      pagerSize: 7.0,// 이미지 하단 페이지 인디케이터 크기
      enableInfiniteScroll: false, // 무한스크롤
      viewportFraction: 1.0, // 전.후 이미지 보여주기 ( 1.0이면 안보여줌 )
      aspectRatio: 0, // 사진 비율
      enlargeMainPage: true, // 자동 확대
      pagination: true, // 이미지 하단 페이지 인디케이터 표시여부
      autoPlayInterval: Duration(milliseconds: 5000), // 자동 넘기기 주기(시간)
      autoPlay: false, // 자동 넘기기 on/off
      pauseAutoPlayOnTouch: Duration(milliseconds: 5000), // 클릭하면 자동넘기기 일시 정지

      /* 선택된 구절 갯수만큼 카드 만들어주기 */
      items: DiaryCtr.diary_view_contents_filtered[index]['dirary_screen_selected_verses_id'].map<Widget>(
            (id) {

          /* 필터링으로 구절정보 하나씩 가져오기 */
          var contents_data = DiaryCtr.diary_view_selected_contents_data.where((f)=>f["_id"]==id).toList();
          var diary_data = DiaryCtr.diary_view_contents_filtered[index];

          /* 성경 구절 카드에 담아서 보여주기 */
          /* 1. 정보가 "null"이 아니면, 구절 정보 담아서 보여준다 */
          return Container(
            decoration: BoxDecoration(
              color: DiaryCtr.ColorCode[diary_data['dirary_screen_color_index']].withOpacity(0.4), // 카드 색깔
              borderRadius: BorderRadius.circular(5),
            ),
            margin: EdgeInsets.fromLTRB(2, 0, 2, 0), // 좌우 카드끼리 간격 띄우기
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
                        SelectableText("  [${contents_data[0]['국문']}(${contents_data[0]['영문']}) ${contents_data[0]['cnum']}장 ${contents_data[0]['vnum']}절]",style:TextStyle(height: 1.5, fontSize: GeneralCtr.fontsize_normal*0.9)),
                      ],
                    ),
                    /* 사회적 거리두기 */
                    SizedBox(height: 5),

                    /* 성경 구절 메인 보여주기 */
                    ClipRRect(
                      //borderRadius: BorderRadius.all(Radius.circular(0.0)),
                      /* 성경 구절 담기 */
                      child: GFCard(
                        padding: EdgeInsets.fromLTRB(5, 5, 5, 5), // 하얀카드 안쪽 텍스트 패딩
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 25), // 컨테이너 자체 마진
                        boxFit: BoxFit.fitHeight,
                        /* 구절 내영 */
                        content: SizedBox(
                            height: 95,
                            child: SelectableText('${contents_data[0][BibleCtr.Bible_choiced]}' ,style:TextStyle(height: 1.5, fontSize: GeneralCtr.fontsize_normal*0.9))),
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


//<서브위젯> 사진 보여주기 위젯
class ViewPhoto extends StatelessWidget {
  const ViewPhoto({Key? key, this.result}) : super(key: key);

  final result; // 결과값 받아오기

  @override
  Widget build(BuildContext context) {
    /* 저장된 사진이 있는 경우 */
    if (result['choiced_image_file'].length>0) {
      return GFCarousel(
        height: 330, // 고정사이즈 적용, 아래 페이저가 보이도록
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
      );
    } else {
      /* 저장된 사진이 없는 경우 */
      return SizedBox(height: 0);
    }
  }
}


//<서브위젯> 시간 태그 보여주기 위젯
class ViewTimeTag extends StatelessWidget {
  const ViewTimeTag({Key? key, this.result}) : super(key: key);

  final result;

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}


//<서브위젯> 해시태그 입력 모듈
Widget HashTagView(result){
  return
    SizedBox(
      // 아래 텍스트 크기와 동일하게 높이를 맞춰준다, 보여줄 태그가 없으면 공간을 없앤다
      height: result['dirary_screen_hashtag'].length != 0 ? GeneralCtr.fontsize_normal*0.9 : 0,
      child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(), // 빌더 내부에서 별도로 스크롤 관리할지, 이게 활성화 된경우 전체 스크롤보다 해당 스크롤이 우선되므로 일단은 비활성화가 좋다
          shrinkWrap: true, //"hassize" 같은 ㅈ같은 오류 방지
          scrollDirection: Axis.horizontal, // 수직(vertical)  수평(horizontal) 배열 선택
          //controller: ,// 스크롤 조작이 필요하다면 할당 ㄱㄱ
          itemCount: result['dirary_screen_hashtag'].length,
          itemBuilder: (context, index) {
            return TextButton(
              onPressed: (){
                /*  해시태크 클릭 이벤트(추가예정) */
              },
              child: Text("${result['dirary_screen_hashtag'][index]}", style: TextStyle(fontSize: GeneralCtr.fontsize_normal*0.85)),
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            );
          }
      ),
    );
}

//<서브위젯> 검색창 모듈
Widget SearchWidget(){
  return
    SizedBox(
      width: 250,
      child: TextField(
        onChanged: (keyword){
          /* 검색어를 입력 했을 때 액션 정의 */
          DiaryCtr.result_filtering(keyword);
        },
        controller: DiaryCtr.DiarySearchController, // 텍스트값을 가져오기 위해 컨트롤러 할당
        autofocus: false, // 자동으로 클릭할것인가
        style: TextStyle(fontSize: GeneralCtr.fontsize_normal),
        decoration: InputDecoration(
            prefixIcon: Icon(Icons.search),
            // suffixIcon: IconButton(
            //   icon: Icon(Icons.clear),
            //   onPressed: () {
            //     /* 클리어 버튼(X) 눌렀을 때 텍스트 비우기 */
            //     DiaryCtr.DiarySearchController.clear();
            //   },
            // ),
            hintText: '검색어',
            hintStyle: GeneralCtr.TextStyle_normal_disable,
            border: InputBorder.none),
      ),
    );
}




