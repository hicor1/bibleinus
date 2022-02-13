import 'dart:ui';
import 'package:bible_in_us/bible/bible_component.dart';
import 'package:bible_in_us/bible/bible_controller.dart';
import 'package:get/get.dart';
import 'package:bible_in_us/bible/bible_repository.dart';

final BibleCtr = Get.put(BibleController());

class DiaryController extends GetxController {

  //<함수> 초기화
  void init(){

  }

  /* <변수>정의 */
  var dirary_screen_address = ""; // 성경일기 작성 페이지 _ 선택된 주소
  var dirary_screen_color_index = 0; // 성경일기 작성 페이지 _ 선택된 색깔 인덱스
  var dirary_screen_timetag_index = 0; // 성경일기 작성 페이지 _ 선택된 시간태그 인덱스

  var dirary_screen_selected_verses_id = [99999]; // 성경일기 작성 페이지 _ 선택된 구절 인덱스 리스트

  var selected_contents_id        = [1,2]; // 선택된 구절 아이디
  var Temp_selected_contents_id   = 0; // 구절 id 수정을 위한  선택된 구절 아이디값 임시저장
  var mode_select                 = ""; // "add" or "replace" 중 모드 선택
  var selected_contents_data      = []; // DB에서 조회한 선택된 구절 정보 담는공간

  /* 칼라코드 정의 */
  var ColorCode = [Color(0xFFBFBFBF), // 젤 처음은 흑백 칼라
    Color(0xFFffd700).withOpacity(0.8),
    Color(0xFF00bfff).withOpacity(0.8),
    Color(0xFF32cd32).withOpacity(0.8),
    Color(0xff9966ff).withOpacity(0.8),
    Color(0xFFF781D8).withOpacity(0.8),

    Color(0xFFFFBF00).withOpacity(0.8),
    Color(0xFF6495ED).withOpacity(0.8),
    Color(0xFF9FE2BF).withOpacity(0.8),
    Color(0xFFE9967A).withOpacity(0.8),
    Color(0xFFFFA07A).withOpacity(0.8),
    Color(0xFFE9967A).withOpacity(0.8),

    Color(0xFF808000).withOpacity(0.8),
    Color(0xFF008000).withOpacity(0.8),
    Color(0xFF008080).withOpacity(0.8),
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
    /* 더미(99999) 다시 넣기 */
    dirary_screen_selected_verses_id.add(99999);
    /* 선택한 구절 DB 조회 */
    selected_contents_data = await BibleRepository.GetClickedVerses(dirary_screen_selected_verses_id, BibleCtr.Bible_choiced);
    update();
  }

  //<함수> 선택한 구절 id 삭제하고 DB 재조회 하기
  Future<void> remove_verses_id (int id) async {
    /* 선택한 구절 id 담기 */
    dirary_screen_selected_verses_id.remove(id);
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

}