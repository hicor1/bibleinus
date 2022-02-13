import 'dart:ui';

import 'package:bible_in_us/bible/bible_controller.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:bible_in_us/bible/bible_repository.dart';

final BibleCtr = Get.put(BibleController());

class DiaryController extends GetxController {

  /* <변수>정의 */
  var dirary_screen_address = ""; // 성경일기 작성 페이지 _ 선택된 주소
  var dirary_screen_color_index = 0; // 성경일기 작성 페이지 _ 선택된 색깔 인덱스
  var dirary_screen_timetag_index = 0; // 성경일기 작성 페이지 _ 선택된 시간태그 인덱스

  var selected_contents_id   = [1,2]; // 선택된 구절 아이디
  var selected_contents_data = []; // 선택된 구절 정보 담는공간

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
    print(dirary_screen_address);
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

  //<함수> 성경일기 작성스크린 _ ID로 성경구절 가져오기
  Future<void> GetClickedVerses() async {
    /* DB에서 정보 받아오기 */
    selected_contents_data = await BibleRepository.GetClickedVerses(selected_contents_id, BibleCtr.Bible_choiced);
    update();
  }

}