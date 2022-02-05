import 'package:bible_in_us/bible/bible_component.dart';
import 'package:bible_in_us/bible/bible_controller.dart';
import 'package:bible_in_us/general/general_controller.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
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
            padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                /* 선택된 성경 구절 가져오기 */
                Flexible(
                  child: Scrollbar(
                    child: ListView.builder(
                        shrinkWrap: true, //"hassize" 같은 ㅈ같은 오류 방지
                        scrollDirection: Axis.vertical, // 수직(vertical)  수평(horizontal) 배열 선택
                        //controller: ,// 스크롤 조작이 필요하다면 할당 ㄱㄱ
                        itemCount: BibleCtr.Favorite_list.length,
                        itemBuilder: (context, index) {
                          var result = BibleCtr.Favorite_list[index]; // 결과 할당, 이런식으로 변수 선언 가능, 아래 위젯에서 활용 가능
                          return Column(
                            children: [
                              // 컨테이너에 테두리 대신, 그림자(elevation)로 구분을 준다.
                              Material(
                                color: Colors.white,
                                elevation: 1.0, // 그림자(elevation) 두께? 너비 같은거
                                /* 본문으로 이동해서 전체로 보기 버튼 */
                                child: InkWell(
                                  onTap: () {
                                    // 1. 팝업창 띄우고 '예'인 경우, 넘어가기 //
                                    IsMoveDialog(context, result, index);
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width, // 요건 필수
                                    padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                                    margin: EdgeInsets.fromLTRB(5, 0, 5, 5),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            /* 구절 정보 */
                                            Text("${result['국문']} (${result['영문']}): ${result['cnum']}장 ${result['vnum']}절 ",
                                                style: TextStyle(fontSize: GeneralCtr.Textsize*0.8, color: BibleCtr.ColorCode[result['highlight_color_index']], fontWeight: FontWeight.bold)),

                                            /* 각종 버튼 */
                                            Row(
                                              children: [
                                                /* 경과시간 표기 */
                                                Text("${BibleCtr.Favorite_timediffer_list[index]}",
                                                    style: TextStyle(fontSize: GeneralCtr.Textsize*0.8, color: Colors.grey, fontWeight: FontWeight.bold)),
                                                /* 즐겨찾기 색(칼러,칼라) 변경 버튼 */
                                                IconButton(
                                                  onPressed: () {
                                                    // 0. 클릭된 구절정보로 업데이트 해주기
                                                    BibleCtr.Favorite_color_change(result['_id']);
                                                    // 1. 팝업창 띄우고 '예'인 경우, 넘어가기 //
                                                    AddFavorite(context);
                                                  },
                                                  /* 색변경 아이콘 */
                                                  icon: Icon(
                                                      FontAwesome5.highlighter,
                                                      size: GeneralCtr.Textsize*0.9,
                                                      color: BibleCtr.ColorCode[result['highlight_color_index']]),
                                                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                                  constraints: BoxConstraints(),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                        SizedBox(height: 5), //제목열과 본문 살짝 띄워주기

                                        /* 본문 */
                                        WordBreakText("${result[BibleCtr.Bible_choiced]}",
                                          style: TextStyle(fontSize: GeneralCtr.Textsize, height: GeneralCtr.Textheight),),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // 컨테이너 끼리 조금 띄워놔야 이쁘다
                              SizedBox(height: 5)
                            ],
                          );
                        }
                    ),
                  ),
                ),

                /* 칼라코드 보여주기 */
                Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.all(20),
                    child: Center(
                      child: ListView.builder(
                          shrinkWrap: true, // 등간격 정렬하기 위해 위에 "Center"위젯과 함께 사용
                          scrollDirection: Axis.horizontal, // 수평 배치
                          itemCount: BibleCtr.ColorCode.length,
                          itemBuilder: (context, index) {
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
                                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      // 선택한 색깔 테두리 강조
                                        color: BibleCtr.Favorite_choiced_color_list.contains(index) ? Colors.grey : Colors.transparent,
                                        width: 2)
                                ),
                                // 젤 처음 아이콘은 "X"표시로 변경
                                child: Column(
                                  children: [
                                    /* 아이콘 배치(색깔에 맞게) */
                                    Icon(
                                        index != 0 ? FontAwesome5.highlighter : Entypo.cancel,
                                        color: BibleCtr.ColorCode[index], size: 40),
                                    /* 색깔별 갯수 배치 (0번 인덱스는 갯수 표기 안함) */
                                    Text(
                                        index == 0 ? "" :
                                        "${BibleCtr.Favorite_Color_count.where((e)=>e['highlight_color_index']==index).toList()[0]['count(highlight_color_index)']}"
                                            , style: TextStyle(color: BibleCtr.ColorCode[index]),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }
                      ),
                    )
                )
              ],
            ),
          ); //return은 필수
        }
    );
  }
}
