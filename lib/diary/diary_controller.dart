import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:bible_in_us/bible/bible_component.dart';
import 'package:bible_in_us/bible/bible_controller.dart';
import 'package:bible_in_us/bible/bible_repository.dart';
import 'package:bible_in_us/diary/diary_component.dart';
import 'package:bible_in_us/diary/diary_tab_page.dart';
import 'package:bible_in_us/diary/diary_write_srceen.dart';
import 'package:bible_in_us/diary/diray_view_page.dart';
import 'package:bible_in_us/my/my_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:hashtager/hashtager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';


final BibleCtr = Get.put(BibleController());
final MyCtr = Get.put(MyController());

/* 파이어스토어 객체 생성 */
FirebaseFirestore firestore    = FirebaseFirestore.instance;
/* diary 콜렉션 선택 */
CollectionReference collection = firestore.collection('diary'); // diary 콜렉션 사용
/* recommended_verse 콜렉션 선택 */
CollectionReference recommended_verse_collection = firestore.collection('verse_tag'); // recommended_verse 콜렉션 사용

class DiaryController extends GetxController {

  //<함수> 초기화
  void init(){
    LoadAction(); // 일기 데이터 로드
  }

  /* (설정값) SharedPrefs 저장하기(save) */
  Future<void> SavePrefsData() async {
    //1. 객체 불러오기
    final prefs = await SharedPreferences.getInstance();
    //2. 상태값 저장할 목록 및 저장 수행
    prefs.setString('diary_view_ViewMode', diary_view_ViewMode);
  }
  /* (설정값) SharedPrefs 불러오기(load) */
  Future<void> LoadPrefsData() async {
    //1. 객체 불러오기
    final prefs = await SharedPreferences.getInstance();
    //2. 불러올 상태값 목록 및 데이터 업데이트
    diary_view_ViewMode  = prefs.getString('diary_view_ViewMode') == null ? diary_view_ViewMode : prefs.getString('diary_view_ViewMode')!;
    update(); // 상태업데이트 내용이 반영되어 로딩이 끝났음을 알려줘야함 ㄱㄱ
  }

  /* <변수>정의 */
  var dirary_screen_address = ""; // 성경일기 작성 페이지 _ 선택된 주소
  var dirary_screen_color_index = 0; // 성경일기 작성 페이지 _ 선택된 색깔 인덱스
  var dirary_screen_emoji_index = 0; // 성경일기 작성 페이지 _ 선택된 색깔 인덱스
  var dirary_screen_weather_index = 0; // 성경일기 작성 페이지 _ 선택된 색깔 인덱스
  var dirary_screen_emoticon_index = 0; // 성경일기 작성 페이지 _ 선택된 색깔 인덱스
  var dirary_screen_timetag_index = 0; // 성경일기 작성 페이지 _ 선택된 시간태그 인덱스
  var dirary_screen_title = "";    //성경일기 작성 페이지 _ 일기 제목 ( title )
  var dirary_screen_contents = ""; //성경일기 작성 페이지 _ 일기 내용 ( contents )
  var dirary_screen_selectedDate = DateTime.now(); //성경일기 작성 페이지 _ 선택된 날짜_ 오늘 날짜로 초기화

  var dirary_screen_selected_verses_id = [99999]; // 성경일기 작성 페이지 _ 선택된 구절 인덱스 리스트
  var max_verse_length = 10; // 추가 가능한 최대 구절 수 제한
  var temp_verses_id_list = []; // DB에서 성경 불러오기 위한 중복이 제거된 구절 아이디 리스트 임시 저장소


  var Temp_selected_contents_id   = 0; // 구절 id 수정을 위한  선택된 구절 아이디값 임시저장
  var mode_select                 = ""; // "add" or "replace" 중 모드 선택
  var selected_contents_data      = []; //dirary_screen_selected_verses_id DB에서 조회한 선택된 구절 정보 담는공간
  // 선택된 사진 3장 경로 저장(빈경로), ( 3장으로 제한 ), File과 URL string 두 개의 타입이 복합적으로 사용돠어야하므로 "dynamic"으로 선언!!
  List<dynamic> choiced_image_file = [File(""),File(""),File("")];

  var diary_view_ViewMode = "grid"; // 성경일기 뷰 페이지 _ "그리드뷰(grid view) 또는 리스트뷰(list view)선택"
  var diary_view_contents = []; // 성경일기 뷰 페이지 _ 데이터 로드
  var diary_view_contents_filtered_index = []; // 성경일기 뷰 페이지 _ 필터된 데이터의 인덱스만 가져온다
  var diary_view_timediffer = []; // 성경일기 뷰 페이지 _ 시간경과 산출데이터 저장
  var diary_view_today_diary_count = 0; // 성경일기 뷰 페이지 _ 오늘 작성한 일기가 몇개인지 카운트
  var diary_view_selected_contents_data = []; // 성경일기 뷰 페이지 _ 보여줄 성경 구절 데이터 DB에서 받아와서 저장하기
  var NewOrModify = "";// 모드선택 ( 신규(new) 또는 수정(modify) )
  var selected_document_id = "";// 수정하기 위해 선택한 파이어스토어 문서 아이디

  var GalleryOrCam = "";// 사진첨부에서 "사진첩(gallery)" 또는 "카메라(camera)" 선택

  List<Meeting> meetings = <Meeting>[]; // 성경일기 달력 스크린 _ 일정담아둘 공간

  var statistics_month_string = ""; // 성경 달력 스크린 _ 기본 통계 _ 월 현황
  var statistics_month_percent = 0.0; // 성경 달력 스크린 _ 기본 통계 _ 월 퍼센트
  var statistics_this_month = 0; //성경 달력 스크린 _ 기본 통계 _ 올해 월

  var statistics_year_string = ""; // 성경 달력 스크린 _ 기본 통계 _ 년 현황
  var statistics_year_percent = 0.0; // 성경 달력 스크린 _ 기본 통계 _ 년 퍼센트
  var statistics_this_year = 0; //성경 달력 스크린 _ 기본 통계 _ 올해 년도

  var diary_view_selected_year       = DateTime.now().year; // 성경 뷰페이지 _ 선택된 년도
  var diary_view_selected_month      = DateTime.now().month; // 성경 뷰페이지 _ 선택된 월

  /* 텍스트컨트롤러 정의 */
  var TitletextController      = TextEditingController(); // 성경일기 작성 페이지 _ 일기 제목 ( title ) 컨트롤러
  var ContentstextController   = TextEditingController(); // 성경일기 작성 페이지 _ 일기 내용 ( contents ) 컨트롤러
  var HashTagController        = TextEditingController(); // 성경일기 작성 페이지 _ 일기 내용 ( contents ) 컨트롤러
  var DiarySearchController    = TextEditingController(); // 성경일기 보기(view) 페이지 _ 일기 검색 컨트롤러


  /* 데이트 피커 컨트롤러 정의 */
  var datePickerController = DateRangePickerController(); // 성경일기 작성 페이지 _ 날짜선택 컨트롤러

  /* 달력 컨트롤러 정의의(https://www.syncfusion.com/kb/12115/how-to-programmatically-select-the-dates-in-the-flutter-calendar) */
  final CalendarController calendarController= CalendarController();

  /* 리스트빌더 컨트롤러 정의 */
  final ScrollController ColorScroller     = ScrollController(keepScrollOffset: false); // 일기 작성페이지 _  색상 스크롤 컨트롤러
  final ScrollController EmoticonScroller  = ScrollController(keepScrollOffset: false); // 일기 작성페이지 _ 이모티콘 스크롤 컨트롤러
  final ScrollController WeatherScroller   = ScrollController(keepScrollOffset: false); // 일기 작성페이지 _ 날씨티콘 스크롤 컨트롤러

  var Scrolling_count = 0; // 일기 작성페이지 _ 이모티콘+날씨티콘 스크롤 동작 횟수 관리용


  /* 칼라코드 정의 */
  var ColorCode = [
    // Color(0xFFBFBFBF), // 젤 처음은 흑백 칼라
    Color(0xff0c0c0d).withOpacity(0.8), // 회색은 제외
    Color(0xFF00bfff).withOpacity(0.8),
    Color(0xFF32cd32).withOpacity(0.8),
    Color(0xff9966ff).withOpacity(0.8),
    Color(0xFFF781D8).withOpacity(0.8),

    Color(0xFFFFBF00).withOpacity(0.8),
    Color(0xFF6495ED).withOpacity(0.8),
    Color(0xFF9FE2BF).withOpacity(0.8),
    //Color(0xFFE9967A).withOpacity(0.8),
    Color(0xFFFFA07A).withOpacity(0.8),
    //Color(0xFFE9967A).withOpacity(0.8),

    Color(0xFF808000).withOpacity(0.8),
    Color(0xFF008000).withOpacity(0.8),
    Color(0xFF008080).withOpacity(0.8),
    //
    // Color(0xFFFF9AA2),
    // Color(0xFFFFB7B2),
    // Color(0xFFFFDAC1),
    // Color(0xFFE2F0CB),
    // Color(0xFFB5EAD7),
    // Color(0xFFC7CEEA),

  ];

  /* 이미티콘(이모지,emoji) 정의 */
  var EmojiCode = [
    "\u{1f601}",
    "\u{1f602}",
    "\u{1f603}",
    "\u{1f604}",
    "\u{1f605}",
    "\u{1f606}",
    "\u{1f609}",
    "\u{1f60A}",
    "\u{1f60B}",
    "\u{1f60C}",
    "\u{1f60D}",
    "\u{1f60F}",
    "\u{1f612}",
    "\u{1f613}",
    "\u{1f614}",
    "\u{1f616}",
    "\u{1f618}",

    "\u{1f61A}",
    "\u{1f61C}",
    "\u{1f61D}",
    "\u{1f61E}",

    "\u{1f620}",
    "\u{1f621}",
    "\u{1f622}",
    "\u{1f623}",
    "\u{1f624}",
    "\u{1f625}",
    "\u{1f628}",
    "\u{1f629}",
    "\u{1f62A}",
    "\u{1f62B}",
    "\u{1f62D}",
    "\u{1f630}",
    "\u{1f631}",
    "\u{1f632}",
    "\u{1f633}",
    "\u{1f635}",
    "\u{1f637}",
  ];

  /* 날씨 아이콘 이름 정의 */
  var WeatherName = [
    "sunny",
    "sunny-cloudy",
    "cloudy",
    "windy",
    "wind",
    "storm-rain",
    "storm",
    "snow-rain",
    "snow",
    "rainy",
    "heavy-rain",
    "blizzard",
  ];

  /* 이모티콘 이름 정의 */
  var EmoticonName = [
    "free-icon-in-love-983030",
    "free-icon-happy-983007",
    "free-icon-happy-983028",
    "free-icon-laughing-982985",
    "free-icon-happy-982984",
    "free-icon-silent-983027",
    "free-icon-sleeping-983004",
    "free-icon-sad-982995",
    "free-icon-embarrassed-982993",
    "free-icon-disappointed-982991",
    "free-icon-crying-982986",
    "free-icon-injured-983025",
    "free-icon-sick-983002",
    "free-icon-angry-982987",
    "free-icon-angry-983032",
    "free-icon-shocked-983019",
    "free-icon-angry-982989",
    "free-icon-angry-983022",
  ];

  /* 시간 추천 태크 정의 */
  var TimeTag = [
    "촉촉한 새벽","새로운 아침","나른한 낮 시간","빛나는 오후","설레는 퇴근","따뜻한 저녁","별 헤는 밤"
  ];

  //<함수> 성경일기 작성스크린 _ 주소 입력
  void update_dirary_screen_address(String address){
    dirary_screen_address = address;
    update();
  }

  //<함수> 성경일기 작성스크린 _ 색깔 인덱스 선택
  void update_dirary_screen_color_index(int index){
    dirary_screen_color_index = index;
    update();
  }

  //<함수> 성경일기 작성스크린 _ 이모지(이모티콘) 인덱스 선택
  void update_dirary_screen_emoji_index(int index){
    dirary_screen_emoji_index = index;
    update();
  }

  //<함수> 성경일기 작성스크린 _ 날씨 인덱스 선택
  void update_dirary_screen_weather_index(int index){
    dirary_screen_weather_index = index;
    update();
  }

  //<함수> 성경일기 작성스크린 _ 이모티콘 선택
  void update_dirary_screen_emoticon_index(int index){
    /* 이모티콘 인덱스 저장 */
    dirary_screen_emoticon_index = index;
    update();
  }

  //<함수> 성경일기 작성스크린 _ 색상&이모티콘&날씨 컨트롤러 offset 설정
  void update_dirary_screen_builder_offet(){
    if(Scrolling_count==1){
      /* 1. 이모티콘 컨트롤러 offset 산출(이모티콘 크기 + 거리로 부터 스크롤 포지션 예측) */
      var icon_width    = 40.0;
      var icon_distance = 25.0;
      var color_offset = (icon_width+icon_distance)*(dirary_screen_color_index) - 5;
      var emoticon_offset = (icon_width+icon_distance)*(dirary_screen_emoticon_index) - 5;
      var weather_offset = (icon_width+icon_distance)*(dirary_screen_weather_index) - 5;

      /* 2-1. 이모티콘 컨트롤러 이동 */
      ColorScroller.animateTo(
        color_offset,
        duration: Duration(milliseconds: 1500),
        curve: Curves.fastOutSlowIn,
      );
      /* 2-2. 이모티콘 컨트롤러 이동 */
      EmoticonScroller.animateTo(
        emoticon_offset,
        duration: Duration(milliseconds: 1500),
        curve: Curves.fastOutSlowIn,
      );
      /* 2-3. 날씨티콘 컨트롤러 이동 */
      WeatherScroller.animateTo(
        weather_offset,
        duration: Duration(milliseconds: 1500),
        curve: Curves.fastOutSlowIn,
      );
      /* 3. 스크롤 카운터 증가 */
      Scrolling_count += 1;
    }
  }

  //<함수> 성경일기 작성스크린 _ 스크롤링 몇번했는지 카운트 기록
  void Recording_Scrolling_count(int count){
    Scrolling_count = count;
  }

  //<함수> 성경일기 작성스크린 _ 타임태그 인덱스 선택
  void update_dirary_screen_timetag_index(int index){
    dirary_screen_timetag_index = index;
    update();
  }
  
  //<함수> 선택한 구절 id 정보 "추가(add)" 또는 "수정(replace)"하고 DB에서 재조회 하기
  Future<void> add_verses_id (int id) async {
    /* 더미(99999) 잠깐 지우기(순서 맞추기 위함) */
    dirary_screen_selected_verses_id.remove(99999);
    /* !!모드에 따라 다른 로직 적용!! */
    if(mode_select == "add"){
      /* 1. 추가 모드 */
      dirary_screen_selected_verses_id.add(id);/* 선택한 구절 id 담기 */
    }else if(mode_select == "replace"){
      /* 2. 수정 모드 */
      int index = dirary_screen_selected_verses_id.indexOf(Temp_selected_contents_id); // 선택한 구절 아이디가 전체 리스트에서 몇번째 인덱스인지 확인
      dirary_screen_selected_verses_id[index] = id; // 선택한 구절 아이디를 새로운 구절 아이돌 수정(replace)
    }

    /* 중복값 제거하기 */
    dirary_screen_selected_verses_id = dirary_screen_selected_verses_id.toSet().toList();
    /* 전체 구절이 10개를 넘지 않도록 제한, 10개가 넘을 경우 "추가"버튼의 트리거인 '99999'가 보이지 않게한다 */
    if(dirary_screen_selected_verses_id.length < max_verse_length){
      /* 더미(99999) 다시 넣기 */
      dirary_screen_selected_verses_id.add(99999);
    }else{
      /* 총 10개가 넘었으므로 "추가"버튼의 트리거인 '99999'는 넣지 않는다 */
    }
    /* 선택한 구절 DB 조회 */
    selected_contents_data = await BibleRepository.GetClickedVerses(dirary_screen_selected_verses_id, BibleCtr.Bible_choiced);
    update();
  }

  //<함수> "bible메인화면"에서 선택한 구절 id 리스트 정보 "추가(add)" 하고 DB에서 재조회 하기기
  Future<void> add_verses_idList() async {

    /* 선택된 구절 아이디 초기화 */
    diray_write_screen_init();
    /* Bible컨트롤러에서 선택한 구절 아이디 리스트 가져오기 */
    var idList = BibleCtr.ContentsIdList_clicked;
    // 1. 구절 추가 가능한 최대갯수(10개)로 제한하기
    if(idList.length > max_verse_length){
      // 1-1. 10개로 짜르기
      idList = idList.sublist(0,max_verse_length);
      PopToast("최대 10개까지 선택가능합니다");
    }else{}

    /* 더미(99999) 잠깐 지우기(순서 맞추기 위함) */
    dirary_screen_selected_verses_id.remove(99999);
    /* for문 돌면서 선택한 구절 id 담기 */
    for(int i = 0; i < idList.length; i++){
      dirary_screen_selected_verses_id.add(idList[i]);
    }
    /* 중복값 제거하기 */
    dirary_screen_selected_verses_id = dirary_screen_selected_verses_id.toSet().toList();
    /* 전체 구절이 10개를 넘지 않도록 제한, 10개가 넘을 경우 "추가"버튼의 트리거인 '99999'가 보이지 않게한다 */
    if(dirary_screen_selected_verses_id.length < max_verse_length){
      /* 더미(99999) 다시 넣기 */
      dirary_screen_selected_verses_id.add(99999);
    }else{
      /* 총 10개가 넘었으므로 "추가"버튼의 트리거인 '99999'는 넣지 않는다 */
    }
    /* 선택한 구절 DB 조회 */
    selected_contents_data = await BibleRepository.GetClickedVerses(dirary_screen_selected_verses_id, BibleCtr.Bible_choiced);
    update();
    /* 일기쓰기 스크린으로 이동하기 */
    Get.to(() => DiaryWriteScreen());
  }


  //<함수> 선택한 구절 id 삭제하고 DB 재조회 하기
  Future<void> remove_verses_id (int id) async {
    /* 선택한 구절 id 담기 */
    dirary_screen_selected_verses_id.remove(id);
    /* 더미(99999) 다시 넣기(10개가 넘어서 "추가"버튼을 빼놨을수도 있으므로, 삭제하면 갯수가 줄어드니깐 추가해줘야지 */
    dirary_screen_selected_verses_id.add(99999);
    /* 중복값 제거하기 */
    dirary_screen_selected_verses_id = dirary_screen_selected_verses_id.toSet().toList();

    /* 선택한 구절 DB 조회 */
    selected_contents_data = await BibleRepository.GetClickedVerses(dirary_screen_selected_verses_id, BibleCtr.Bible_choiced);
    /* 삭제 안내메세지 */
    PopToast("삭제 안료");
    update();
  }

  //<함수> 선택한 구절 id 수정하기 위한 현재 선택 인덱스 값 저장
  void update_mode_select(String mode, int id){
    mode_select = mode; // "add" or "replace" 중 모드 선택
    Temp_selected_contents_id = id; // 선택된 구절 아이디 값 저장
    update();
  }


  /* <함수> 갤러리에서 프로필 이미지 가져오기 */
  Future<void> galleryImagePicker(index)  async {

    /* 이미지 피커 객체 불러오기 */
    final ImagePicker _picker = ImagePicker();
    /* 갤러리에서 이미지 선택하기(용량을 줄이기 위해 이미지 리사이즈 시전) */
    final XFile? image = await _picker.pickImage(// https://firebase.flutter.dev/docs/storage/usage/
        source: GalleryOrCam == "gallery" ? ImageSource.gallery : ImageSource.camera ,
    );

    /* 이미지 자르기 */ https://pub.dev/packages/image_cropper/example
    File? croppedFile = await ImageCropper().cropImage(
        sourcePath: image!.path,
        // 저장효율을 위해 이미지 크기 밎 퀄리티 제한
        maxWidth: 1200, // 4:3 맞추자
        maxHeight: 900, // 4:3 맞추자
        compressQuality: 70,
        /* 1. 안드로이드인 경우 */
        aspectRatioPresets: Platform.isAndroid
            ? [
          CropAspectRatioPreset.ratio4x3
        ]
        /* 2. 그 외 경우 */
            : [
          CropAspectRatioPreset.ratio4x3,
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: '사진 자르기',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        )
    );


    /* 이미지 경로 할당 */
    choiced_image_file[index] = croppedFile!;
    update();
  }


  /* <함수> 사진 삭제버튼 클릭 */
  Future<void> DeleteImg(index)  async {
    /* "신규" 또는 "수정"으로 구분해서 사진데이터 삭제한다 */
    var type = choiced_image_file[index].runtimeType;
    /* 1. URL string타입(수정)인 경우 삭제 방식 */
    if (type == String){
      choiced_image_file[index] = "";// 해당 인덱스 URL 초기화
    }else{
    /* 2. 파일타입(신규등록)인 경우 삭제 방식 */
      choiced_image_file[index] = File('');/* 해당 인덱스 이미지 파일 초기화 */
    }
    update();
  }


  /* <함수> 파이어베이스 파일업로드 및 파일 호출경로 받는 함수 */
  Future<String> Firebase_ImgSaveNGetUrl(docID, _imageFile, i)  async {

    /* 경로 만들기 */
    var ImgSavePath = "${'diaryImg/${MyCtr.uid}/$docID/$i'}"; // 사용자UID → 문서ID → 이미지 순서 로 저장한다
    /* 파이어베이스 storage에 이미지 파일 업로드(https://firebase.flutter.dev/docs/storage/usage/) */
    try {
      /* 파이어베이스 스토리지 객체 가져오기 */
      await firebase_storage.FirebaseStorage.instance
          .ref()
          .child(ImgSavePath) // 저장 경로 설정, 파일이름은$docID/$i로 한다. 최대 3개만 저장가능하도록
          .putFile(_imageFile); // 저장할 이미지 파일 지정
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
    }

    /* 위에서 저장한 이미지를 불러올 수 있는 URL 가져오기 */
    String downloadURL = await firebase_storage.FirebaseStorage.instance
        .ref(ImgSavePath)
        .getDownloadURL();

    return downloadURL;
  }

  /* <함수> 파이어베이스 데이터 저장 모듈  */
  Future<void> Firebase_save()  async {
    // 로딩화면 띄우기
    EasyLoading.show(status: 'loading...');

    /* 사진 이름만들기 + 파이어베이스 저장 + 호출 경로 만들기 */
    var docID = collection.doc().id; // 파이어 스토어에 저장되는 문서 ID, 파일 저장 경로로 활용한다.
    var ImgUrl = []; // 최종 파일 downloadURL 이 저장될 공간
    for(int i = 0; i < choiced_image_file.length; i++){
      /* 이미지 경로가 비어있지 않다면 */
      var _imageFile = choiced_image_file[i]; // 이미지 파일 할당
      if(_imageFile.path.isEmpty == false){



        /* <함수> 파이어베이스 파일업로드 및 파일 호출경로 받는 함수 */
        /* 경로 만들기 */
        var ImgSavePath = "${'diaryImg/${MyCtr.uid}/$docID/$i'}"; // 사용자UID → 문서ID → 이미지 순서 로 저장한다
        /* 파이어베이스 storage에 이미지 파일 업로드(https://firebase.flutter.dev/docs/storage/usage/) */
        try {
          /* 파이어베이스 스토리지 객체 가져오기 */
          await firebase_storage.FirebaseStorage.instance
              .ref()
              .child(ImgSavePath) // 저장 경로 설정, 파일이름은$docID/$i로 한다. 최대 3개만 저장가능하도록
              .putFile(_imageFile); // 저장할 이미지 파일 지정
        } on FirebaseException catch (e) {
          // e.g, e.code == 'canceled'
        }
        /* 위에서 저장한 이미지를 불러올 수 있는 URL 가져오기 */
        String downloadURL = await firebase_storage.FirebaseStorage.instance
            .ref(ImgSavePath)
            .getDownloadURL();



        /* 경로 모아주기 */
        ImgUrl.add(downloadURL);
      }else{
        /* 이미지 경로가 비어있다면 */
        null;
      }
    }

    /* 더미데이터(99999) 제거(임시) */
    dirary_screen_selected_verses_id.remove(99999);

    /* 데이터 세이브 */
    collection.add({
      "uid":MyCtr.uid,
      "created_at":DateTime.now(), // 최초 생성 시간
      "updated_at":DateTime.now(), // 수정 시간
      "dirary_screen_selected_verses_id": dirary_screen_selected_verses_id, // 더미 데이터 삭제
      "dirary_screen_selectedDate": dirary_screen_selectedDate,
      "dirary_screen_color_index": dirary_screen_color_index,
      "dirary_screen_title": dirary_screen_title,
      "dirary_screen_contents":dirary_screen_contents,
      "choiced_image_file":ImgUrl,
      "dirary_screen_timetag_index":dirary_screen_timetag_index,
      "dirary_screen_weather_index":dirary_screen_weather_index,
      "dirary_screen_emoticon_index":dirary_screen_emoticon_index,
      "dirary_screen_address":dirary_screen_address,
      "dirary_screen_hashtag":get_hash_tag_list(),
      //"dirary_screen_emoji_index": dirary_screen_emoji_index,
    }).then((value) {
      /* 일기 등록이 완료 된 후에, */
      PopToast("일기가 등록되었어요!");

      /* 더미데이터(99999) 추가 */
      dirary_screen_selected_verses_id.add(99999);

      // 일기 작성페이지 초기화
      diray_write_screen_init();

      // 일기 리스트 다시 불러오기
      LoadAction();

      // 로딩화면 종료
      EasyLoading.dismiss();
      //안내 메세지
      PopToast("등록 안료");
      });// 안내메세지



  }

  /* <함수> 저장버튼 눌렀을 때 파이어베이스로 저장하기 */
  Future<void> SaveAction(context)  async {

    /* 유효성 검사 */
    // 1. 최소 1개 이상의 구절 선택
    if(dirary_screen_selected_verses_id.length <= 1){
      DiaryDialog(context, "최소 1개 이상의 성경 구절을 선택해주세요");
    }else{
      /* 유효성검사를 통과했으므로 정상적인 저장 프로세스 진행 */
      /* 이때, "신규저장"인지 "수정"인지에 따라 액션 구분 */
      Save_check_Dialog(context); // 저장할건지 묻는 안내창 팝
    }
  }


  /* <함수> 삭제버튼 눌렀을 때 파이어베이스로 저장하기 */
  Future<void> DeleteAction(Docid, index)  async {
    /* 파이어스토어에서 삭제 */
    collection.doc(Docid).delete();
    /* 지우고 DB재조회 하지말고, 불러온 리스트에서만 수정하자 */
    diary_view_contents.removeAt(index);
    // 일기 리스트 다시 불러오기
    LoadAction();
    // 달력페이지 다시 불러오기
    calendar_data_mapping();
    // 일기view 페이지로 돌아가기
    //Get.offAll(() => DiaryViewPage());

    Get.back();
    //Get.off(DiaryViewPage());
    //Get.offNamedUntil('/DiaryTabPage', (route) => false);
  }


  /* <함수> 개인별 일기 데이터 로드하기 */
  Future<void> LoadAction() async {
    // 로딩화면 띄우기
    EasyLoading.show(status: 'loading...');

    /* 데이터 로드(조건) */
    collection
        .where("uid", isEqualTo: MyCtr.uid) // 본인이 작성한 글만 보이게
        /* 설정된 년 & 월 범위에서만 일기 검색한다 */
        //.where("dirary_screen_selectedDate", isGreaterThanOrEqualTo: DateTime(diary_view_selected_year,diary_view_selected_month)) // 선택된 날짜에 맞는 일기만 보여주기
        //.where("dirary_screen_selectedDate", isLessThan: DateTime(diary_view_selected_year,diary_view_selected_month+1)) // 선택된 날짜에 맞는 일기만 보여주기
        .orderBy("dirary_screen_selectedDate", descending:true) // 날짜로 내림차순 정렬
        //.orderBy("updated_at", descending:true) // 업데이트순서로 내림차순 정렬

        /* ↓정상적으로 로드가 되었다면 아래 수행↓ */
        .get().then((QuerySnapshot ds) async {
          /*  불러온 데이터 할당 */
          diary_view_contents          = ds.docs;

          /* 오늘작성한 일기 있는지 체크 */
          diary_view_today_diary_count = 0; // 오늘 작성한 일기가 몇개인지 카운트
          for(int i = 0; i < diary_view_contents.length; i++){
            /* 오늘작성한 일기 있는지 체크 */
            var selectedDate = diary_view_contents[i]["dirary_screen_selectedDate"].toDate(); // DB에서 불러온 날짜 Timestamp ==> Date로 변환
            /* 오늘과 일치하는 일기 날짜가 있는지 체크 */
            if(DateTime(selectedDate.year,selectedDate.month,selectedDate.day)==DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day)){
              diary_view_today_diary_count += 1;
            }
          }
          /* 성경구절 ID에 맞는 구절 DATA를 DB에서 조회해서 가져오기 */
          // 0 . 임시 저장공간생성
          temp_verses_id_list = [];
          // 1. 성경구절 id 합쳐주기
          for(int i = 0; i < diary_view_contents.length; i++){
            temp_verses_id_list.addAll(diary_view_contents[i]['dirary_screen_selected_verses_id']);
          }
          // 2. 성경구절 id 중복제거
          temp_verses_id_list = temp_verses_id_list.toSet().toList();
          // 3. DB에서 조회
          diary_view_selected_contents_data = await BibleRepository.GetClickedVerses(temp_verses_id_list, BibleCtr.Bible_choiced);

          /* 쿼리 + 날짜 필터 결과 적용 */
          result_filtering();

          // 달력페이지 다시 불러오기
          calendar_data_mapping();

          // 로딩화면 종료
          EasyLoading.dismiss();

        }
    );// 필드명에 단어 포함


    /* 데이터 로드(단순) _ 이거는 필요없는데, 이걸 넣어줘야 오류가 안남??...ㅜ 이유는 몰겠음..*/
    var documentSnapshot = await collection.doc("diary").get();

    update();

  }

  /* <함수> 설정에서 성경이 변경되었을 경우, 리로드 하는 모듈 */
  Future<void> Bilbe_reload() async {
    diary_view_selected_contents_data = await BibleRepository.GetClickedVerses(temp_verses_id_list, BibleCtr.Bible_choiced);
  }

  /* <함수> 현재시간과의 시간차이 산출 _ 현재와의 시간차이 구하기 ( 방금_1분이내, xx시간전, xx일전, xx달전, xx년전 으로 구분 ) */
  String cal_time_differ(date){
    // 현재 시간
    var _toDay = DateTime.now();
    // 비교시간을 timestamp -> date로 형식 변환
    var target_date = date.toDate();
    // 날짜 표기방식(#format, #포맷 )
    var newFormat = DateFormat("M월 d일");
    // 1. 시간 산출결과 임시 저장공간
    var time_differ = "";
    // 2. 시간차이 계산 ( 분 기준으로 )
    int time_difference = int.parse(_toDay.difference(target_date).inMinutes.toString());
    // 3. 조건에 맞게 시간 재지정
    if(time_difference<=0){time_differ = "방금 전";} // 1분 미만
    else if (0 <= time_difference &&  time_difference < 60){time_differ = "${time_difference}분 전";} // 1시간 미만
    else if (60 <= time_difference &&  time_difference < 60*24){time_differ = "${(time_difference/60).floor()}시간 전";} // 1일 미만
    else if (60*24 <= time_difference &&  time_difference < 60*24*7){time_differ = "${(time_difference/(60*24)).floor()}일 전";} // 1주일 미만
    else if (60*24*7 <= time_difference){time_differ = "${newFormat.format(target_date)}";} // 1주일 초과 시, 날짜 그대로 표현
    //else if (60*24 < time_difference &&  time_difference < 60*24*30){time_differ = "${(time_difference/(60*24)).round()}일 전";} // 1달 미만
    //else if (60*24*30 < time_difference &&  time_difference < 60*24*30*12){time_differ = "${(time_difference/(60*24*30)).round()}달 전";} // 1년 미만
    //else if (60*24*30*12 < time_difference){time_differ = "${(time_difference/(60*24*30*12)).round()}년 전";} // 1년 초과


    /* 결과 리턴 */
    return time_differ;
    }

  /* <함수> 일기쓰지 페이지 초기화 */
  void diray_write_screen_init(){
    dirary_screen_selected_verses_id = [99999];
    dirary_screen_selectedDate       = DateTime.now();
    dirary_screen_color_index        = 0; //
    dirary_screen_emoji_index        = 0; //
    TitletextController.text         = "";
    ContentstextController.text      = "";
    choiced_image_file               = [File(""),File(""),File("")];
    dirary_screen_timetag_index      = 0;
    dirary_screen_weather_index      = 0;
    dirary_screen_emoticon_index     = 0;
    dirary_screen_address            = "";
    HashTagController.text           = "";

    update();
  }
  /* <함수> 작성중인 내용이 있는지 확인하는 모듈 */
  bool IsWriting(){
    /* 작성중인 내용이 있는지 확인 */
    var check_score = 0; // 1점이상인 경우, 바뀐게 있는거임
    if(dirary_screen_selected_verses_id.length != 1){check_score+=1;}
    //if(dirary_screen_selectedDate       != DateTime.now()){check_score+=1;} // 날짜는 초단위로 바껴서 비교하기가 좀 빡세네
    if(dirary_screen_color_index        != 0){check_score+=1;}
    if(dirary_screen_emoji_index        != 0){check_score+=1;}
    if(TitletextController.text         != ""){check_score+=1;}
    if(ContentstextController.text      != ""){check_score+=1;}
    if(dirary_screen_timetag_index      != 0){check_score+=1;}
    if(dirary_screen_weather_index      != 0){check_score+=1;}
    if(dirary_screen_emoticon_index     != 0){check_score+=1;}
    if(dirary_screen_address            != ""){check_score+=1;}
    if(HashTagController.text           != ""){check_score+=1;}
    // 이상하게 계속 1점이 나온다,..??!!!!
    if(choiced_image_file               != [File(""),File(""),File("")]){check_score+=1;}

    /* 작성중인 내용이 있는경우, 팝업 띄우기 */
    if(check_score>1){
      return true;
    } else {
      return false;
    }

  }


  /* <함수> 모드선택 ( 신규(new) 또는 수정(modify) ) */
  void select_NewOrModify(String mode){
    NewOrModify = mode;
    update();
  }

  /* <함수> 일기 내용 수정버튼 눌렀을 떄 보여줄 데이터 맵핑 */
  Future<void> diary_modify_call(int index) async {
    /* 모드선택 ( 신규(new) 또는 수정(modify) ) */
    select_NewOrModify("modify");
    /* 선택한 파이어스토어 문서 번호_아이디(documentID) 저장 */
    selected_document_id = diary_view_contents[index].id;

    /* 데이터 입혀주기 */
    dirary_screen_selected_verses_id = diary_view_contents[index]['dirary_screen_selected_verses_id'].cast<int>();
    dirary_screen_selectedDate       = diary_view_contents[index]['dirary_screen_selectedDate'].toDate();
    dirary_screen_color_index        = diary_view_contents[index]['dirary_screen_color_index'];
    dirary_screen_title              = diary_view_contents[index]['dirary_screen_title'];
    dirary_screen_contents           = diary_view_contents[index]['dirary_screen_contents'];
    dirary_screen_timetag_index      = diary_view_contents[index]['dirary_screen_timetag_index'];
    dirary_screen_weather_index      = diary_view_contents[index]['dirary_screen_weather_index'];
    dirary_screen_emoticon_index     = diary_view_contents[index]['dirary_screen_emoticon_index'];
    dirary_screen_address            = diary_view_contents[index]['dirary_screen_address'];
    //dirary_screen_emoji_index        = diary_view_contents[index]['dirary_screen_emoji_index'];

    /* 선택한 구절 DB 조회 */
    selected_contents_data = await BibleRepository.GetClickedVerses(dirary_screen_selected_verses_id, BibleCtr.Bible_choiced);
    /* 더미(99999) 다시 넣기 */
    dirary_screen_selected_verses_id.add(99999);

    /* 제목 & 내용 삽입 */
    TitletextController.text     = diary_view_contents[index]['dirary_screen_title'];
    ContentstextController.text  = diary_view_contents[index]['dirary_screen_contents'];

    /* 해시태그 입혀주기 */

    var temp = ""; /* 태그 텍스트 저장공간(임시) */

    var target = diary_view_contents[index]['dirary_screen_hashtag']; /* 태그만으로 구성된 리스트 가져오기 */
    /* 태그 텍스트로 변경 */
    for(int i = 0; i < target.length; i++){
      temp = temp + " " + target[i];}
    /* 클리닝된 텍스트를 대신 삽입해주기 */
    HashTagController.text = temp;


    /* 작성하기 페이지로 이동 */
    Get.to(() => DiaryWriteScreen());

    /* 사진 URL 삽입(3개 갯수 맞춰야하므로 바로 할당하지 않고, For문으로 하나씩 할당) */
    //1. 리스트 초기화
    choiced_image_file = ["","",""];
    //2. 리스트 입히기
    var temp_image_list = diary_view_contents[index]['choiced_image_file'];
    for(int i = 0; i < temp_image_list.length; i++){
      choiced_image_file[i] = temp_image_list[i];
    }
    update();
  }

  /* <함수> 일기 내용 "수정"상태에서 "저장" 눌렀을 떄 */
  Future<void> diary_modify_save() async {
    // 로딩화면 띄우기
    EasyLoading.show(status: 'loading...');



    /* 사진 이름만들기 + 파이어베이스 저장 + 호출 경로 만들기 */
    var docID = selected_document_id; // 수정 문서 번호 입력
    var ImgUrl = []; // 최종 파일 downloadURL 이 저장될 공간
    for(int i = 0; i < choiced_image_file.length; i++){
      /* 이미지 경로가 비어있지 않다면 */
      var _imageFile = choiced_image_file[i]; // 이미지 파일 할당
      var type = _imageFile.runtimeType;
      /* 1. 이미지데이터가 String*(URL)인 경우, 수정된게 없는 상태이므로 경로만 그대로 추가해준다 */
      if(type == String){
        if(_imageFile != "") { // 빈경로가 아닌경우만 추가한다.
          /* 경로 추가해주기 */
          ImgUrl.add(_imageFile);
        }
      }else{
      /* 2. 이미지데이터가 File인 경우, 수정되었으므로 파이어스토어에 업로드 후, 다운경로를 추가해준다. */
        if(_imageFile.path.isEmpty == false){ // 빈경로가 아닌경우만 추가한다.


          /* <함수> 파이어베이스 파일업로드 및 파일 호출경로 받는 함수 */
          /* 경로 만들기 */
          var ImgSavePath = "${'diaryImg/${MyCtr.uid}/$docID/$i'}"; // 사용자UID → 문서ID → 이미지 순서 로 저장한다
          /* 파이어베이스 storage에 이미지 파일 업로드(https://firebase.flutter.dev/docs/storage/usage/) */
          try {
            /* 파이어베이스 스토리지 객체 가져오기 */
            await firebase_storage.FirebaseStorage.instance
                .ref()
                .child(ImgSavePath) // 저장 경로 설정, 파일이름은$docID/$i로 한다. 최대 3개만 저장가능하도록
                .putFile(_imageFile); // 저장할 이미지 파일 지정
          } on FirebaseException catch (e) {
            // e.g, e.code == 'canceled'
          }
          /* 위에서 저장한 이미지를 불러올 수 있는 URL 가져오기 */
          String downloadURL = await firebase_storage.FirebaseStorage.instance
              .ref(ImgSavePath)
              .getDownloadURL();


          /* 경로 모아주기 */
          ImgUrl.add(downloadURL);
        }else{
          /* 이미지 경로가 비어있다면 */
          null;
        }
      }
    }
    /* 더미데이터(99999) 제거(임시) */
    dirary_screen_selected_verses_id.remove(99999);

    /* 데이터 세이브 */
    collection.doc(selected_document_id).update({
      "updated_at":DateTime.now(), // 수정 시간
      "dirary_screen_selected_verses_id": dirary_screen_selected_verses_id, // 더미 데이터 삭제
      "dirary_screen_selectedDate": dirary_screen_selectedDate,
      "dirary_screen_color_index": dirary_screen_color_index,
      "dirary_screen_emoji_index": dirary_screen_emoji_index,
      "dirary_screen_title": dirary_screen_title,
      "dirary_screen_contents":dirary_screen_contents,
      "choiced_image_file":ImgUrl,
      "dirary_screen_timetag_index":dirary_screen_timetag_index,
      "dirary_screen_weather_index":dirary_screen_weather_index,
      "dirary_screen_emoticon_index":dirary_screen_emoticon_index,
      "dirary_screen_address":dirary_screen_address,
      "dirary_screen_hashtag":get_hash_tag_list(),
    }).then((value) {
      /* 저장이 완료된 후에,, */
      PopToast("일기가 수정되었어요!");
      // 일기 리스트 다시 불러오기
      LoadAction();
      // 일기 작성페이지 초기화
      diray_write_screen_init();
      update();
      // 로딩화면 종료
      EasyLoading.dismiss();
      //안내 메세지
      PopToast("수정 안료");
      });

  }

  /* <함수> 사진첩("gallery") 또는 카메라("camera") 모드 선택 */
  void GalleryOrCam_choice(String mode){
    GalleryOrCam = mode;
    update();
  }


  /* <함수> 일기 정보 달력에 맵핑해주기 (https://pub.dev/packages/syncfusion_flutter_calendar)*/
  void calendar_data_mapping(){
    //초기화
    meetings = [];
    // "Meeting"클래스에 데이터를 담고, "meetings"리스트에 쌓기
    for(int i = 0; i < diary_view_contents.length; i++){
      var index = i;
      var contents = diary_view_contents[i]["dirary_screen_title"] ;
      var date = diary_view_contents[i]["dirary_screen_selectedDate"].toDate();
      var date_convert = DateTime(date.year, date.month, date.day);
      var color = ColorCode[diary_view_contents[i]["dirary_screen_color_index"]];
      //"meetings"리스트에 쌓기
      meetings.add(Meeting(i, contents, date_convert, date_convert, color, true));
    }
  }


  /* <함수> 해시태그 가져와서 태그만 분류하기(https://pub.dev/packages/hashtager) */
  List<String> get_hash_tag_list(){
    /* 컨트롤러로부터 텍스트 가져오기 */
    var target = HashTagController.text;
    /* 해시태그만 추출하기(리스트) */
    final List<String> hashTags = extractHashTags(target);
    /* 추출된 태그만 리턴 */
    return hashTags;
  }

  /* <함수> 해시태그 클리닝 _ 태그만 남기고 다 지우기 */
  void hash_tag_cleaning(){
    /* 태그 텍스트 저장공간(임시) */
    var temp = "";
    /* 태그만으로 구성된 리스트 가져오기 */
    var target = get_hash_tag_list();
    /* 태그 텍스트로 변경 */
    for(int i = 0; i < target.length; i++){
      temp = temp + " " + target[i];
    }
    /* 클리닝된 텍스트를 대신 삽입해주기 */
    HashTagController.text = temp;

  }

  /* <함수> 성경일기 뷰 페이지 _ "그리드뷰(grid view) 또는 리스트뷰(list view)선택" */
  void ViewMode_change(String mode){
    /* 설정값 적용 */
    diary_view_ViewMode = mode;
    /* 설정값 저장 */
    SavePrefsData();
    update();
  }

  /* <함수> 성경작성(write)_페이지 _ 선택된 날짜로 변경 함수 */
  void SelectedDate_change(){
    /* 선택된 날짜로 업데이트 */
    dirary_screen_selectedDate = datePickerController.selectedDate!;
    update();
  }

  /* <함수> 성경작성(write)_페이지 _ 선택된 날짜로 변경 함수 */
  void SelectedDate_change_from_calendar(context){
    /* 선택된 날짜로 업데이트 */

    /* 1.선택된 날짜가 없는 경우, */
    if(calendarController.selectedDate == null){
      DiaryDialog(context, "날짜를 선택해주세요.");
    }else{
    /* 2.선택된 날짜가 있는 경우, */
      // 선택된 날짜로 셋팅
      dirary_screen_selectedDate = calendarController.selectedDate!;
      // 일기 쓰기 페이지로 이동하기
      Get.to(() => DiaryWriteScreen());
    }
    update();
  }

  /* <함수> 날짜를 요일로 변경하는 함수 */
  String ConvertWeekday(int weekday){
    var result = "";
    switch(weekday){
      case 1 : result = "월"; break;
      case 2 : result = "화"; break;
      case 3 : result = "수"; break;
      case 4 : result = "목"; break;
      case 5 : result = "금"; break;
      case 6 : result = "토"; break;
      case 7 : result = "일"; break;
    }
    return result;
  }


  //<함수> 기초 통계 ( 이번달 몇건, 올해 몇건 등등 )
  void cal_basic_statistics(){
    var now = DateTime.now();

    /* 이번달(month) 통계 구하기 */
    //0. 이번 달 총 몇일인지 구하기
    int MonthDayCount = int.parse(
        DateTime(now.year, now.month+1, 0).difference(DateTime(now.year, now.month, 1)).inDays.toString()
    );
    //1. 임시 저장공간 만들기
    var temp_month_list= [];
    //2. 이번달 구하기
    var this_month = now.month;
    //3. 이번달에 일기의 서로다른 날짜 갯수 구하기
    for(int i = 0; i < diary_view_contents.length; i++){
      var date = diary_view_contents[i]["dirary_screen_selectedDate"].toDate();
      //3-1. 이번달 일기가 맞다면,
      if(date.month == this_month){
        temp_month_list.add(date.day);
      }
    }
    //4. 일(day)중복제거
    temp_month_list = temp_month_list.toSet().toList();
    //5. 결과 정리
    statistics_this_month = now.month;
    statistics_month_percent = (temp_month_list.length/MonthDayCount);
    statistics_month_string = "${temp_month_list.length}일/${MonthDayCount}일 (${(statistics_month_percent*100).toStringAsFixed(1)}%)";

    /* 이번 년도(year) 통계 구하기 */
    //0. 이번 년도 총 몇일인지 구하기
    int YearCount = int.parse(
        DateTime(now.year+1, 1, 1).difference(DateTime(now.year, 1, 1)).inDays.toString()
    );
    //1. 임시 저장공간 만들기
    var temp_year_list= [];
    //2. 이번 년도 구하기
    var this_year = now.year;
    //3. 이번 년도에 일기의 서로다른 날짜 갯수 구하기
    for(int i = 0; i < diary_view_contents.length; i++){
      var date = diary_view_contents[i]["dirary_screen_selectedDate"].toDate();
      //3-1. 이번달 일기가 맞다면,
      if(date.year == this_year){
        temp_year_list.add("${date.month}/${date.day}");
      }
    }
    //4. 일(day)중복제거
    temp_year_list = temp_year_list.toSet().toList();
    //5. 결과 정리
    statistics_this_year = now.year;
    statistics_year_percent = (temp_year_list.length/YearCount);
    statistics_year_string = "${temp_year_list.length}일/${YearCount}일 (${(statistics_year_percent*100).toStringAsFixed(1)}%)";

  }

  /* 검색결과 필터링 *///diary_view_selected_contents_data
  void result_filtering(){
    // 1. 결과 저장용 임시공간
    var QueryString = DiarySearchController.text;
    diary_view_contents_filtered_index = []; // 필터링 결과 초기화
    // 2. 각 결과 순환하면서 조건에 맞는 값 가져오기
    // 2-1. 쿼리("Query")문 + 날짜 필터
    for(int i = 0; i < diary_view_contents.length; i++){
      var u = diary_view_contents[i];
      var selectedDate = u['dirary_screen_selectedDate'].toDate(); // DB에서 불러온 날짜 Timestamp ==> Date로 변환
      /* "검색"필터 + "날짜"필터 적용 */
      if((u['dirary_screen_title'].contains(QueryString) | u['dirary_screen_contents'].contains(QueryString))
      &(DateTime(selectedDate.year,selectedDate.month)==DateTime(diary_view_selected_year,diary_view_selected_month))
      ){
        // 3. 결과 쌓아주기(인덱스번호만)
        diary_view_contents_filtered_index.add(i);
      }
    }

    // 4. 경과 시간 재산출하기
    diary_view_timediffer = []; // 시간 경과 저장 리스트 초기화
    for(int i = 0; i < diary_view_contents.length; i++){
      /* 1. 시간경과 산출(마지막으로 수정된 시간기준) */
      diary_view_timediffer.add(cal_time_differ(diary_view_contents[i]["updated_at"]));
    }
    update();
  }

  /* <함수> 성경 뷰페이지 _ 년도 & 월 최종 선택 */
  void ViewPage_Date_Select_Confirm(int year, int month){
    /* 유저가 선택한 날짜 값이 변했는지 확인 */
    if((diary_view_selected_year != year)
    | (diary_view_selected_month != month)
    ){
      /* 값이 변한게 맞는 경우에, */
      /* 1. 유저가 선택한 날짜로 최종 입력 */
      diary_view_selected_year = year;
      diary_view_selected_month = month;
      /* 2. 선택된 날짜정보에 맞게 일기 재조회 */
      result_filtering();
      /* 3. 상태값 업데이트 */
      update();
    }
  }


} // 여기가 전체 클래스 끝 부분!!






/* <서브 클래스> 달력정보만들기에 필요한 클래스 정의 */
class Meeting {
  Meeting(this.index, this.eventName, this.from, this.to, this.background, this.isAllDay);

  /* <변수> 클래스 데이터 멤버 정의 */
  int index;
  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;

  /* <함수> 클래스 인스턴스에서 변수를 가져오기 위한 함수 정의 */
  int get get_index => index;
}