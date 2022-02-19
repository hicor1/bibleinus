import 'dart:convert';

import 'package:bible_in_us/bible/bible_component.dart';
import 'package:bible_in_us/bible/bible_controller.dart';
import 'package:bible_in_us/general/general_controller.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/modern_pictograms_icons.dart';
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
            child: Scrollbar(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: BibleCtr.Memo_list.length,
                  itemBuilder: (context, index) {
                    var result = BibleCtr.Memo_list[index]; // 결과 할당, 이런식으로 변수 선언 가능, 아래 위젯에서 활용 가능
                    var verses_list = json.decode(result['연관구절']);// 그냥 가져오면 텍스트로 가져오므로 리스트로 변환해줌
                    return Column(
                      children: [
                        /* 그림자(shadow)효과를 위해 Materail 위젯 씌우기 */
                        Material(
                          color: Colors.white,
                          elevation: 1.0,

                          /* 커스톰 위젯을 써보자 ㄱㄱ */
                          child: GFAccordion(
                            /* 각종 스타일 정의 */
                            collapsedTitleBackgroundColor: Colors.white, // 평소 제목 배경 색깔
                            expandedTitleBackgroundColor:GeneralCtr.MainColor.withOpacity(0.15), // 펼쳤을때, 제목 배경 색깔
                            contentBackgroundColor: Colors.white, // 본문 배경 색깔
                            contentPadding: EdgeInsets.all(0), // 본문 패딩 조절
                            titleBorderRadius: BorderRadius.circular(10), // 제목 테두리 라운드
                            contentBorderRadius: BorderRadius.circular(10), // 본문 테두리 라운드

                            /* 제목 */
                            titleChild: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                /* 제목 표기 */
                                Flexible(
                                    child: SelectableText("${result['메모']}", // 복사 가능하도록
                                        style: TextStyle(fontSize: GeneralCtr.Textsize, color: Colors.black))
                                ),
                              ],
                            ),

                            /* 본문 */
                            contentChild: Column(
                              children: [
                                /* 본문 최상단 경과시간 및 옵션버튼 배치 */
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    /* 경과 시간 표기 */
                                    Text("${BibleCtr.Memo_timediffer_list[index]}",
                                        style: TextStyle(fontSize: GeneralCtr.Textsize*0.7, color: Colors.grey, fontWeight: FontWeight.bold)
                                    ),

                                    /* 옵션 버튼(편집, 삭제 등) _ DPopupMenuButton */
                                    PopupMenuButton(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5)),
                                        color: Colors.white, // pop메뉴 배경색
                                        elevation: 10,// pop메뉴 그림자
                                        tooltip: "추가기능",
                                        onSelected: (value) {
                                          /* 각 버튼에 따른 액션 정의 */
                                          switch(value){
                                          /* 1. [편집] 버튼 클릭 */
                                            case "편집" :
                                            // 1-1. 현재 구절 담아주기
                                              BibleCtr.Memo_ContentsIdList_update(result);
                                              // 1-2. 편집 팝업 띄워주기
                                              AddMemo(context, result["_id"], "UPDATE"); // 입력과 동일한 팝업 재활용 및 업데이트 이므로 "UPDATE"로 분류
                                              break;
                                          /* 2. [삭제] 버튼 클릭 */
                                            case "삭제" :
                                              IsMemoDelete(context, result['_id']); // [삭제]팝업띄우기, 확인 버튼에 대한 액션은 팝업 내에서 처리한다.
                                              break;
                                          }
                                        },
                                        icon: Icon(Icons.more_vert_sharp,size: GeneralCtr.Textsize*1.2), // pop메뉴 아이콘
                                        /* 하위 메뉴 스타일 */
                                        itemBuilder: (context) => [
                                          PopupMenuItem(child: Row(children: [Icon(ModernPictograms.edit, size: GeneralCtr.Textsize*0.9), Text(" 편집", style: TextStyle(fontSize: GeneralCtr.Textsize*0.9))]), value: "편집"),
                                          PopupMenuItem(child: Row(children: [Icon(FontAwesome.trash_empty, size: GeneralCtr.Textsize*0.9), Text(" 삭제", style: TextStyle(fontSize: GeneralCtr.Textsize*0.9))]), value: "삭제"),
                                        ]
                                    )
                                  ],
                                ),

                                /*  본문 성경내용 ListView */
                                ListView.builder(
                                    physics: const NeverScrollableScrollPhysics(), // 빌더 내부에서 별도로 스크롤 관리할지, 이게 활성화 된경우 전체 스크롤보다 해당 스크롤이 우선되므로 일단은 비활성화가 좋다
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

                                                SelectableText("${verse['국문']} (${verse['영문']}): ${verse['cnum']}장 ${verse['vnum']}절 ",
                                                    style: TextStyle(fontSize: GeneralCtr.Textsize*0.8, color: Colors.grey, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                            /* 구절 내용 */
                                            SelectableText("${verse[BibleCtr.Bible_choiced]}",
                                                style: TextStyle(letterSpacing: 1.0,fontSize: GeneralCtr.Textsize*0.9, height: GeneralCtr.Textheight))
                                          ],
                                        ),
                                      );
                                    }
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 5)
                      ],
                    );
                  }
              ),
            ),
          ); //return은 필수
        }
    );
  }
}
