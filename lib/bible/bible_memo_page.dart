import 'dart:convert';

import 'package:bible_in_us/bible/bible_component.dart';
import 'package:bible_in_us/bible/bible_controller.dart';
import 'package:bible_in_us/general/general_controller.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:word_break_text/word_break_text.dart';


// Gex컨트롤러 객체 초기화
final GeneralCtr = Get.put(GeneralController());
final BibleCtr = Get.put(BibleController());

class BibleMemoPage extends StatelessWidget {
  const BibleMemoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /* 메모 로드 */
    BibleCtr.Memo_DB_load();
    /* 메인위젯 뿌리기 */
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
            child: Flexible(
              child: Scrollbar(
                child: ListView.builder(
                    itemCount: BibleCtr.Memo_list.length,
                    itemBuilder: (context, index) {
                      var result = BibleCtr.Memo_list[index]; // 결과 할당, 이런식으로 변수 선언 가능, 아래 위젯에서 활용 가능
                      var verses_list = json.decode(result['연관구절']);// 그냥 가져오면 텍스트로 가져오므로 리스트로 변환해줌
                      return Column(
                        children: [
                          /* 그림자(shadow)효과를 위해 Materail 위젯 씌우기 */
                          Material(
                            color: Colors.white,
                            elevation: 1.5,

                            /* 커스톰 위젯을 써보자 ㄱㄱ */
                            child: GFAccordion(

                              /* 제목 */
                                titleChild: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    /* 내용 표기 */
                                    Flexible(
                                        child: WordBreakText("${result['메모']}",
                                          style: TextStyle(fontSize: GeneralCtr.Textsize, color: Colors.black))),
                                    /* 경과 시간 표기 */
                                    Text("${BibleCtr.Memo_timediffer_list[index]}",
                                        style: TextStyle(fontSize: GeneralCtr.Textsize*0.8, color: Colors.grey, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                collapsedTitleBackgroundColor: Colors.white, // 평소 제목 배경 색깔
                                expandedTitleBackgroundColor:Colors.blueAccent.withOpacity(0.2), // 펼쳤을때, 제목 배경 색깔

                              /* 본문 */
                                contentChild: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: verses_list.length,// 각 메모에 있는 "연관구절 리스트" 길이 가져옴
                                    itemBuilder: (context2, index2) {
                                      var verse = BibleCtr.Memo_verses_list.where((e)=>e['_id'] == verses_list[index2]).toList()[0]; // "Memo_verses_list"에서 조건에 맞는 구절을 하나씩 가져온다
                                      return Container(
                                        padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                                        color: Colors.transparent,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            /* 구절 정보 */
                                            Row(
                                              children: [

                                                Text("${verse['국문']} (${verse['영문']}): ${verse['cnum']}장 ${verse['vnum']}절 ",
                                                    style: TextStyle(fontSize: GeneralCtr.Textsize*0.8, color: Colors.grey, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                            /* 구절 내용 */
                                            Text("${verse[BibleCtr.Bible_choiced]}",
                                              style: TextStyle(fontSize: GeneralCtr.Textsize, height: GeneralCtr.Textheight))
                                          ],
                                        ),
                                      );
                                    }
                                ),
                              contentBackgroundColor: Colors.white, // 본문 배경 색깔
                              contentPadding: EdgeInsets.all(0), // 본문 패딩 조절

                            ),
                          ),
                          SizedBox(height: 5)
                        ],
                      );
                    }
                ),
              ),
            ),
          ); //return은 필수
        }
    );
  }
}
