import 'package:bible_in_us/bible/bible_controller.dart';
import 'package:bible_in_us/general/general_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:word_break_text/word_break_text.dart';

// Gex컨트롤러 객체 초기화
final GeneralCtr = Get.put(GeneralController());
final BibleCtr = Get.put(BibleController());

class BibleMainPage extends StatefulWidget {
  const BibleMainPage({Key? key}) : super(key: key);

  @override
  _BibleMainPageState createState() => _BibleMainPageState();
}

class _BibleMainPageState extends State<BibleMainPage> {
  @override
  Widget build(BuildContext context) {
    return MainWidget(); // 메인 위젯 뿌리기
  }
}

// <서브위젯>메인 위젯 정의
class MainWidget extends StatelessWidget {
  const MainWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return
      GetBuilder<BibleController>(
          init: BibleController(),
          builder: (_){
            return Padding(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // 모달팝업 버튼이 가장 아래로 가도록 정렬
                children: [
                  // 성경이 담길 공간
                  Flexible(
                    // ListView는 Flexible로 감싸 줘야한다.
                    child: ListView.builder(
                      //controller: ,// 스크롤 조작이 필요하다면 할당 ㄱㄱ
                        itemCount: BibleCtr.ContentsList_filtered.length,
                        itemBuilder: (context, index) {
                          // 변수 정의
                          var result = BibleCtr.ContentsList_filtered[index];
                          // 위젯 뿌리기 ㄱㄱ
                          return TextButton(
                            // 버튼에 기본적으로 쓸데없는 패딩(padding)있기 때문에 삭제해준다.
                              style: TextButton.styleFrom(
                                minimumSize: Size.zero,
                                padding: EdgeInsets.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: (){},
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${result['vnum']}) ", style: TextStyle(fontSize: 10, color: Colors.grey),),
                                  Flexible(
                                      child: WordBreakText("${result[BibleCtr.Bible_choiced]}")),
                                ],
                              ));// "=>"이 아닌 "{}"을 쓸때는 반드시 return을 써줘야한다!!
                        }
                    ),
                  ),
                  // 모달창 팝업 버튼
                  TextButton(
                    child: Column(
                      children: [
                        Icon(Entypo.up_open_mini,
                            color: GeneralCtr.BlueColor, size: 30),
                        // 모달창을 위로 올리라는 아이콘
                        Text(
                          "${BibleCtr.Book_choiced} ${BibleCtr.Chapter_choiced} 장",
                          style: TextStyle(color: GeneralCtr.BlueColor, fontSize: 15),
                        ),
                      ],
                    ),
                    onPressed: () {
                      BibleCtr.GetBookList();
                      showCupertinoModalBottomSheet(
                          enableDrag: true, // 아래로 끌어내릴수 있음
                          bounce: false, // 이건잘 모르겠음 ㄷㄷㄷ
                          backgroundColor: Colors.white,
                          closeProgressThreshold: 0.6,
                          duration: Duration(milliseconds: 500), // 모달창이 올라오는 시간
                          expand: false, // 높이와 상관없이 화면 끝까지 늘리는 기능
                          context: context, // 아래부터 모달창에 보여줄 내용
                          builder: (context) => ModalWigdet() // 모달위젯 뿌리기
                      );
                    },
                  ),
                ],
              ),
            ); //return은 필수
          }
      );
  }
}

// <서브위젯>모달 위젯 정의
class ModalWigdet extends StatelessWidget {
  const ModalWigdet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return
      // GetX사용하기
      GetBuilder<BibleController>(
          init: BibleController(),
          builder: (_){
            // 메인위젯 뿌리기
            return Material(
              child: SizedBox(
                height: 600, // 전체 모달창 크기 설정
                child: Column(
                  children: [
                    // 모달창을 아래로 내리라는 아이콘
                    Icon(Entypo.down_open_mini,
                        color: GeneralCtr.BlueColor, size: 30),
                    // 아래부터 성경 선택 스크롤
                    SizedBox(
                      height: 550, // 아이콘을 제외한 나머지 모달창 크기 설정
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // 첫 번째 열은 신약/구약 선택
                          SingleChildScrollView(
                            // 성경 권(book)리스트 뿌려주기
                            child: SizedBox(width: 150, height: 550, // "ListView.builder"는 반드시 사이즈 구속 필요!
                              child: ListView.builder(
                                //controller: ,// 스크롤 조작이 필요하다면 할당 ㄱㄱ
                                  itemCount: BibleCtr.NEWorOLD_list.length,
                                  itemBuilder: (context, index) {
                                    var result = BibleCtr.NEWorOLD_list[index]; // 결과 할당, 이런식으로 변수 선언 가능, 아래 위젯에서 활용 가능
                                    return TextButton(
                                        onPressed: (){BibleCtr.NEWorOLD_choice(result);},
                                        child: Text(
                                            "${result}",
                                            style: result == BibleCtr.NEWorOLD_choiced ? GeneralCtr.TextStyle_normal_accent : GeneralCtr.TextStyle_normal_disable,
                                            textAlign: TextAlign.left)
                                    );
                                  }
                              ),
                            ),
                          ),
                          VerticalDivider(color: Colors.black, thickness: 0.1),
                          // 두 번째 열은 권(book)선택
                          SingleChildScrollView(
                            // 성경 권(book)리스트 뿌려주기
                            child: SizedBox(width: 150, height: 550, // "ListView.builder"는 반드시 사이즈 구속 필요!
                              child: ListView.builder(
                                //controller: ,// 스크롤 조작이 필요하다면 할당 ㄱㄱ
                                  itemCount: BibleCtr.BookList_filtered.length,
                                  itemBuilder: (context, index) {
                                    var result = BibleCtr.BookList_filtered[index]; // 결과 할당, 이런식으로 변수 선언 가능, 아래 위젯에서 활용 가능
                                    return TextButton(
                                        onPressed: (){BibleCtr.Book_choice(result['국문']);},
                                        child: Text(
                                            "${result['국문']}",
                                            style: result['국문'] == BibleCtr.Book_choiced ? GeneralCtr.TextStyle_normal_accent : GeneralCtr.TextStyle_normal_disable)
                                    );
                                  }
                              ),
                            ),
                          ),
                          VerticalDivider(color: Colors.black, thickness: 0.1),
                          // 세 번째 열은 장(chapter)선택
                          SingleChildScrollView(
                            // 성경 권(book)리스트 뿌려주기
                            child: SizedBox(width: 150, height: 550, // "ListView.builder"는 반드시 사이즈 구속 필요!
                              child: ListView.builder(
                                //controller: ,// 스크롤 조작이 필요하다면 할당 ㄱㄱ
                                  itemCount: BibleCtr.ChapterList_filtered.length,
                                  itemBuilder: (context, index) {
                                    var result = BibleCtr.ChapterList_filtered[index]; // 결과 할당, 이런식으로 변수 선언 가능, 아래 위젯에서 활용 가능
                                    return TextButton(
                                        onPressed: (){BibleCtr.Chapternumber_choice(result['cnum']);},
                                        child: Text(
                                            "${result['cnum']} 장",
                                            style: result['cnum'] == BibleCtr.Chapter_choiced ? GeneralCtr.TextStyle_normal_accent : GeneralCtr.TextStyle_normal_disable)
                                    );
                                  }
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );;
          }
      );
  }
}


