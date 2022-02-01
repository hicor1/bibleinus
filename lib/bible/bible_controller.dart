import 'package:bible_in_us/bible/bible_component.dart';
import 'package:bible_in_us/bible/bible_repository.dart';
import 'package:bible_in_us/general/general_controller.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

// Gex컨트롤러 객체 초기화
final GeneralCtr = Get.put(GeneralController());

class BibleController extends GetxController {

  /* <함수> 초기화 함수 */
  void init (){
    GetBookList(); // 성경 리스트는 초반 한번만 받아오면 되므로 init에서 처리한다.
    GetVersesDummy(); // 초반 다음 페이지 정보를 확인하기 위한 더미 데이터 get
    NEWorOLD_choice(NEWorOLD_choiced);  //초반 권(book)불러오기
    Book_choice(Book_choiced); // 초반 챕터번호 선택해놓기
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
    prefs.setString('FreeSearch_Bible_choiced', FreeSearch_Bible_choiced);
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
    FreeSearch_Bible_choiced  = prefs.getString('FreeSearch_Bible_choiced') == null ? FreeSearch_Bible_choiced : prefs.getString('FreeSearch_Bible_choiced')!;
    FreeSearch_history_bible  = prefs.getStringList('FreeSearch_history_bible') == null ? FreeSearch_history_bible : prefs.getStringList('FreeSearch_history_bible')!;
    FreeSearch_history_query  = prefs.getStringList('FreeSearch_history_query') == null ? FreeSearch_history_query : prefs.getStringList('FreeSearch_history_query')!;
    update(); // 상태업데이트 내용이 반영되어 로딩이 끝났음을 알려줘야함 ㄱㄱ
  }

  /* <변수> 각종 변수 정의  */
  late TabController tabController; // 메인페이지 탭 컨트롤러 정의
  late TabController SearchtabController; // 자유검색페이지 탭 컨트롤러 정의

  /* 메인 페이지 모달창 스크롤 컨트롤러 정의 */
  final ScrollController BookScroller    = ScrollController(keepScrollOffset: true); // 모달창 스크롤 컨트롤러 선언
  final ScrollController ChapterScroller = ScrollController(keepScrollOffset: true); // 모달창 스크롤 컨트롤러 선언

  /* 자유 검색 스크린 결과 스크롤 조정을 위한 컨트롤러 정의 */
  final ScrollController BookCountScroller  = ScrollController(keepScrollOffset: true);
  final ScrollController ContentsScroller   = ScrollController(keepScrollOffset: true);

  /* 자유 검색 스크린 검색창 텍스트컨트롤러 정의 */
  var textController = TextEditingController();

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
  var Bible_list              = ['개역개정', '개역한글판_국한문', '현대인의성경', 'KJV', 'NIV', 'ASV'];
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
  var FreeSearch_Bible_choiced  = '개역개정';
  List<String> FreeSearch_history_bible  = []; // 최근검색 성경이름
  List<String> FreeSearch_history_query  = []; // 최근검색 쿼리문

  var FAB_opacity = 0.0; // 메인페이지 플로팅액션버튼 투명도

  var ColorCode = [Color(0xFFBFBFBF), Color(0xFF0040FF), Color(0xFF64FE2E),Color(0xFFD0A9F5),Color(0xFF088A29),Color(0xFFF781D8)]; // 플로팅 액션버튼 -> 즐겨찾기 색깔표
  var ColorCode_choiced_index = 0; // 플로팅 액션버튼 -> 선택된 즐겨찾기 색깔표

  var Favorite_choiced_color_list = []; // 즐겨찾기 페이지에서 선택된 칼라코드 인덱스


  //<함수>성경(book)리스트 받아오기
  Future<void> GetBookList() async {
    BookList = await BibleRepository.GetBookList();
    update();
  }

  //<함수>"구약" or "신약" 선택
  void NEWorOLD_choice(String value){
    // 조건 업데이트
    NEWorOLD_choiced = value;
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
    ContentsIdList_clicked = [];// 선택한 구절 초기화
    fabKey.currentState!.close();
    Change_FAB_opacity(0.0); // 플로팅 액션버튼 숨기기

    // 로딩화면 종료
    EasyLoading.dismiss();
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
    ContentsDataList_clicked = await BibleRepository.GetClickedVerses(ContentsIdList_clicked, Bible_choiced);
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
    // 앞에서 클릭한 구절 초기화 및 플로팅 액션버튼 닫기
    ContentsIdList_clicked = [];
    Change_FAB_opacity(0.0); // 플로팅 액션버튼 숨기기
    fabKey.currentState!.close(); // 열려있는 액션버튼이 있으므로 닫아준다 ㄱㄱ

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
    FreeSearch_history_update(FreeSearch_Bible_choiced, query);
  }
  // <함수> 자유검색 히스토리 저장
  void FreeSearch_history_update(bible, query){
    FreeSearch_history_bible.add(bible); /* 성경이름 넣기 */
    FreeSearch_history_query.add(query); /* 쿼리문 넣기 */
    update();
  }
  // <함수> 자유검색 히스토리 삭제 (초기화)
  void FreeSearch_history_remove(){
    FreeSearch_history_bible=[]; /* 성경이름 넣기 */
    FreeSearch_history_query=[]; /* 쿼리문 넣기 */
    // 토스트 메세지 띄우기
    PopToast("최근검색 기록이 삭제 되었습니다.");
    update();
  }


  //<함수>자유검색 결과 리스트 받아오기
  Future<void> GetFreeSearchList() async {
    //0. 로딩시작 화면 띄우기
    EasyLoading.show(status: 'loading...');
    //1. DB에서 전체 데이터 받아오기 //
    FreeSearchResult      = await BibleRepository.FreeSearchList(FreeSearch_Bible_choiced, FreeSearchQuery);
    //2. DB에서 각각의 성경이 몇개씩인지 받아오기 //
    FreeSearchResultCount = await BibleRepository.FreeSearchResultCount(FreeSearch_Bible_choiced, FreeSearchQuery);

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
  void FreeSearch_book_choice(bcode){
    /* 선택된 권 번호 업데이트 */
    FreeSearchSelected_bcode = bcode;
    /* 선택된 권 번호에 맞게 결과 필터링 */
    if(FreeSearchResult.length > 0){
      FreeSearchResult_filtered = FreeSearchResult.where((f) => f['bcode'] == bcode).toList();
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
    Bible_choiced = FreeSearch_Bible_choiced;
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
    update();
  }

  // <함수> 옵션팝업 성경(Bible) 선택
  void Bible_choice(bible, IsMain){
    /* 메인페이지와 검색페이지가 성경을 다르게 관리하므로 구분 */
    if(IsMain){
      Bible_choiced = bible;/* 선택된 성경 업데이트 */
      Getcontents(); /* 컨텐츠 업데이트 */
    }else{
      FreeSearch_Bible_choiced = bible; /* 선택된 성경 업데이트 */
      FreeSearch_init();
    }
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
    FreeSearch_Bible_choiced = FreeSearch_history_bible[index]; // 선택된 성경 수정
    // 2. 쿼리 실행
    GetFreeSearchList();
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

    // 플로팅 액션버튼 초기화
    ContentsIdList_clicked = [];// 선택한 구절 초기화
    fabKey.currentState!.close();
    Change_FAB_opacity(0.0); // 플로팅 액션버튼 숨기기
    update();
  }



}