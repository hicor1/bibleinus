

import 'package:bible_in_us/bible/bible_component.dart';
import 'package:bible_in_us/bible/bible_controller.dart';
import 'package:bible_in_us/general/general_controller.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/typicons_icons.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:word_break_text/word_break_text.dart';


// Gex컨트롤러 객체 초기화
final GeneralCtr = Get.put(GeneralController());
final BibleCtr = Get.put(BibleController());

class BibleRecommendScreen extends StatelessWidget {
  const BibleRecommendScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainWidget();
  }
}

/* <서브위젯> 메인 위젯 정의 */
Widget MainWidget(){
  return
    GetBuilder<BibleController>(
        init: BibleController(),
        builder: (_){
          return Scaffold(
            appBar: AppBar(
                iconTheme: IconThemeData(
                  color: GeneralCtr.MainColor
              ),
                title: Text("성경구절 모음",
                    style: GeneralCtr.Style_title
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true
            ),

            body: SingleChildScrollView(
              child: Column(
                children: [
                  /* 태그 선택 버튼 위젯 */
                  TagListWidget(),
                  /* 사회적 거리두기 */
                  SizedBox(height: 20),
                  /* 태그에 맞는 성경 구절 보여주기 */
                  View_verses_list(),

                  /* 사회적 거리두기 */
                  SizedBox(height: 100),
                ],
              ),
            ),

          ); //return은 필수
        }
    );

}
/* <서브위젯> 태그 리스트 정의 */
Widget TagListWidget(){
  return
    Column(
      children: [
        /* 1층 태그 */
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TagButton("외로움"),
            TagButton("슬픔"),
            TagButton("믿음"),
          ],
        ),
        /* 2층 태그 */
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TagButton("미움"),
            TagButton("용기"),
            TagButton("공부"),
            TagButton("기도"),
          ],
        ),
        /* 3층 태그 */
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TagButton("사랑"),
            TagButton("일상"),
            TagButton("전도"),
            TagButton("유혹"),
          ],
        ),
      ],
    );
}
/* <서브위젯> 태그 버튼 정의 */
Widget TagButton(tag){
  return
    Container(
      height: GeneralCtr.fontsize_normal+15,
      padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
      child: OutlinedButton(
        onPressed: (){
          //BibleCtr.Test(text);
          BibleCtr.Update_recommend_tag(tag);
        },
        /* 선택된 태그 강조해주기 */
        child: Text("#$tag",
            style: TextStyle(
                color: BibleCtr.recommended_tag_list.contains(tag) ? Colors.black : Colors.grey.withOpacity(0.5),
                fontWeight: FontWeight.bold,
                fontSize: GeneralCtr.fontsize_normal*0.8)
        ),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          side: BorderSide(
            width: 1,
            color: BibleCtr.recommended_tag_list.contains(tag) ? Colors.black : Colors.grey.withOpacity(0.5),
          ),
        ),
      ),
    );
}

/* <서브위젯> 검색 결과에 따라 리스트 성경 구절 리스트 반환 해주기 */
Widget View_verses_list(){
  return
    /* 메인컨텐츠 _ 선택된 성경 구절 가져오기 */
    Scrollbar(
      child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true, //"hassize" 같은 ㅈ같은 오류 방지
          scrollDirection: Axis.vertical, // 수직(vertical)  수평(horizontal) 배열 선택
          //controller: ,// 스크롤 조작이 필요하다면 할당 ㄱㄱ
          itemCount: BibleCtr.recommendedList_clicked_filteted.length,
          itemBuilder: (context, index) {
            /* 결과 할당, 이런식으로 변수 선언 가능, 아래 위젯에서 활용 가능 */
            var result = BibleCtr.recommendedList_clicked_filteted[index];

            return InkWell(
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
                padding: EdgeInsets.fromLTRB(5,5,5,5),
                margin: EdgeInsets.fromLTRB(15,5,15,5),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 3.5,
                    color: Colors.grey.withOpacity(0.25),
                  ),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(7),
                  boxShadow: [
                    BoxShadow(
                      color: GeneralCtr.MainColor.withOpacity(0.2),
                      blurRadius: 4,
                      offset: Offset(4, 4), // Shadow position
                    ),
                  ],
                ),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    /* 좌 : 태그 + 아이콘 */
                    SizedBox(
                      width: 70,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          /* 1층 아이콘*/
                          Image.asset(
                            "assets/img/icons/tag/${result['tag']}.png",
                            height : 40.0,
                            width  : 40.0,
                          ),
                          /* 사회적 거리두기 */
                          SizedBox(height: 5),
                          /* 2층 태그*/
                          Text("#${result['tag']}", style: TextStyle(fontSize: GeneralCtr.fontsize_normal*0.8))
                        ],
                      ),
                    ),
                    /* 가운데 : 38도선 */
                    VerticalDivider(),
                    /* 우 : 성경구절 */
                    SizedBox(
                      width: MediaQuery.of(context).size.width-135,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          /* 1층 구절 내용 */
                          WordBreakText(
                            "${result[BibleCtr.Bible_choiced]}",
                            wrapAlignment: WrapAlignment.center,// 텍스트 가운데 정렬
                            style: TextStyle(fontSize: GeneralCtr.fontsize_normal),
                            textAlign: TextAlign.center,
                          ),
                          /* 사회적 거리두기 */
                          SizedBox(height: 10),
                          /* 2층 구절 기본정보 */
                          Text(
                            "${result['국문']}(${result['영문']}):${result['cnum']}장 ${result['vnum']}절",
                            style: TextStyle(fontSize: GeneralCtr.fontsize_normal*0.8),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          }
      ),
    );
}