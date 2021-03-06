import 'package:bible_in_us/bible/bible_controller.dart';
import 'package:bible_in_us/diary/diary_controller.dart';
import 'package:bible_in_us/diary/diray_view_page.dart';
import 'package:bible_in_us/general/general_controller.dart';
import 'package:bible_in_us/my/my_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final DiaryCtr     = Get.put(DiaryController());
final GeneralCtr   = Get.put(GeneralController());
final BibleCtr     = Get.put(BibleController());
final MyCtr        = Get.put(MyController());

class DiaryViewDetailScreen extends StatelessWidget {
  const DiaryViewDetailScreen({Key? key, this.index, this.IsFilteredData}) : super(key: key);

  final index;
  /* 일반적으로 필터링된 데이터를 사용하지만, 캘린더의 경우 필터링 되지 않은 전체데이터를 활용하므로 구분 짓는다 */
  final IsFilteredData;

  @override
  Widget build(BuildContext context) {
    /* 메인위젯 뿌려주기 with 선택한 일기 index */
    return MainWidget(context, index);
  }
}

/*<서브위젯> 메인위젯 정의 */
Widget MainWidget(context, int index){

  return
  /* 컨트롤러 불러오기 */
    GetBuilder<DiaryController>(
        init: DiaryController(),
        builder: (_){
          /* 선택한 결과 불러오기 */
          var result = DiaryCtr.diary_view_contents[index];

          /* 위젯 시작 */
          return Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(
                  color: GeneralCtr.MainColor
              ),
              backgroundColor: Colors.white,
              elevation: 0.0,
              centerTitle: false,
              title: Text("나만의 일기", style: GeneralCtr.Style_title),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(15, 5, 15, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /* 헤더정보 */
                    ContentsHeader(context, result, index),
                    /* 해시태그 삽입 */
                    HashTagView(result),
                    /* 사회적 거리두기 */
                    SizedBox(height: 10),
                    /* 제목*/
                    SelectableText("${result['dirary_screen_title']}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: GeneralCtr.fontsize_normal*1.1)),
                    /* 성경 구절 보여주기 카드 */
                    ViewVerses(result: result),
                    /* 사회적 거리두기 */
                    SizedBox(height: 10),
                    /* 내용 */
                    SelectableText("${result['dirary_screen_contents']}",  style: TextStyle(fontSize:GeneralCtr.fontsize_normal)),
                    /* 사회적 거리두기 */
                    SizedBox(height: 10),
                    /* 사진보여주기 */
                    ViewPhoto(result: result),
                    /* 사회적 거리두기 */
                    SizedBox(height: 100),
                  ],

                ),
              ),
            ),
          ); //return은 필수
        }
    );
    
}