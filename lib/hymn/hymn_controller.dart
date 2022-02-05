
import 'package:bible_in_us/general/general_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bible_in_us/hymn/hymn_repository.dart';


// Gex컨트롤러 객체 초기화
final GeneralCtr = Get.put(GeneralController());

class HymnController extends GetxController {

  /* <변수> 각종 변수 정의  */
  var hymn_type_count_init   = []; // 찬송가 타입별 갯수 받아오기
  var hymn_list              = []; // 조건에 맞는 찬송가 조회해서 받아오기
  var selected_type          = "송영";

  /* 컨트롤러 정의 */
  var searchtextController = TextEditingController(); // 메인 검색어 컨트롤러
  late TabController tabController; // 메인페이지 탭 컨트롤러 정의


  // <함수> 선택한 타입(type) 입력해주기
  void type_update (String type) {
    selected_type = type;
    update();
  }

  // <함수>찬송가 메인페이지 _ 타입별 갯수 가져오기 ( 초반 _ init _ 표만들기용 )
  Future<void> Get_type_count_init(String query) async {
    hymn_type_count_init = await HymnRepository.Get_type_count(query);
    update();
  }


  // <함수>찬송가 메인페이지 _ 조건에 맞는 찬송가 리스트 가져오기
  Future<void> Get_Hymn_list(String query) async {
    hymn_list = await HymnRepository.Get_Hymn_list(selected_type, query);
    print(hymn_list);
    update();
  }

}