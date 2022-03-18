import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeneralController extends GetxController {

    /* SharedPrefs 저장하기(save) */
    Future<void> SavePrefsData() async {
        //1. 객체 불러오기
        final prefs = await SharedPreferences.getInstance();
        //2. 상태값 저장할 목록 및 저장 수행
        prefs.setDouble('Textsize', Textsize);
        prefs.setDouble('Textheight', Textheight);
    }

    /* SharedPrefs 불러오기(load) */
    Future<void> LoadPrefsData() async {

        //1. 객체 불러오기
        final prefs = await SharedPreferences.getInstance();
        //2. 불러올 상태값 목록 및 데이터 업데이트
        Textsize   = prefs.getDouble('Textsize') == null ? Textsize : prefs.getDouble('Textsize')!;
        Textheight = prefs.getDouble('Textheight') == null ? Textheight : prefs.getDouble('Textheight')!;
        update(); // 상태업데이트 내용이 반영되어 로딩이 끝났음을 알려줘야함 ㄱㄱ
    }

    /* 메인컬러 정의 */
    var MainColor = Color(0xff9966ff); // 앱 전반적으로 사용될 메인 컬러 # 0xFF9966ff # 969FF3 #00c896
    var GreenColor = Color(0xff00c896); // 앱 전반적으로 사용될 메인 컬러 # 0xFF9966ff # 969FF3 #00c896
    var BlueColor = Color(0xff536dfe); // 블루계열 색상 # 0xff2196f3 # 0xff2196f3 # 0xff2979ff

    /* 메인 텍스트 스타일 정의 */
    var Style_title       = TextStyle(color: Color(0xff9966ff), fontSize: 28, fontWeight: FontWeight.bold);
    var fontsize_normal   = 20.0;

    /* 모달창 텍스트 스타일 */
    var TextStyle_normal_accent = TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w900); // 일반적인 텍스트 스타일 정의
    var TextStyle_normal_disable = TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w300); // 일반적인 텍스트 스타일 정의

    /*  메인에 보여지는 성경구절 스타일 */
    var Textsize = 20.0; // 팝업창에서 설정할 전체 텍스트 사이즈
    var Textheight = 2.0; // 팝업창에서 설정할 전체 텍스트 높이

    var selectedPageIndex = 0; // 현재 선택된 탭

    //<함수> 탭 전환 이벤트
    void PageChanged(index){
        selectedPageIndex = index;
        update();
    }

    //<모듈> 슬라이더를 이용한 글씨크기 변경 함수
    void TextSizeChanged(newvalue){
        Textsize = newvalue;
        update();
    }
    //<모듈> 슬라이더를 이용한 글씨높이 변경 함수
    void TextHeightChanged(newvalue){
        Textheight = newvalue;
        update();
    }

}