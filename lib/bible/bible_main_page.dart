import 'package:bible_in_us/bible/bible_component.dart';
import 'package:bible_in_us/bible/bible_controller.dart';
import 'package:bible_in_us/general/general_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';

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
            var IsClicked; // 클릭한 구절인지 결과 담을 공간
            // 성경에 뿌려질 내용 한번에 이어서 보여주기
            var result = BibleCtr.ContentsList_filtered;// 변수 정의
            // 이거 대박, 성경 구절을 위젯화해서 뿌려주기 ( https://stackoverflow.com/questions/55839275/flutter-changing-textstyle-of-textspan-with-tapgesturerecognizer)
            final spans = <TextSpan>[]; // 텍스트를 담을 빈공간, 아래에서 RichText에 뿌려준다.
            // 모든 구절을 순환하면서,
            for (int i = 0; i <= BibleCtr.ContentsList_filtered.length-1; i++){
              // 클릭된 구절인지 확인
              if(BibleCtr.ContentsIdList_clicked.contains(result[i]['_id'])){
                IsClicked = true;
              }else{
                IsClicked = false;
              }
              spans.add( // 절(verse)번호 붙이기
                  TextSpan(
                      text : result[i]['vnum'].toString() + " ",
                      style : TextStyle(
                          color: Colors.grey.withOpacity(0.8),
                          fontSize: GeneralCtr.Textsize*0.7
                      )
                  )
              );
              spans.add( // 구절(content)붙이기
                  TextSpan(
                    text : result[i][BibleCtr.Bible_choiced].toString() + " ",
                    // 선택한 텍스트는 강조해주기
                    style: TextStyle(
                      // 선택된 컬러 코드 인덱스에 따라서 색 부여 단, 0번일 경우 색 없음처리
                      backgroundColor: result[i]['highlight_color_index'] == 0 ? Colors.transparent : BibleCtr.ColorCode[result[i]['highlight_color_index']],
                      fontSize: GeneralCtr.Textsize,
                      height: GeneralCtr.Textheight,
                      decoration: IsClicked == true ? TextDecoration.underline : null,
                      decorationStyle: TextDecorationStyle.dashed, // .underline .dotted. dashed .double .wavy
                      decorationColor: Colors.purpleAccent,
                      decorationThickness: 5,
                      color: IsClicked == true ? Colors.black : Colors.black
                    ),
                    /* 구절(텍스트)을 눌렀을 때 이벤트 정의 */
                    recognizer : TapGestureRecognizer()..onTap = () {
                      /* 클릭한 컨텐츠 아이디 저장 */
                      BibleCtr.ContentsList_click(result[i]['_id']);
                    },
                  )
              );
            }

            // 위젯 뿌리기
            return Padding(
              padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // 모달팝업 버튼이 가장 아래로 가도록 정렬
                children: [
                  // 성경이 담길 공간
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          /* [제목]성경 정&절(bible, chapter) 뿌려주기 */
                          Text("${BibleCtr.Book_choiced}\n${BibleCtr.Chapter_choiced}장",
                            style: TextStyle(fontSize: GeneralCtr.Textsize+10), textAlign: TextAlign.center,),
                          // 엄청난 공간
                          SizedBox(height: 30),
                          /* [성경내용(contents)]뿌려주기 */
                          RichText(text: TextSpan(children: spans)),
                          // 엄청난 공간
                          SizedBox(height: 300), // 모달창 높이만큼 띄워준다 ㄱㄱ
                        ],
                      ),
                    )// 위에서 연결한 구절 뿌려주기
                  ),
                  // 페이지 하단 버튼( 이전페이지  / 모달팝업 / 다음페이지 )
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 이전페이지
                      IconButton(icon: Icon(Elusive.left_open, color: GeneralCtr.BlueColor),
                          onPressed: (){BibleCtr.Page_change('previous');}),
                      // 모달팝업
                      TextButton(
                        child: Column(
                          children: [
                            Icon(Entypo.up_open_mini,
                                color: GeneralCtr.BlueColor, size: 30),
                            // 모달창을 위로 올리라는 아이콘
                            Text(
                              "${BibleCtr.Book_choiced} ${BibleCtr.Chapter_choiced} 장",
                              style: TextStyle(color: GeneralCtr.BlueColor, fontSize: GeneralCtr.Textsize),
                            ),
                          ],
                        ),
                        onPressed: () {
                          /* 모달창 옵션 */
                          showCupertinoModalBottomSheet( // 모달창 옵션
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
                      // 다음페이지
                      IconButton(icon: Icon(Elusive.right_open, color: GeneralCtr.BlueColor),
                          onPressed: (){BibleCtr.Page_change('next');}),
                    ],
                  ),
                ],
              ),
            ); //return은 필수
          }
      );
  }
}

// <서브위젯_모달>모달 위젯 정의
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
                height: 500, // 전체 모달창 크기 설정
                child: Column(
                  children: [
                    // 모달창을 아래로 내리라는 아이콘
                    Icon(Entypo.down_open_mini,
                        color: GeneralCtr.BlueColor, size: 30),





                    /* 모달창 최상단 성경 권(book) 검색창 */
                    TextField(
                      onChanged: (keyword){
                        /* 검색어를 입력 했을 때 액션 정의 */
                        BibleCtr.Search_book(keyword);
                      },
                      controller: BibleCtr.ModaltextController, // 텍스트값을 가져오기 위해 컨트롤러 할당
                      autofocus: false, // 자동으로 클릭할것인가
                      style: TextStyle(fontSize: GeneralCtr.Textsize),
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              /* 클리어 버튼(X) 눌렀을 때 텍스트 비우기 */
                              BibleCtr.ModaltextController.clear();
                              BibleCtr.NEWorOLD_choice(BibleCtr.NEWorOLD_choiced);// 원래 조건으로 재검색
                            },
                          ),
                          hintText: '검색어를 입력해주세요',
                          hintStyle: GeneralCtr.TextStyle_normal_disable,
                          border: InputBorder.none),
                    ),







                    // 사회적 위젯 거리두기
                    Divider(indent: 10, endIndent: 10),


                    // 아래부터 성경 선택 스크롤
                    SizedBox(
                      height: 400, // 아이콘을 제외한 나머지 모달창 크기 설정
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // 첫 번째 열은 신약/구약 선택
                          SingleChildScrollView(
                            // 성경 권(book)리스트 뿌려주기
                            child: SizedBox(width: 50, height: 400, // "ListView.builder"는 반드시 사이즈 구속 필요!
                              child: ListView.builder(
                                //controller: ,// 스크롤 조작이 필요하다면 할당 ㄱㄱ
                                  itemCount: BibleCtr.NEWorOLD_list.length,
                                  itemBuilder: (context, index) {
                                    var result = BibleCtr.NEWorOLD_list[index]; // 결과 할당, 이런식으로 변수 선언 가능, 아래 위젯에서 활용 가능
                                    return TextButton(
                                      /* 쓸데없는 패딩 없애주기 */
                                        style: TextButton.styleFrom(
                                          minimumSize: Size.zero,
                                          padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
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
                          Scrollbar(
                            controller: BibleCtr.BookScroller, // 아래 스크롤러랑 반드시 동일
                            isAlwaysShown: false,   //화면에 항상 스크롤바가 나오도록 한다
                            // 성경 권(book)리스트 뿌려주기
                            child: SizedBox(width: 150, height: 400, // "ListView.builder"는 반드시 사이즈 구속 필요!
                              child: ListView.builder(
                                  controller: BibleCtr.BookScroller,// 위에 스크롤러랑 반드시 동일
                                  itemCount: BibleCtr.BookList_filtered.length,
                                  itemBuilder: (context, index) {
                                    var result = BibleCtr.BookList_filtered[index]; // 결과 할당, 이런식으로 변수 선언 가능, 아래 위젯에서 활용 가능
                                    return TextButton(
                                      /* 쓸데없는 패딩 없애주기 */
                                        style: TextButton.styleFrom(
                                          minimumSize: Size.zero,
                                          padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
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
                          Scrollbar(
                            controller: BibleCtr.ChapterScroller, // 아래 스크롤러랑 반드시 동일
                            isAlwaysShown: false,   //화면에 항상 스크롤바가 나오도록 한다
                            // 성경 권(book)리스트 뿌려주기
                            child: SizedBox(width: 60, height: 400, // "ListView.builder"는 반드시 사이즈 구속 필요!
                              child: ListView.builder(
                                  controller: BibleCtr.ChapterScroller,// 위에 스크롤러랑 반드시 동일
                                  itemCount: BibleCtr.ChapterList_filtered.length,
                                  itemBuilder: (context, index) {
                                    var result = BibleCtr.ChapterList_filtered[index]; // 결과 할당, 이런식으로 변수 선언 가능, 아래 위젯에서 활용 가능
                                    return TextButton(
                                      /* 쓸데없는 패딩 없애주기 */
                                        style: TextButton.styleFrom(
                                          minimumSize: Size.zero,
                                          padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
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
            );
          }
      );
  }
}
