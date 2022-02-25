import 'package:bible_in_us/bible/bible_component.dart';
import 'package:bible_in_us/bible/bible_controller.dart';
import 'package:bible_in_us/general/general_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/modern_pictograms_icons.dart';
import 'package:fluttericon/typicons_icons.dart';
import 'package:fluttericon/web_symbols_icons.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
              appBar: AppBar(
                iconTheme: IconThemeData(
                  color: GeneralCtr.MainColor, //change your color here
                ),
                elevation: 1.5,
                title: TextField(
                  textAlignVertical: TextAlignVertical.center,
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
                  style: TextStyle(fontSize: GeneralCtr.fontsize_normal),
                  decoration: InputDecoration(
                    //prefixIcon: Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear, color: GeneralCtr.MainColor),
                        /* 클리어 버튼(X) 눌렀을 때 텍스트 비우기 */
                        onPressed: () {
                          BibleCtr.textController.clear();
                          BibleCtr.FreeSearch_init(); // 자유검색결과
                        },
                      ),
                      hintText: '검색어를 입력해주세요',
                      border: InputBorder.none),
                ),
                backgroundColor: Colors.white,
                // 앱바 액숀 버튼
                actions: [
                  // 셋팅 버튼
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child: IconButton(
                      onPressed: () {
                        /* 셋팅화면 띄워주기 */
                        openPopup(context);
                      },
                      icon: Icon(Typicons.cog_outline, size: 25.0, color: GeneralCtr.MainColor),
                    ),
                  )
                ],
                // "TabBar"는 기본적으로 Evenly 정렬이므로, 좌측정렬이 안됨. 따라서 PreferredSize를 사용해서 인위적으로 좌측 정렬 시킴
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(30),
                  child: Align(
                    alignment: Alignment.centerLeft, // 탭 메뉴들 왼쪽 정렬
                    child: TabBar(
                      padding: EdgeInsets.zero,
                      controller: BibleCtr.SearchtabController, // 컨트롤러 정의
                      //labelColor: GeneralCtr.MainColor, // 활성 탭 색
                      //labelStyle: TextStyle(fontSize: 17.0), // 활성 탭 스타일
                      //unselectedLabelStyle: TextStyle(fontSize: 15.0), // 비활성 탭 스타일
                      unselectedLabelColor: Colors.white54, // 비활성 탭 색
                      indicatorSize: TabBarIndicatorSize.label, // 아래 강조표시 길이
                      indicatorWeight: 3.0, // 아래 강조표시 두께
                      indicatorColor: GeneralCtr.MainColor, // 아래 강조표시 색깔
                      isScrollable: true, // 수평으로 스크롤가능여부
                      tabs: [
                        Tab(child: Text("검색결과", style: TextStyle(fontSize: GeneralCtr.fontsize_normal))),
                        Tab(child: Text('최근검색', style: TextStyle(fontSize: GeneralCtr.fontsize_normal))),
                      ],
                    ),
                  ),
                ),
              ),

              body: TabBarView(
                controller: BibleCtr.SearchtabController, // 컨트롤러 정의
                children: [
                  /* 1. 검색결과 보여주기 */
                  FreeSearchResult(),
                  /* 2. 최근검색 히스토리 보여주기 */
                  History(),
                ],
              ),
            ),
          ); //return은 필수
        });
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
                  child: Text(
                    '검색어 : "${BibleCtr.textController.text}" 에 대한 검색결과 ${NumberFormat('##,###').format(BibleCtr.FreeSearchResult.length)} 건',
                    style: TextStyle(fontSize: GeneralCtr.fontsize_normal*0.9),),
                  margin: EdgeInsets.fromLTRB(0,5,0,5),
                  padding: EdgeInsets.fromLTRB(50,2,50,2),
                  decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
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
                        flex: 6, // 남은 공간을 비율로 조정함
                        child: Scrollbar(
                          controller: BibleCtr.BookCountScroller,// 스크롤 조작이 필요하다면 할당 ㄱㄱ
                          isAlwaysShown: false,   //화면에 항상 스크롤바가 나오도록 한다
                          child: ListView.builder(
                            controller: BibleCtr.BookCountScroller,// 스크롤 조작이 필요하다면 할당 ㄱㄱ
                              itemCount: BibleCtr.FreeSearchResultCount.length,
                              itemBuilder: (context, index) {
                                var result = BibleCtr.FreeSearchResultCount[index]; // 결과 할당, 이런식으로 변수 선언 가능, 아래 위젯에서 활용 가능
                                /* 성경 권(book) 리스트를 갯수와 함께 뿌려주기 ㄱㄱ */
                                return Column(
                                  children: [
                                    TextButton(
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
                                        child: Text("${result['국문']}(${result['count(국문)']})",
                                            /* 선택된 권의 경우 강조해주기, 그렇지 않은 권은 회색처리 */
                                            style: result['bcode'] == BibleCtr.FreeSearchSelected_bcode ?
                                            GeneralCtr.TextStyle_normal_accent : GeneralCtr.TextStyle_normal_disable ),
                                      ),
                                    ),
                                    /* 리스트간 사히적 거리두기 */
                                    SizedBox(height: 5)
                                  ],
                                );
                              }
                          ),
                        ),
                      ),
                      VerticalDivider(color: GeneralCtr.MainColor.withOpacity(0.5), indent: 10, endIndent: 10),


                      /* 2. 성경 장(chapter) 보여줄 리스트 */
                      Flexible( /* 자유로운 줄바꿈 및 크기 조절을 위해 "Flexible" 위젯 감싸기 */
                        flex: 2, // 남은 공간을 비율로 조정함
                        child: Scrollbar(
                          controller: BibleCtr.BookCountScroller,// 스크롤 조작이 필요하다면 할당 ㄱㄱ
                          isAlwaysShown: false,   //화면에 항상 스크롤바가 나오도록 한다
                          child: ListView.builder(
                              controller: BibleCtr.BookCountScroller,// 스크롤 조작이 필요하다면 할당 ㄱㄱ
                              itemCount: BibleCtr.FreeSearchResultCount_cnum.length,
                              itemBuilder: (context, index) {
                                var result = BibleCtr.FreeSearchResultCount_cnum[index]; // 결과 할당, 이런식으로 변수 선언 가능, 아래 위젯에서 활용 가능
                                /* 성경 권(book) 리스트를 갯수와 함께 뿌려주기 ㄱㄱ */
                                return Column(
                                  children: [
                                    TextButton(
                                      // 텍스트 버튼 쓸데없는 패딩 삭제
                                      style: TextButton.styleFrom(
                                        minimumSize: Size.zero,
                                        padding: EdgeInsets.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      onPressed: (){
                                        /* 성경 챕터(cnum)이름을 선택하면 해당 권으로 필터링*/
                                        BibleCtr.FreeSearch_cnum_choice(result['cnum']);
                                      },
                                      // 텍스트 정렬을 위해 "Align" 위젯 씌우기
                                      child: Align(
                                        alignment: Alignment.topCenter,
                                        child: Text("${result['cnum']}장",// Text("${result['cnum']}장(${result['count']})",
                                            /* 선택된 챕터의 경우 강조해주기, 그렇지 않은 권은 회색처리 */
                                            style: result['cnum'] == BibleCtr.FreeSearchSelected_cnum ?
                                            GeneralCtr.TextStyle_normal_accent : GeneralCtr.TextStyle_normal_disable ),
                                      ),
                                    ),
                                    /* 리스트간 사히적 거리두기 */
                                    SizedBox(height: 5)
                                  ],
                                );
                              }
                          ),
                        ),
                      ),
                      VerticalDivider(color: GeneralCtr.MainColor.withOpacity(0.5), indent: 10, endIndent: 10),


                      /* 3. 검색된 성경구절(contents) 보여줄 리스트 */
                      Expanded( /* "Expanded"위젯으로 남은공간을 조정한다 */
                        flex: 13, // 남은 공간을 비율로 조정함
                        child: Scrollbar(
                          controller: BibleCtr.ContentsScroller,
                          isAlwaysShown: false,   //화면에 항상 스크롤바가 나오도록 한다
                          child: ListView.builder(
                              shrinkWrap: false,
                              controller: BibleCtr.ContentsScroller,// 스크롤 조작이 필요하다면 할당 ㄱㄱ
                              itemCount: BibleCtr.FreeSearchResult_filtered.length,
                              itemBuilder: (context, index) {
                                var result = BibleCtr.FreeSearchResult_filtered[index]; // 결과 할당, 이런식으로 변수 선언 가능, 아래 위젯에서 활용 가능
                                /* 검색결과 담을 컨테이너 */
                              return GetBuilder<GeneralController>(
                                  init: GeneralController(),
                                  builder: (_) {
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
                                            /* 구절 정보 보여주기 */
                                            Text(
                                                "${result['국문']} (${result['영문']})  ${result['cnum']}:${result['vnum']}",
                                                style: TextStyle(
                                                    fontSize: GeneralCtr.fontsize_normal,
                                                    color: Colors.grey)),

                                            /* 사회적 거리두기*/
                                            SizedBox(height: 2),

                                            /* 구절 내용 보여주기 */
                                            SubstringHighlight(
                                              // 일반 텍스트
                                              text: result[BibleCtr.Bible_choiced].toString(),
                                              // 강조 텍스트
                                              term: BibleCtr.textController.text,
                                              // 일반 텍스트 스타일
                                              textStyle: TextStyle(
                                                fontFamily: DefaultTextStyle.of(context).style.fontFamily,
                                                color: Colors.black,
                                                fontSize: GeneralCtr.Textsize,
                                                height: GeneralCtr.Textheight,
                                              ),
                                              // 강조 텍스트 스타일
                                              textStyleHighlight: TextStyle(
                                                // highlight style
                                                fontFamily: DefaultTextStyle.of(context).style.fontFamily,
                                                color: GeneralCtr.MainColor,
                                                decoration: TextDecoration.none,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ); // "=>"이 아닌 "{}"을 쓸때는 반드시 return을 써줘야한다!!; //return은 필수
                                  });
                            }
                          ),
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
          return Padding(
            padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
            child: Scrollbar(
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
                        /* 히스토리를 클릭 했을 때 이벤트 정의 */
                        onTap: (){
                          /* 찾기 페이지로 넘어가기 */
                          BibleCtr.History_click(index)
                          ;},
                        child: Container(
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          color: Colors.transparent,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  /* 검색결과 내용 표기 */
                                  Flexible(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Icon(Elusive.search, size: GeneralCtr.fontsize_normal*0.9, color: GeneralCtr.MainColor),
                                        Flexible(
                                          child: Text("   ${BibleCtr.FreeSearch_history_query[index]}    ",
                                              style: TextStyle(fontSize: GeneralCtr.fontsize_normal, color: Colors.black)),
                                        ),
                                        Icon(FontAwesome5.bible, size: GeneralCtr.fontsize_normal*0.9, color: Colors.grey.withOpacity(0.8)),
                                        Text(" ${BibleCtr.FreeSearch_history_bible[index]}",
                                            style: TextStyle(fontSize: GeneralCtr.fontsize_normal*0.85, color: Colors.grey.withOpacity(0.8))),
                                      ],
                                    ),
                                  ),
                                  /* 옵션 버튼 */
                                  PopupMenuButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                    padding: EdgeInsets.zero,

                                    tooltip: "추가기능",
                                    color: Colors.white, // pop메뉴 배경색
                                    elevation: 10,// pop메뉴 그림자
                                    onSelected: (value) {
                                      /* 각 버튼에 따른 액션 정의 */
                                      switch(value){
                                      /* 1. [편집] 버튼 클릭 */
                                        case "삭제" :
                                          BibleCtr.FreeSearch_history_remove_one(index); // 1개만 삭제
                                          break;
                                      /* 2. [삭제] 버튼 클릭 */
                                        case "전체 삭제" :
                                          BibleCtr.FreeSearch_history_remove_all(); // 전체 삭제
                                          break;
                                      }
                                    },
                                    icon: Icon(Icons.more_vert_sharp, size: GeneralCtr.fontsize_normal*1.2), // pop메뉴 아이콘
                                    /* 하위 메뉴 스타일 */
                                    itemBuilder: (context) => [
                                      PopupMenuItem(child: Row(children: [Icon(FontAwesome.trash_empty, size: GeneralCtr.fontsize_normal*0.9), Text(" 삭제", style: TextStyle(fontSize: GeneralCtr.fontsize_normal*0.9))]), value: "삭제"),
                                      PopupMenuItem(child: Row(children: [Icon(WebSymbols.cancel_circle, size: GeneralCtr.fontsize_normal*0.9), Text(" 전체 삭제", style: TextStyle(fontSize: GeneralCtr.fontsize_normal*0.9))]), value: "전체 삭제"),
                                    ]
                                  )
                                ],
                              ),
                              SizedBox(height: 5),
                              Divider(height: 3,)
                            ],
                          ),
                        ),
                      );
                    }
                ),
              ),
            )
          );
        }
    );
  }
}
