import 'package:bible_in_us/bible/bible_component.dart';
import 'package:bible_in_us/bible/bible_repository.dart';
import 'package:bible_in_us/general/general_controller.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:convert';

// Gex컨트롤러 객체 초기화
final GeneralCtr = Get.put(GeneralController());

class BibleController extends GetxController {

  /* <함수> 초기화 함수 */
  void init (){
    GetBookList(); // 성경 리스트는 초반 한번만 받아오면 되므로 init에서 처리한다.
    GetVersesDummy(); // 초반 다음 페이지 정보를 확인하기 위한 더미 데이터 get
    NEWorOLD_choice(NEWorOLD_choiced);  //초반 권(book)불러오기
    Book_choice(Book_choiced); // 초반 챕터번호 선택해놓기
    FloatingAB_init(); // 플로팅 액션버튼 초기화
    Get_color_count(); // 색깔별 즐겨찾기 몇개인지 쿼리
  }

  /* SharedPrefs 저장하기(save) */
  Future<void> SavePrefsData() async {
    //1. 객체 불러오기
    final prefs = await SharedPreferences.getInstance();
    //2. 상태값 저장할 목록 및 저장 수행
    prefs.setString('Book_choiced', Book_choiced);
    prefs.setString('NEWorOLD_choiced', NEWorOLD_choiced);
    prefs.setInt('BookCode_choiced', BookCode_choiced);
    prefs.setInt('Chapter_choiced', Chapter_choiced);
    prefs.setString('Bible_choiced', Bible_choiced);
    prefs.setStringList('FreeSearch_history_bible', FreeSearch_history_bible);
    prefs.setStringList('FreeSearch_history_query', FreeSearch_history_query);

  }

  /* SharedPrefs 불러오기(load) */
  Future<void> LoadPrefsData() async {

    //1. 객체 불러오기
    final prefs = await SharedPreferences.getInstance();
    //2. 불러올 상태값 목록 및 데이터 업데이트
    Book_choiced              = prefs.getString('Book_choiced') == null ? Book_choiced : prefs.getString('Book_choiced')!;
    NEWorOLD_choiced          = prefs.getString('NEWorOLD_choiced') == null ? NEWorOLD_choiced : prefs.getString('NEWorOLD_choiced')!;
    BookCode_choiced          = prefs.getInt('BookCode_choiced') == null ? BookCode_choiced : prefs.getInt('BookCode_choiced')!;
    Chapter_choiced           = prefs.getInt('Chapter_choiced') == null ? Chapter_choiced : prefs.getInt('Chapter_choiced')!;
    Bible_choiced             = prefs.getString('Bible_choiced') == null ? Bible_choiced : prefs.getString('Bible_choiced')!;
    FreeSearch_history_bible  = prefs.getStringList('FreeSearch_history_bible') == null ? FreeSearch_history_bible : prefs.getStringList('FreeSearch_history_bible')!;
    FreeSearch_history_query  = prefs.getStringList('FreeSearch_history_query') == null ? FreeSearch_history_query : prefs.getStringList('FreeSearch_history_query')!;
    update(); // 상태업데이트 내용이 반영되어 로딩이 끝났음을 알려줘야함 ㄱㄱ
  }

  /* <변수> 각종 변수 정의  */
  late TabController tabController; // 메인페이지 탭 컨트롤러 정의
  late TabController SearchtabController; // 자유검색페이지 탭 컨트롤러 정의

  /* 메인페이지 성경 스크롤 컨트롤러 정의 */
  final ScrollController BibleScroller    = ScrollController(keepScrollOffset: true); // 모달창 스크롤 컨트롤러 선언

  /* 메인 페이지 모달창 스크롤 컨트롤러 정의 */
  final ScrollController BookScroller    = ScrollController(keepScrollOffset: true); // 모달창 스크롤 컨트롤러 선언
  final ScrollController ChapterScroller = ScrollController(keepScrollOffset: true); // 모달창 스크롤 컨트롤러 선언

  /* 자유 검색 스크린 결과 스크롤 조정을 위한 컨트롤러 정의 */
  final ScrollController BookCountScroller  = ScrollController(keepScrollOffset: true);
  final ScrollController ContentsScroller   = ScrollController(keepScrollOffset: true);

  /* 텍스트컨트롤러 정의 */
  var ModaltextController = TextEditingController(); // 메인 모달 검색어 컨트롤러
  var textController      = TextEditingController(); // 자유 검색 스크린 검색창
  var MemotextController  = TextEditingController(); // 메모 팝업 메모내용 컨트롤러
  var MemoErrorText       = null; // 메모 팝업 글자 수 모자람 에러 텍스트 저장

  /* 메인페이지 플로팅액션버튼 컨트롤러 정의 */
  final GlobalKey<FabCircularMenuState> fabKey = GlobalKey();


  var NEWorOLD_list           = ["구약","신약"]; // "구약" or "신약" 선택
  var NEWorOLD_choiced        = "구약"; //"구약" or "신약" 선택 인덱스
  var BookList                = []; // 권(book)리스트
  var BookList_filtered       = []; // "구약 or 신약" 등 필터링 된 성경 리스트
  var Book_choiced            = "창세기"; //"구약" or "신약" 선택 인덱스
  var BookCode_choiced        = 1; // 권 (book) 코드

  var ChapterList_filtered    = []; // 권에 맞는 챕터 리스트 불러오기
  var Chapter_choiced         = 1; //"구약" or "신약" 선택 인덱스
  var Bible_list              = ['개역개정', '개역한글판_국한문','쉬운성경','현대어성경', '현대인의성경', 'KJV', 'NIV', 'ASV'];
  var Bible_choiced           = '개역개정';
  var ContentsList_filtered   = []; // 선택된 구절
  var ContentsIdList_clicked  = []; // 사람이 클릭한 구절 담기
  var ContentsDataList_clicked = []; // 사람이 클릭한 구절 정보 DB에서 조회해서 담기
  var spans                   = <TextSpan>[]; // 성경구절 텍스트를 담을 빈공간, 아래에서 RichText에 뿌려준다.
  var VersesDummy             = []; // 다음 페이지 정보를 확인하기 위한 더미 데이터 생성
  var FreeSearchQuery         =""; // 자유검색 쿼리문 저장
  var FreeSearchResult        = []; // 자유검색결과를 담을 공간
  var FreeSearchResult_filtered = []; // 자유검색결과 필터링된 결과
  var FreeSearchResultCount   = []; // 자유검색결과 각 권마다 몇개가 있는지 담을 공간
  var FreeSearchSelected_bcode = 1; // 자유검색결과 선택된 북코드
  var FreeSearchResultCount_cnum   = []; // 자유검색결과 각 챕터마다 몇개가 있는지 담을 공간
  var FreeSearchSelected_cnum  = 1; // 자유검색결과 선택된 챕터번호
  List<String> FreeSearch_history_bible  = []; // 최근검색 성경이름
  List<String> FreeSearch_history_query  = []; // 최근검색 쿼리문

  var from_which_app = ""; // 어떤 앱(app)에서 호출했는지 분류하기위한 변수

  var FAB_opacity = 0.0; // 메인페이지 플로팅액션버튼 투명도

  var ColorCode = [Color(0xFFBFBFBF), // 젤 처음은 흑백 칼라
    Color(0xFFffd700).withOpacity(0.8),
    Color(0xFF00bfff).withOpacity(0.8),
    Color(0xFF32cd32).withOpacity(0.8),
    Color(0xff9966ff).withOpacity(0.8),
    Color(0xFFF781D8).withOpacity(0.8),
  ]; // 플로팅 액션버튼 -> 즐겨찾기 색깔표
  var ColorCode_choiced_index = 0; // 플로팅 액션버튼 -> 선택된 즐겨찾기 색깔표

  var Favorite_choiced_color_list = []; // 즐겨찾기 페이지 _  선택된 칼라코드 인덱스
  var Favorite_list = []; // 즐겨찾기 페이지 _ 조건에 맞는 즐겨찾기 불러오기
  var Favorite_Color_count = []; // 즐겨찾기 페이지 _ 색깔별 갯수 담기
  var Favorite_timediffer_list = []; // 즐겨찾기 페이지 _ 시간산출결고 담기
  
  var Memo_list = []; // 메모 페이지 _ DB에서 불러온 메모 내용 저장
  var Memo_verses_list = []; // 메모 페이지 _ 메모와 관련있는 구절 불러오기
  var Memo_timediffer_list = []; // 메모 페이지 _ 시간산출결고 담기


  //<함수>성경(book)리스트 받아오기
  Future<void> GetBookList() async {
    BookList = await BibleRepository.GetBookList();
    update();
  }

  //<함수>"구약" or "신약" 선택
  void NEWorOLD_choice(String value){
    // 조건 업데이트
    NEWorOLD_choiced = value;
    // 검색창 텍스트 초기화
    ModaltextController.text = "";
    // 조건에 맞는 성경 권(book)가져오기
    switch (value) {
      case "구약" :
        BookList_filtered = BookList.where((f) => f['type'] == 'old').toList(); // 구약으로 필터링
        Book_choiced ="창세기"; // 초기선택값 부여
        break;
      case "신약" :
        BookList_filtered = BookList.where((f) => f['type'] == 'new').toList(); // 신약으로 필터링
        Book_choiced ="마태복음"; // 초기선택값 부여
        break;
    }
    update();
  }
  //<함수> 메인페이지 _ 모달 검색창에서 성경 권(book) 자유 검색
  void Search_book(keyword){
    BookList_filtered = BookList.where((f) => f['국문'].contains(keyword)).toList();
    update();
  }


  // <함수> 성경 권(book) 선택
  Future<void> Book_choice(String value) async {
    // 조건 업데이트
    Book_choiced = value;
    Chapter_choiced = 1; // 권이 변경되었으므로, 챕터 1장으로 초기화
    // 조건에 맞는 권(book)의 bcode 가져오기
    if(BookList_filtered.length>0){
      BookCode_choiced = BookList_filtered.where((f) => f['국문'] == value).toList()[0]['bcode'];
    }else{
      BookCode_choiced = 1;
    }
    // 조건에 맞는 챕터 번호 리스트 받아오기
    ChapterList_filtered = await BibleRepository.GetChapterNumberList(BookCode_choiced);
    // 조건에 맞는 구절(contents)가져오기
    Getcontents();
    update();
  }

  // <함수> 챕터번호(cnum) 선택
  void Chapternumber_choice(cnum){
    // 조건 업데이트
    Chapter_choiced = cnum;
    // 조건에 맞는 구절(contents)가져오기
    Getcontents();
    update();
    SavePrefsData(); //현재 설정값 저장
  }

  // <함수> 조건에 맞는 성경 구절 가져오기
  Future<void> Getcontents() async {
    // 로딩화면 띄우기
    EasyLoading.show(status: 'loading...');
    // 조건에 맞는 챕터 번호 리스트 받아오기
    ContentsList_filtered = await BibleRepository.Getcontents(BookCode_choiced, Chapter_choiced, Bible_choiced);
    update();
    SavePrefsData(); //현재 설정값 저장

    // 플로팅 액션버튼 초기화
    FloatingAB_init();

    // 로딩화면 종료
    EasyLoading.dismiss();
  }

  // <함수> 플로팅 액션버튼 초기화
  void FloatingAB_init(){
    ContentsIdList_clicked = [];// 선택한 구절 초기화
    fabKey.currentState?.close();
    Change_FAB_opacity(0.0); // 플로팅 액션버튼 숨기기
  }

  // <함수> 성경구절 손으로 클릭
  void ContentsList_click(_id){
    // 1. 클릭한 구절의 _id값이  있는지 확인
    if (ContentsIdList_clicked.contains(_id)){
      ContentsIdList_clicked.remove(_id);//1. 이미 클릭한 구절인 경우, 리스트에서 제외
    }else{
      ContentsIdList_clicked.add(_id);//2. 클릭하지 않은 구절인 경우, 리스트에 삽입
    }

    // 2. 클릭한 구절이 1개 이상이면 플로팅액션버튼 보이기
    if(ContentsIdList_clicked.length>0){
      Change_FAB_opacity(1.0);
    }else{
      Change_FAB_opacity(0.0);
      fabKey.currentState!.close(); // 열려있는 액션버튼이 있으므로 닫아준다 ㄱㄱ
    }
    update();
  }

  // <함수> 손으로 클릭한 성경구절 각각의 정보 받아오기
  Future<void> GetClickedVerses() async {
    /* DB에서 정보 받아오기 */
    ContentsDataList_clicked = await BibleRepository.GetClickedVerses(ContentsIdList_clicked, Bible_choiced);
    /* 팝업 띄우기 전에 선택된 칼라코드 가장 위쪽에 있는 색깔로 업뎃해주기 */
    ColorCode_choice(ContentsDataList_clicked[0]["highlight_color_index"]);
    update();
  }


  // <함수> 다음 페이지 정보를 확인하기 위한 더미 데이터 받아오기, 초반 한번만 받아오면 됨
  Future<void> GetVersesDummy() async {
    VersesDummy = await BibleRepository.GetVersesDummy();
    update();
  }

  // <함수> 이전, 다음페이지 넘어가기
  void Page_change(direction){
    // 더미데이터에서 현재 인덱스 확인
    var current_index = VersesDummy.indexWhere((e) => e['bcode']==BookCode_choiced && e['cnum']==Chapter_choiced);
    // 이전 또는 다음페이지 확인
    switch (direction){
      case "previous" :
        if(current_index==0){ // 이전 페이지가 없는 경우, 안내 메세지 팝업
          PopToast("첫 페이지 입니다.");
        }else{
          BookCode_choiced = VersesDummy[current_index - 1]['bcode'];
          Chapter_choiced  = VersesDummy[current_index - 1]['cnum'];
        }
        break;

      case "next" :
        if(current_index==1188){ // 다음 페이지가 없는 경우, 안내 메세지 팝업
          PopToast("마지막 페이지 입니다.");
        }else{
          BookCode_choiced = VersesDummy[current_index + 1]['bcode'];
          Chapter_choiced  = VersesDummy[current_index + 1]['cnum'];
        }
        break;
    }
    // 플로팅 액션버튼 초기화
    FloatingAB_init();

    // 스크롤 젤위로 초기화
    BibleScroller.jumpTo(0);

    // 성경구절 재조회
    Getcontents();
    update();
    SavePrefsData(); //현재 설정값 저장
  }


  // <함수> 자유검색 질의어(쿼리, Query) 저장
  void FreeSearchQuery_update(query){
    /* 선택된 권 번호 업데이트 */
    FreeSearchQuery = query;
    /* 검색 히스토리 저장 */
    FreeSearch_history_update(Bible_choiced, query);
  }
  // <함수> 자유검색 히스토리 저장
  void FreeSearch_history_update(bible, query){
    FreeSearch_history_bible.add(bible); /* 성경이름 넣기 */
    FreeSearch_history_query.add(query); /* 쿼리문 넣기 */
    update();
  }
  // <함수> 자유검색 히스토리 삭제 (1개 삭제 & 일부 삭제)
  void FreeSearch_history_remove_one(index){
    FreeSearch_history_bible.removeAt(index);
    FreeSearch_history_query.removeAt(index);
    SavePrefsData(); //현재 설정값 저장
    // 토스트 메세지 띄우기
    PopToast("해당 검색 기록이 삭제 되었습니다.");
    update();
  }
  // <함수> 자유검색 히스토리 삭제 (전체 삭제 & 초기화)
  void FreeSearch_history_remove_all(){
    FreeSearch_history_bible=[]; /* 성경이름 넣기 */
    FreeSearch_history_query=[]; /* 쿼리문 넣기 */
    SavePrefsData(); //현재 설정값 저장
    // 토스트 메세지 띄우기
    PopToast("전체 검색 기록이 삭제 되었습니다.");
    update();
  }


  //<함수>자유검색 결과 리스트 받아오기
  Future<void> GetFreeSearchList() async {
    //0. 로딩시작 화면 띄우기
    EasyLoading.show(status: 'loading...');
    //1. DB에서 전체 데이터 받아오기 //
    FreeSearchResult      = await BibleRepository.FreeSearchList(Bible_choiced, FreeSearchQuery);
    //2. DB에서 각각의 성경이 몇개씩인지 받아오기 //
    FreeSearchResultCount = await BibleRepository.FreeSearchResultCount(Bible_choiced, FreeSearchQuery);

    //3. 가장 검색결과가 많은 권을 초기값으로 지정 //
    if(FreeSearchResultCount.length>=1){
      // 3-1. 검색결과가 1건 이상인 경우는 정상적으로 진행 //
      FreeSearch_book_choice(FreeSearchResultCount[0]['bcode']);
      PopToast("총 ${FreeSearchResult.length} 건의 검색결과가 존재합니다.");
    }else{
      // 3-2. 검색결과가 0건인경우, 검색 기록 없음 띄워주기
      PopToast("검색결과가 없습니다");
      FreeSearchResult_filtered = []; // 리스트 초기화
    }
    // 4. 검색기록 저장 및 변수 업뎃
    SavePrefsData(); //현재 설정값 저장
    update();

    //5. 로딩종료 화면 띄우기
    EasyLoading.dismiss();
  }

  // <함수> 자유검색 성경 권(book) 선택
  Future<void> FreeSearch_book_choice(bcode) async {
    //0. 로딩시작 화면 띄우기
    EasyLoading.show(status: 'loading...');

    /* 선택된 권 번호 업데이트 */
    FreeSearchSelected_bcode = bcode;

    /* 선택된 권에 맞는 챕터(cnum) 갯수 받아오기 */
    FreeSearchResultCount_cnum = await BibleRepository.FreeSearchResultCount_cnum(Bible_choiced, FreeSearchSelected_bcode, FreeSearchQuery);
    /* 선택된 챕터(cnum)번호 가장 위에 있는 챕터번호로 초기화 */
    FreeSearchSelected_cnum = FreeSearchResultCount_cnum[0]['cnum'];


    /* 선택된 권 번호(bcode) & 챕터번호 (cnum) 에 맞게 결과 필터링 */
    if(FreeSearchResult.length > 0){
      FreeSearchResult_filtered = FreeSearchResult.where(
              (f) =>
              (f['bcode'] == FreeSearchSelected_bcode) &
              (f['cnum'] == FreeSearchSelected_cnum)
      ).toList();
    }else{
      FreeSearchResult_filtered = [];
    }
    /* 컨텐츠 스크롤 초기화 */
    ContentsScroller.jumpTo(0);
    update();

    //5. 로딩종료 화면 띄우기
    EasyLoading.dismiss();
  }

  // <함수> 자유검색 성경 챕터번호(cnum) 선택
  void FreeSearch_cnum_choice(cnum){
    /* 챕터번호(cnum)업데이트 */
    FreeSearchSelected_cnum = cnum;
    /* 선택된 권 번호(bcode) & 챕터번호 (cnum) 에 맞게 결과 필터링 */
    if(FreeSearchResult.length > 0){
      FreeSearchResult_filtered = FreeSearchResult.where(
              (f) =>
          (f['bcode'] == FreeSearchSelected_bcode) &
          (f['cnum'] == FreeSearchSelected_cnum)
      ).toList();
    }else{
      FreeSearchResult_filtered = [];
    }
    /* 컨텐츠 스크롤 초기화 */
    ContentsScroller.jumpTo(0);
    update();
  }


  // <함수> 자유검색에서 "구절로 이동" 클릭 BookCode_choiced, Chapter_choiced
  void MoveToContents(result){
    /* 성경 종류 업데이트 */
    Bible_choiced = Bible_choiced;
    /* 권 이름 업데이트 */
    Book_choiced     = result['국문'];
    /* 권 코드 업데이트 */
    BookCode_choiced = result['bcode'];
    /* 챕터번호 업데이트 */
    Chapter_choiced  = result['cnum'];
    /* 컨텐츠 업데이트 */
    Getcontents();
    update();
  }

  // <함수> 자유검색창 초기화
  void FreeSearch_init(){
    FreeSearchResult = []; /* 검색결과 초기화 */
    FreeSearchResult_filtered = []; /* 검색결과 초기화 */
    FreeSearchResultCount = []; /* 검색결과 초기화 */
    FreeSearchResultCount_cnum = []; /* 검색결과 초기화 */
    FreeSearchQuery = ""; // 자유검색 쿼리문 초기화
    GetFreeSearchList();
    update();
  }

  // <함수> 옵션팝업 성경(Bible) 선택
  void Bible_choice(bible){
    Bible_choiced = bible;/* 선택된 성경 업데이트 */
    Getcontents(); /* 메인 성경 컨텐츠 업데이트 */
    FreeSearch_init(); // 자유검색 초기화
    GetFavorite_list(); // 즐겨찾기 업데이트
    Memo_DB_load(); // 메모 업데이트
    update();
  }

  // <함수> 히스토리 -> 자유검색 재검색
  void History_click(index){
    /* 선택한 히스토리값에 맞에 검색 값 수정 */
    // 0. 0번탭(검색결과탭)으로 이동
    SearchtabController.animateTo(0);
    // 1. 쿼리에 필요한 변수 수정
    textController.text      = FreeSearch_history_query[index]; // 보여지는 쿼리 수정
    FreeSearchQuery          = FreeSearch_history_query[index]; // 실제 검색에 쓸 쿼리문 수정
    Bible_choiced = FreeSearch_history_bible[index]; // 선택된 성경 수정
    // 2. 쿼리 실행
    GetFreeSearchList();
    /* 메인 성경 컨텐츠 업데이트 */
    Getcontents();
    GetFavorite_list(); // 즐겨찾기 업데이트
    update();
  }

  //<함수> 플로팅액션버튼 투명도 변경
  void Change_FAB_opacity(double opacity){
    FAB_opacity = opacity;
    update();
  }

  //<함수> 즐겨찾기 색깔 선택
  void ColorCode_choice(int index){
    ColorCode_choiced_index = index;
    update();
  }


  //<함수> 즐겨찾기 색깔 저장
  Future<void> ColorCode_DB_save() async {
    // DB에 덮어쓰기
    await BibleRepository.ColorCode_save(ContentsIdList_clicked, ColorCode_choiced_index);
    // 메인구절 재조회
    Getcontents();
    // 즐겨찾기 목록 재조회
    GetFavorite_list();
    // 플로팅 액션버튼 초기화
    FloatingAB_init();
    update();
  }

  // <함수> 즐겨찾기페이지 _ 사람이 클릭한 색깔 리스트 업데이트 ( Favorite_choiced_color_list )
  void Favorite_choiced_color_list_update(int index){
    // 0번 칼라코드 인덱스(X)를 클릭한 경우, 리스트 초기화
    if(index == 0){
      Favorite_choiced_color_list = []; // 선택된 칼라코드 모두 초기화
      FloatingAB_init(); // 플로팅 액션버튼 관련 정보 모두 초기화
    // 0번이 아닌 칼라코드 인경우, 아래와 같이 처리한다 ㄱㄱ
    }else{
      // 1. 클릭한 칼라 인덱스가 있는지 확인하고 있으면 제외, 없으면 추가 해준다.
      if (Favorite_choiced_color_list.contains(index)){
        Favorite_choiced_color_list.remove(index);//1. 이미 클릭한 구절인 경우, 리스트에서 제외
      }else{
        Favorite_choiced_color_list.add(index);//2. 클릭하지 않은 구절인 경우, 리스트에 삽입
      }
    }
    update();
  }

  /* 즐겨찾기페이지 _ 칼라코드 별 갯수 구하기 */
  Future<void> Get_color_count() async {
    //1. DB에서 칼라코드별 갯수 받아오기
    Favorite_Color_count = await BibleRepository.Get_color_count();
    update();
    //print(Favorite_Color_count.where((e)=>e['highlight_color_index']==1).toList()[0]['count(highlight_color_index)']);
  }


  // <함수> 즐겨찾기페이지 _ 즐겨찾기 불러오기 _ 특정 칼라코드에 따른 즐겨찾기 리스트 가져오기
  Future<void> GetFavorite_list() async {
    // 로딩화면 띄우기
    EasyLoading.show(status: 'loading...');

    /* DB 조회하기 */
    Favorite_list = await BibleRepository.Favorite_list_load_specific(Bible_choiced, Favorite_choiced_color_list);

    /* 현재와의 시간차이 구하기 ( 방금_1분이내, xx시간전, xx일전, xx달전, xx년전 으로 구분 ) */
    // 현재 시간
    var _toDay = DateTime.now();
    // 결과 담을 공간 초기화
    Favorite_timediffer_list = [];
    // for로 모든 항목에 대한 시간 계산
    for(int i = 0; i < Favorite_list.length; i++){
      var date = Favorite_list[i]['bookmark_updated_at'];
      // 1. 시간 산출결과 임시 저장공간
      var temp = "";
      // 2. 시간차이 계산 ( 분 기준으로 )
      int time_difference = int.parse(_toDay.difference(DateTime.parse(date)).inMinutes.toString());
      // 3. 조건에 맞게 시간 재지정
      if(time_difference<=0){temp = "방금 전";} // 1분 미만
      else if (0 < time_difference &&  time_difference < 60){temp = "${time_difference}분 전";} // 1시간 미만
      else if (60 < time_difference &&  time_difference < 60*24){temp = "${(time_difference/60).round()}시간 전";} // 1일 미만
      else if (60*24 < time_difference &&  time_difference < 60*24*30){temp = "${(time_difference/(60*24)).round()}일 전";} // 1달 미만
      else if (60*24*30 < time_difference &&  time_difference < 60*24*30*12){temp = "${(time_difference/(60*24*30)).round()}달 전";} // 1년 미만
      else if (60*24*30*12 < time_difference){temp = "${(time_difference/(60*24*30*12)).round()}년 전";} // 1년 초과
      // 4. 결과 담기
      Favorite_timediffer_list.add(temp);
    }
    // 즐겨찾기 색깔별 갯수 가져오기
    Get_color_count();
    // 로딩화면 종료
    EasyLoading.dismiss();
    update();
  }

  // <함수> 즐겨찾기페이지 _ 구절에 대한 색변경 버튼 이벤트
  Future<void> Favorite_color_change(int _id) async {
    // 즐겨찾기 팝업창에 보여줘야하므로 클릭된 구절 정보로 업데이트
    ContentsIdList_clicked = [_id];
    // 위에 클릭 된 구절 정보로 DB에서 데이터 받아오기
    GetClickedVerses();
    update();
  }

  //<함수> 메모내용 저장 (INSERT)
  Future<void> Memo_DB_save(String memo) async {
    // DB에 덮어쓰기
    await BibleRepository.Memo_save(ContentsIdList_clicked, memo);
    // 플로팅 액션버튼 초기화
    FloatingAB_init();
    update();
  }

  //<함수> 메모내용 수정 (UPDATE)
  Future<void> Memo_update(int id, String memo) async {
    // DB에 수정하기
    await BibleRepository.Memo_update(id, memo);
    // 메모내용 로드
    Memo_DB_load();
    update();
  }


  //<함수> 메모내용 로드 (LOAD)
  Future<void> Memo_DB_load() async {
    // 0. 연관구절에 대한 구정 내용 DB 조회해서 가져오기
    Memo_list = await BibleRepository.Memo_load();

    // 1. 연관 구절 중복 제거해서 정리
    var verses_id_list = []; // 결과 담을 공간
    for(int i = 0; i < Memo_list.length; i++){
      var _toList = json.decode('${Memo_list[i]['연관구절']}'); // 텍스트형식의 리스트를 리스트 타입으로 변경해준다.
      for(int j = 0; j < _toList.length; j++){ // 리스트 속의 리스트를 순환하면서 하나씩 배열에 다시 담아준다.
        verses_id_list.add(_toList[j]); // 결과를 하나씩 모아준다.
      }
    }
    verses_id_list = verses_id_list.toSet().toList(); // 중복값 제거 ( duplicate drop )

    // 2. DB에서 해당되는 구절 가져와서 입혀주기
    Memo_verses_list = await BibleRepository.GetClickedVerses(verses_id_list, Bible_choiced);

    // 3. 현재와의 시간차이 구하기 ( 방금_1분이내, xx시간전, xx일전, xx달전, xx년전 으로 구분 ) //
    // 현재 시간
    var _toDay = DateTime.now();
    // 결과 담을 공간 초기화
    Memo_timediffer_list = [];
    // for로 모든 항목에 대한 시간 계산
    for(int i = 0; i < Memo_list.length; i++){
      var date = Memo_list[i]['updated_at'];
      // 1. 시간 산출결과 임시 저장공간
      var temp = "";
      // 2. 시간차이 계산 ( 분 기준으로 )
      int time_difference = int.parse(_toDay.difference(DateTime.parse(date)).inMinutes.toString());
      // 3. 조건에 맞게 시간 재지정
      if(time_difference<=0){temp = "방금 전";} // 1분 미만
      else if (0 < time_difference &&  time_difference < 60){temp = "${time_difference}분 전";} // 1시간 미만
      else if (60 < time_difference &&  time_difference < 60*24){temp = "${(time_difference/60).round()}시간 전";} // 1일 미만
      else if (60*24 < time_difference &&  time_difference < 60*24*30){temp = "${(time_difference/(60*24)).round()}일 전";} // 1달 미만
      else if (60*24*30 < time_difference &&  time_difference < 60*24*30*12){temp = "${(time_difference/(60*24*30)).round()}달 전";} // 1년 미만
      else if (60*24*30*12 < time_difference){temp = "${(time_difference/(60*24*30*12)).round()}년 전";} // 1년 초과
      // 4. 결과 담기
      Memo_timediffer_list.add(temp);
    }
    update();
  }

  //<함수> 메모 페이지 _ 메모 팝업 초기화
  void MemoPop_init(){
    MemotextController.text = ""; // 메모 초기화
    MemoErrorText = null; // 메모 오류 알림 초기화
  }

  //<함수> 메모 페이지 _ 메모 입력 시 validation 경고 띄우기
  void MemoErrorText_update(String msg){
    MemoErrorText = msg;
    update();
  }

  //<함수> 메모 페이지 _ 메모 삭제 (DELETE)
  Future<void> Memo_DB_delete(int id) async {
    //1. DB에서 지우기
    await BibleRepository.Memo_delete(id);
    //2. 메모 DB 다시 불러오기
    Memo_DB_load();
    update();
  }

  //<함수> 메모 페이지 _ 편집 버튼 눌렀을 때, 해당 구절 리스트에 담아주기 + 메모 내용 붙여주기
  void Memo_ContentsIdList_update(result){
    //0. 그냥 가져오면 텍스트로 가져오므로 리스트로 변환해줌
    var verses_list = json.decode(result['연관구절']);//
    //1. 선택된 연관구절 담아주기
    ContentsIdList_clicked = verses_list;
    //2. 기존 메모내용 붙여주기 ( 텍스트 필드 컨트롤러 활용 )
    MemotextController.text = result['메모'];
    //3. 해당 구절 정보 받아와서 업뎃해주기
    GetClickedVerses();
    update();
  }


  //<함수> 호출 앱 정보 변경
  void update_from_which_app(String appname){
    from_which_app = appname;
    update();
  }

}