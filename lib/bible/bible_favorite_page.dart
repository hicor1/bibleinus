import 'package:bible_in_us/bible/bible_component.dart';
import 'package:bible_in_us/bible/bible_controller.dart';
import 'package:bible_in_us/general/general_controller.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/typicons_icons.dart';
import 'package:fluttericon/web_symbols_icons.dart';
import 'package:get/get.dart';
import 'package:word_break_text/word_break_text.dart';
import 'package:getwidget/getwidget.dart';


// Gex컨트롤러 객체 초기화
final GeneralCtr = Get.put(GeneralController());
final BibleCtr = Get.put(BibleController());

class BibleFavoritePage extends StatelessWidget {
  const BibleFavoritePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /* 색깔별 갯수 받아오기 */
    BibleCtr.Get_color_count();
    /* 메인위젯 뿌려주기 */
    return MainWidget();
  }
}

/* <서브위젯> 메인 위젯 정의 */
class MainWidget extends StatelessWidget {
  const MainWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    /* GetX 불러오기 */
    return GetBuilder<BibleController>(
        init: BibleController(),
        builder: (_){
          return Padding(
            padding: EdgeInsets.fromLTRB(5, 10, 5, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                /* 메인컨텐츠 _ 선택된 성경 구절 가져오기 */
                Flexible(
                  child: Scrollbar(
                    child: ListView.builder(
                        shrinkWrap: true, //"hassize" 같은 ㅈ같은 오류 방지
                        scrollDirection: Axis.vertical, // 수직(vertical)  수평(horizontal) 배열 선택
                        //controller: ,// 스크롤 조작이 필요하다면 할당 ㄱㄱ
                        itemCount: BibleCtr.Favorite_list.length,
                        itemBuilder: (context, index) {
                          /* 결과 할당, 이런식으로 변수 선언 가능, 아래 위젯에서 활용 가능 */
                          var result = BibleCtr.Favorite_list[index];
                          /* 해당 구절이 클릭된 구절인지 확인 */
                          var checker = false;
                          if(BibleCtr.ContentsIdList_clicked.contains(result['_id'])){
                            checker = true;
                          }else{
                            checker = false;
                          }
                          return Column(
                            children: [
                              // 컨테이너에 테두리 대신, 그림자(elevation)로 구분을 준다.
                              Material(
                                color: Colors.white,
                                elevation: 0.0, // 그림자(elevation) 두께? 너비 같은거
                                /* 본문으로 이동해서 전체로 보기 버튼 */
                                child: InkWell(
                                  /* 컨테이너를 눌렀을 때 해당 페이지로 이동할지 물어보자 ㄱㄱ */
                                  onTap: (){
                                    /* 해당 기능을 호출한 앱(app)에 따라 다른 액션 적용 */
                                    switch (BibleCtr.from_which_app) {
                                      case "bible" : // 1. bible앱 에서 호출한 경우
                                        IsMoveDialog(context, result, index); break;
                                      case "diary" : // 2. diary앱 에서 호출한 경우
                                        IsMoveDialog_from_diary(context, result, index); break;
                                    }
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width, // 요건 필수
                                    padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                    margin: EdgeInsets.fromLTRB(5, 0, 5, 5),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            /* 구절정보를 포함하는 체크버튼에 대한 액션 설정 */
                                            InkWell(
                                              onTap: (){
                                                /* 클릭한 컨텐츠 아이디 저장(아래 아이콘 클릭과 동일한 기능 적용) */
                                                BibleCtr.ContentsList_click(result['_id']);
                                              },
                                              child: Row(
                                                children: [
                                                  /* 메모 추가를 위한 체크박스 _ 플로팅 액숀버튼 띄우기 */
                                                  GFCheckbox(
                                                    size: GeneralCtr.fontsize_normal*1.1, // 박스 사이즈
                                                    activeIcon: Icon(Typicons.ok, size: GeneralCtr.fontsize_normal, color: BibleCtr.ColorCode[result['highlight_color_index']]), // 활성 아이콘
                                                    inactiveIcon: Icon(Typicons.ok_outline, size: GeneralCtr.fontsize_normal, color: Colors.white), // 비활성 아이콘
                                                    type: GFCheckboxType.circle, // 아이콘 모양(사각형, 원형 등등)
                                                    activeBgColor: Colors.transparent, // 활성 아이콘 배경 색깔
                                                    activeBorderColor: BibleCtr.ColorCode[result['highlight_color_index']], // 활성 아이콘 테두리 색깔
                                                    inactiveBgColor: BibleCtr.ColorCode[result['highlight_color_index']].withOpacity(0.25), // 비활성 아이콘 색깔
                                                    inactiveBorderColor: Colors.grey.withOpacity(0.0), // 비활성 아이콘 테두리 색깔

                                                    onChanged: (value) {
                                                      /* 클릭한 컨텐츠 아이디 저장(위에 컨테이너 클릭과 동일한 기능 적용) */
                                                      BibleCtr.ContentsList_click(result['_id']);
                                                    },
                                                    value: checker,
                                                  ),
                                                  /* 위젯간 거리두기 캠페인 */
                                                  SizedBox(width: 5),
                                                  /* 구절 정보( 클릭된 구절은 강조해주기 ) */
                                                  Container(
                                                    color: checker ? BibleCtr.ColorCode[result['highlight_color_index']] : Colors.transparent,
                                                    child: Text("${result['국문']} (${result['영문']}): ${result['cnum']}장 ${result['vnum']}절 ",
                                                        style: TextStyle(fontSize: GeneralCtr.fontsize_normal,
                                                            color: checker ? Colors.white :BibleCtr.ColorCode[result['highlight_color_index']],
                                                            fontWeight: FontWeight.bold)
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            /* 각종 버튼 */
                                            Row(
                                              children: [
                                                /* 경과시간 표기 */
                                                Text("${BibleCtr.Favorite_timediffer_list[index]}",
                                                    style: TextStyle(fontSize: GeneralCtr.fontsize_normal*0.8, color: Colors.grey, fontWeight: FontWeight.bold)),
                                              ],
                                            )
                                          ],
                                        ),
                                        SizedBox(height: GeneralCtr.Textheight+10), //제목열과 본문 살짝 띄워주기

                                        /* 본문 */
                                        WordBreakText("${result[BibleCtr.Bible_choiced]}",
                                          style: TextStyle(fontSize: GeneralCtr.Textsize, height: GeneralCtr.Textheight),),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              //사회적 거리두기
                              Divider(),
                              SizedBox(height: 5)
                            ],
                          );
                        }
                    ),
                  ),
                ),

                /* 칼라코드 보여주기 */
                Container(
                    height: 55,
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.all(10),
                    child: Center(
                      child: ListView.builder(
                          shrinkWrap: true, // 등간격 정렬하기 위해 위에 "Center"위젯과 함께 사용
                          scrollDirection: Axis.horizontal, // 수평 배치
                          itemCount: BibleCtr.ColorCode.length,
                          itemBuilder: (context, index) {
                            /* 각 색깔별 갯수 구하기 */
                            //1. 결과값 담을 변수 만들기
                            var color_count = null;
                            //2. 빈값이면 "0"을 리턴하고, 그렇지 않으면 DB에서 받은값을 사용하기
                            if(BibleCtr.Favorite_Color_count.where((e)=>e['highlight_color_index']==index).isEmpty){
                              color_count = "0";
                            }else{
                              color_count = BibleCtr.Favorite_Color_count.where((e)=>e['highlight_color_index']==index).toList()[0]['count(highlight_color_index)'];
                            }
                            // 색깔 선택이 가능하도록 "InkWell" 위젯으로 감싸기
                            return InkWell(
                              splashColor: Colors.white,
                              onTap: (){
                                /* 선택한 칼라코드 리스트에 추가 또는 제외 해주기 */
                                BibleCtr.Favorite_choiced_color_list_update(index);
                                /* 선택된 칼로코드 리스트에 맞는 즐겨찾기 불러오기 */
                                BibleCtr.GetFavorite_list();
                              },
                              child: Container(
                                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                // 젤 처음 아이콘은 "X"표시로 변경
                                child: Column(
                                  children: [
                                    /* 아이콘 배치(색깔에 맞게), 아이콘을 겹쳐서 강조표기해주기 */
                                    Stack(
                                      alignment: Alignment.center,
                                      children:[
                                        /* 색깔 아이콘 */
                                        Icon(
                                            index != 0 ? FontAwesome5.star : Entypo.cancel,
                                            color: BibleCtr.ColorCode[index], size: 25
                                        ),
                                        /* 색깔 선택 아이콘 */
                                        Icon(
                                          BibleCtr.Favorite_choiced_color_list.contains(index) ? WebSymbols.ok : null,
                                            color: Colors.deepOrangeAccent, size: 15
                                        ),
                                      ]
                                    ),
                                    /* 색깔별 갯수 배치 (0번 인덱스는 갯수 표기 안함) */
                                    Text(
                                        index == 0 ? "취소" :  // 0번째 인덱스는 "취소"표기
                                        " ${color_count}", style: TextStyle(color: BibleCtr.ColorCode[index], fontSize: GeneralCtr.fontsize_normal),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }
                      ),
                    )
                ),
              ],
            ),
          ); //return은 필수
        }
    );
  }
}
