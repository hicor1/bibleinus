import 'package:bible_in_us/bible/bible_component.dart';
import 'package:bible_in_us/bible/bible_controller.dart';
import 'package:bible_in_us/general/general_controller.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:get/get.dart';


// Gex컨트롤러 객체 초기화
final GeneralCtr = Get.put(GeneralController());
final BibleCtr = Get.put(BibleController());

class BibleFavoritePage extends StatelessWidget {
  const BibleFavoritePage({Key? key}) : super(key: key);

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

    /* GetX 불러오기 */
    return GetBuilder<BibleController>(
        init: BibleController(),
        builder: (_){
          return Padding(
            padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                /* 선택된 성경 구절 가져오기 */
                Flexible(
                  child: Scrollbar(
                    child: ListView.builder(
                        scrollDirection: Axis.vertical, // 수직(vertical)  수평(horizontal) 배열 선택
                        //controller: ,// 스크롤 조작이 필요하다면 할당 ㄱㄱ
                        itemCount: BibleCtr.Favorite_list.length,
                        itemBuilder: (context, index) {
                          var result = BibleCtr.Favorite_list[index]; // 결과 할당, 이런식으로 변수 선언 가능, 아래 위젯에서 활용 가능
                          return Container(
                            width: MediaQuery.of(context).size.width, // 요건 필수
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black.withOpacity(0.3), width: 1),
                                borderRadius: BorderRadius.circular(5)
                            ),
                            padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                            margin: EdgeInsets.fromLTRB(0, 0, 10, 5),
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
                                            style: TextStyle(fontSize: GeneralCtr.Textsize*0.8, color: BibleCtr.ColorCode[result['highlight_color_index']], fontWeight: FontWeight.bold)),
                                        /* 즐겨찾기 색(칼러,칼라) 변경 버튼 */
                                        IconButton(
                                          onPressed: () {
                                            // 0. 클릭된 구절정보로 업데이트 해주기
                                            BibleCtr.Favorite_color_change(result['_id']);
                                            // 1. 팝업창 띄우고 '예'인 경우, 넘어가기 //
                                            AddFavorite(context);
                                          },
                                          icon: Icon(
                                              FontAwesome5.highlighter,
                                              size: GeneralCtr.Textsize*0.9,
                                              color: BibleCtr.ColorCode[result['highlight_color_index']]),
                                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                          constraints: BoxConstraints(),
                                        ),
                                        /* 본문으로 이동해서 전체로 보기 버튼 */
                                        IconButton(
                                          onPressed: () {
                                            // 1. 팝업창 띄우고 '예'인 경우, 넘어가기 //
                                            IsMoveDialog(context, result, index);
                                          },
                                          icon: Icon(
                                              FontAwesome5.arrow_circle_right,
                                              size: GeneralCtr.Textsize*0.9,
                                              color: BibleCtr.ColorCode[result['highlight_color_index']]),
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(),
                                        ),
                                      ],
                                    )
                                  ],
                                ),


                                /* 본문 */
                                Text("${result[BibleCtr.Bible_choiced]}",
                                  style: TextStyle(fontSize: GeneralCtr.Textsize, height: GeneralCtr.Textheight),),
                              ],
                            ),
                          );
                        }
                    ),
                  ),
                ),



                /* 칼라코드 보여주기 */
                Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.all(20),
                    child: Center(
                      child: ListView.builder(
                          shrinkWrap: true, // 등간격 정렬하기 위해 위에 "Center"위젯과 함께 사용
                          scrollDirection: Axis.horizontal,
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
                                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      // 선택한 색깔 테두리 강조
                                        color: BibleCtr.Favorite_choiced_color_list.contains(index) ? Colors.grey : Colors.transparent,
                                        width: 2)
                                ),
                                // 젤 처음 아이콘은 "X"표시로 변경
                                child: Icon(
                                    index != 0 ? FontAwesome5.highlighter : Entypo.cancel,
                                    color: BibleCtr.ColorCode[index], size: 40),
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
