import 'package:bible_in_us/bible/bible_component.dart';
import 'package:bible_in_us/bible/bible_controller.dart';
import 'package:bible_in_us/general/general_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttericon/linearicons_free_icons.dart';
import 'package:fluttericon/typicons_icons.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:get/get.dart';
import 'package:substring_highlight/substring_highlight.dart';


// Gex컨트롤러 객체 초기화
final GeneralCtr = Get.put(GeneralController());
final BibleCtr = Get.put(BibleController());

class BibleSearchScreen extends StatefulWidget {
  const BibleSearchScreen({Key? key}) : super(key: key);

  @override
  _BibleSearchScreenState createState() => _BibleSearchScreenState();
}

class _BibleSearchScreenState extends State<BibleSearchScreen> with TickerProviderStateMixin {

  //자유검색 페이지 탭 컨트롤러 초기화 및 종료
  @override
  void initState() {
    BibleCtr.SearchtabController = TabController(length: 2, vsync: this);
    super.initState();
  }
  @override
  void dispose() {
    BibleCtr.SearchtabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainWidget();
  }
}

// <서브위젯> Main위젯 정의
class MainWidget extends StatelessWidget {
  const MainWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BibleController>(
        init: BibleController(),
        builder: (_){
          return DefaultTabController(
            length: 2,
            child: Scaffold(
                body: NestedScrollView(
                  headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                      // 수직으로 스크롤 가능하도록 설정
                      SliverAppBar(
                        title: Container(
                          child: TextField(
                            controller: BibleCtr.textController, // 텍스트값을 가져오기 위해 컨트롤러 할당
                            /* 키패드에서 "완료"버튼 누르면 이벤트 발동 */
                            onEditingComplete: () {
                              /* 최소 검색글자수 ( 2글자 ) 만족하는지 체크 */
                              if(BibleCtr.textController.text.length>=2){
                                // 0. 질의어 저장하기 //
                                BibleCtr.FreeSearchQuery_update(BibleCtr.textController.text);
                                // 1. 검색결과 받아오기 //
                                BibleCtr.GetFreeSearchList();
                                // 2. 키패드 감추기 //
                                FocusScopeNode currentFocus = FocusScope.of(context);
                                currentFocus.unfocus();
                                // 3. 검색결과(o번)탭으로 이동하기 ( "최근검색" 탭에서도 검색 버튼을 누를 수 있으므로 ! );
                                BibleCtr.SearchtabController.animateTo(0);
                              }else{
                                /* 글자수 모자람 안내창 띄우기 */
                                FlutterDialog(context);
                              }
                            },
                            autofocus: false, // 자동으로 클릭할것인가
                            style: TextStyle(fontSize: 20),
                            decoration: InputDecoration(
                              //prefixIcon: Icon(Icons.search),
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.clear),
                                  /* 클리어 버튼(X) 눌렀을 때 텍스트 비우기 */
                                  onPressed: () {
                                    BibleCtr.textController.clear();
                                    BibleCtr.FreeSearch_init(); // 자유검색결과
                                    },
                                ),
                                hintText: '검색어를 입력해주세요',
                                border: InputBorder.none),
                          ),
                        ),
                        backgroundColor: GeneralCtr.MainColor,
                        floating: true, // 최상단 앱바까지 감출지 여부
                        pinned: false, // 탭까지 모두 감출지 여부
                        snap: true, // 잠깐다시올릴때 앱바 보여주기
                        // 앱바 액숀 버튼
                        actions: [
                          // 셋팅 버튼
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                            child: IconButton(
                              onPressed: () {
                                /* 셋팅화면 띄워주기 */
                                openPopup(context, false);
                              },
                              icon: Icon(Typicons.cog_outline, size: 25.0, color: Colors.black.withOpacity(0.6)),
                            ),
                          )
                        ],
                        // "TabBar"는 기본적으로 Evenly 정렬이므로, 좌측정렬이 안됨. 따라서 PreferredSize를 사용해서 인위적으로 좌측 정렬 시킴
                        bottom: PreferredSize(
                          preferredSize: Size.fromHeight(kToolbarHeight),
                          child: Align(
                            alignment: Alignment.centerLeft, // 탭 메뉴들 왼쪽 정렬
                            child: TabBar(
                              controller: BibleCtr.SearchtabController, // 컨트롤러 정의
                              //labelColor: GeneralCtr.MainColor, // 활성 탭 색
                              labelStyle: TextStyle(fontSize: 17.0), // 활성 탭 스타일
                              unselectedLabelColor: Colors.white54, // 비활성 탭 색
                              unselectedLabelStyle: TextStyle(fontSize: 15.0), // 비활성 탭 스타일
                              indicatorSize: TabBarIndicatorSize.label, // 아래 강조표시 길이
                              indicatorWeight: 3.0, // 아래 강조표시 두께
                              indicatorColor: Colors.white, // 아래 강조표시 색깔
                              isScrollable: true, // 수평으로 스크롤가능여부
                              tabs: [
                                Tab(child: Text("검색결과")),
                                Tab(child: Text('최근검색')),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ];
                  },
                  body: TabBarView(
                    controller: BibleCtr.SearchtabController, // 컨트롤러 정의
                    children: <Widget>[
                      /* 1. 검색결과 보여주기 */
                      FreeSearchResult(),
                      /* 2. 최근검색 히스토리 보여주기 */
                      History(),
                    ],
                  ),
                )),
          ); //return은 필수
        }
    );
  }
}

// <서브위젯> 검색결과 보여주는 위젯
class FreeSearchResult extends StatelessWidget {
  const FreeSearchResult({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return
      GetBuilder<BibleController>(
        init: BibleController(),
        builder: (_){
          return
            Column(
              children: [
                /* 전체 검색 결과 등 결과 요약 표기 */
                Container(
                  child: Text("'${BibleCtr.textController.text}'에 대한 검색결과 ${BibleCtr.FreeSearchResult.length} 건"),
                  margin: EdgeInsets.fromLTRB(0,5,0,0),
                  padding: EdgeInsets.fromLTRB(50,2,50,2),
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: GeneralCtr.MainColor),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                /* 아래는 검색 결과 표기 */
                Flexible(
                  child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Row(
                    children: [
                      /* 1. 성경 권(book) 보여줄 리스트 */
                      Flexible( /* 자유로운 줄바꿈 및 크기 조절을 위해 "Flexible" 위젯 감싸기 */
                        child: Container(
                          child: Scrollbar(
                            controller: BibleCtr.BookCountScroller,// 스크롤 조작이 필요하다면 할당 ㄱㄱ
                            isAlwaysShown: true,   //화면에 항상 스크롤바가 나오도록 한다
                            child: ListView.builder(
                              controller: BibleCtr.BookCountScroller,// 스크롤 조작이 필요하다면 할당 ㄱㄱ
                                itemCount: BibleCtr.FreeSearchResultCount.length,
                                itemBuilder: (context, index) {
                                  var result = BibleCtr.FreeSearchResultCount[index]; // 결과 할당, 이런식으로 변수 선언 가능, 아래 위젯에서 활용 가능
                                  /* 성경 권(book) 리스트를 갯수와 함께 뿌려주기 ㄱㄱ */
                                  return TextButton(
                                    // 텍스트 버튼 쓸데없는 패딩 삭제
                                    style: TextButton.styleFrom(
                                      minimumSize: Size.zero,
                                      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 3.0),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: (){
                                      /* 성경 권(book)이름을 선택하면 해당 권으로 필터링*/
                                      BibleCtr.FreeSearch_book_choice(result['bcode']);
                                    },
                                    // 텍스트 정렬을 위해 "Align" 위젯 씌우기
                                    child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Text("${result['국문']} (${result['count(국문)']})",
                                        /* 선택된 권의 경우 강조해주기, 그렇지 않은 권은 회색처리 */
                                        style: result['bcode'] == BibleCtr.FreeSearchSelected_bcode ?
                                        TextStyle(color: Colors.black, fontSize: 17) : TextStyle(color: Colors.grey, fontSize: 15) ),
                                    ),
                                  );
                                }
                            ),
                          )
                        ),
                      ),
                      VerticalDivider(color: GeneralCtr.MainColor.withOpacity(0.5), indent: 10, endIndent: 10),

                      /* 2. 검색된 성경구절(contents) 보여줄 리스트 */
                      Expanded( /* "Expanded"위젯으로 남은공간을 조정한다 */
                        flex: 3, // 남은 공간을 비율로 조정함
                        child: Container(
                          //color: Colors.indigoAccent,
                          child: Scrollbar(
                            controller: BibleCtr.ContentsScroller,
                            isAlwaysShown: true,   //화면에 항상 스크롤바가 나오도록 한다
                            child: ListView.builder(
                              controller: BibleCtr.ContentsScroller,// 스크롤 조작이 필요하다면 할당 ㄱㄱ
                                itemCount: BibleCtr.FreeSearchResult_filtered.length,
                                itemBuilder: (context, index) {
                                  var result = BibleCtr.FreeSearchResult_filtered[index]; // 결과 할당, 이런식으로 변수 선언 가능, 아래 위젯에서 활용 가능
                                  /* 검색결과 담을 컨테이너 */
                                return GetBuilder<GeneralController>(
                                    init: GeneralController(),
                                    builder: (_) {
                                      return Container(
                                        margin: EdgeInsets.fromLTRB(0, 0, 10, 5),
                                        padding: EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey,
                                            style: BorderStyle.solid,
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.circular(5.0),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                    "${result['국문']} (${result['영문']}): ${result['cnum']}장 ${result['vnum']}절",
                                                    style: TextStyle(
                                                        fontSize: GeneralCtr.Textsize*0.7,
                                                        color: Colors.grey)),
                                                /* 해당구절로 이동할지 물어보는 버튼 삽입 */
                                                IconButton(
                                                  onPressed: () {
                                                    // 1. 팝업창 띄우고 '예'인 경우, 넘어가기 //
                                                    IsMoveDialog(
                                                        context, result, index);
                                                  },
                                                  icon: Icon(
                                                      FontAwesome5
                                                          .arrow_circle_right,
                                                      size: GeneralCtr.Textsize*0.9,
                                                      color: GeneralCtr.MainColor),
                                                  padding: EdgeInsets.zero,
                                                  constraints: BoxConstraints(),
                                                )
                                                // 쓸데없는 패딩 없애기
                                              ],
                                            ),
                                            /* 검색결과에 하이라이트 입히기 */
                                            SubstringHighlight(
                                              text: result[BibleCtr.FreeSearch_Bible_choiced].toString(),
                                              term: BibleCtr.textController.text,
                                              // 강조할 텍스트
                                              textStyle: TextStyle(
                                                color: Colors.black,
                                                fontSize: GeneralCtr.Textsize,
                                                height: GeneralCtr.Textheight,
                                              ),
                                              textStyleHighlight: TextStyle(
                                                // highlight style
                                                color: GeneralCtr.MainColor,
                                                decoration: TextDecoration.none,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          ],
                                        ),
                                      ); // "=>"이 아닌 "{}"을 쓸때는 반드시 return을 써줘야한다!!; //return은 필수
                                    });
                              }
                            ),
                          )
                        ),
                      ),
                    ],
                  ),
          ),
                ),
              ],
            ); //return은 필수
        }
    );
  }
}


// <서브위젯> 최근검색기록 보여주는 위젯 //
class History extends StatelessWidget {
  const History({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /*  GetX 불러오기 */
    return GetBuilder<GeneralController>(
        init: GeneralController(),
        builder: (_){
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              /* 버튼 등 최상단 표기*/
              Padding(padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                child: OutlinedButton(
                  onPressed: (){BibleCtr.FreeSearch_history_remove();},
                  child: Text("기록지우기", style: TextStyle(color: Colors.black),),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: EdgeInsets.fromLTRB(20, 3, 20, 3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    side: BorderSide(width: 1.0, color: GeneralCtr.MainColor),
                  )
                ),
              ),

              /* 히스토리 테이블 */
              Flexible(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Scrollbar(
                    isAlwaysShown: true,   //화면에 항상 스크롤바가 나오도록 한다
                    child: Align(
                      // 가장 최신 히스토리가 위로 올라오도록 "reverse"시킴
                      // 배열이 뒤집혀 아래로 몰릴수 있으므로 "Align"위젯씌워서 "topcenter"로 재정렬
                      alignment: Alignment.topCenter,
                      child: ListView.builder(
                          reverse: true,
                          shrinkWrap: true,
                          itemCount: BibleCtr.FreeSearch_history_query.length,
                          itemBuilder: (context, index) {
                            //var result = FavoriteCtr.FavoriteList[index]; // 결과 할당, 이런식으로 변수 선언 가능, 아래 위젯에서 활용 가능
                            /* 아래부터 검색결과를 하나씩 컨테이너에 담아주기*/
                            return InkWell(
                              onTap: (){BibleCtr.History_click(index);},
                              child: Container(
                                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                color: Colors.transparent,
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        /* 검색결과 내용 표기 */
                                        Icon(Elusive.search, size: GeneralCtr.Textsize*0.9, color: GeneralCtr.MainColor),
                                        Flexible(
                                          child: Text(" ${BibleCtr.FreeSearch_history_query[index]}  ",
                                              style: TextStyle(fontSize: GeneralCtr.Textsize, color: Colors.black)),
                                        ),
                                        Icon(FontAwesome5.bible, size: GeneralCtr.Textsize*0.9, color: Colors.grey),
                                        Text(" ${BibleCtr.FreeSearch_history_bible[index]}",
                                            style: TextStyle(fontSize: GeneralCtr.Textsize*0.85, color: Colors.grey)),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Divider(height: 3,)
                                  ],
                                ),
                              ),
                            ); // "=>"이 아닌 "{}"을 쓸때는 반드시 return을 써줘야한다!!
                          }
                      ),
                    ),
                  )
                ),
              ),
            ],
          ); //return은 필수
        }
    );
  }
}
