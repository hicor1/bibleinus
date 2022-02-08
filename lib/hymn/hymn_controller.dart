
import 'package:bible_in_us/general/general_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bible_in_us/hymn/hymn_repository.dart';
import 'package:intl/intl.dart';


// Gex컨트롤러 객체 초기화
final GeneralCtr = Get.put(GeneralController());

class HymnController extends GetxController {

  /* <변수> 각종 변수 정의  */
  var hymn_type_count        = []; // 찬송가 타입별 갯수 받아오기
  var hymn_list              = []; // 조건에 맞는 찬송가 조회해서 받아오기
  var selected_type_name     = "송영"; // 사용자가 선택한 타입(type)이름
  var selected_hymn_name     = "만복의 근원 하나님"; // 사용자가 선택한 찬송가 이름
  var selected_hymn_number   = 1; // 사용자가 선택한 찬송가 번호
  var selected_hymn_path     = "assets/img/hymns/newhymn-001.jpg"; // 사용자가 선택한 찬송가 이미지 경로

  /* 컨트롤러 정의 */
  var searchtextController = TextEditingController(); // 메인 검색어 컨트롤러
  late TabController tabController; // 메인페이지 탭 컨트롤러 정의


  // <함수> 선택한 타입(type) 입력해주기
  void type_update (String type) {
    selected_type_name = type;
    update();
  }

  // <함수>찬송가 메인페이지 _ 타입별 갯수 가져오기( 빈값은 없는게 아닌, 0으로 리턴되도록 쿼리수정했음! )
  Future<void> Get_type_count(String query) async {
    // 1. DB 조회
    hymn_type_count = await HymnRepository.Get_type_count(query);
    //2. 찬송가 리스트 업데이트
    Get_Hymn_list(query);
    update();
  }

  // <함수>찬송가 메인페이지 _ 조건에 맞는 찬송가 리스트 가져오기
  Future<void> Get_Hymn_list(String query) async {
    hymn_list = await HymnRepository.Get_Hymn_list(selected_type_name, query);
    update();
  }

  // <함수> 찬송가 클릭 이벤트 ( 찬송가 번호로 이미지 찾기 )
  void hymn_click (int number, String hymn_name) {
    /* 클릭한 찬송가 정보업데이트 */
    selected_hymn_number = number;
    selected_hymn_name   = hymn_name;
    /* 클릭한 찬송가 이미지 경로 정보업데이트 */
    //1. 포맷 변경 ( ex: 29 -> 029 )
    var formatted_selected_hymn_number = NumberFormat('000').format(selected_hymn_number);
    //2. 경로 만들기
    selected_hymn_path   =  "assets/img/hymns/newhymn-$formatted_selected_hymn_number.jpg";// 예) "assets/img/hymns/newhymn-020.jpg"
    //3. "악보" tab으로 이동
    tabController.animateTo(1);
    update();
  }

}