import 'package:bible_in_us/bible/bible_component.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class MyController extends GetxController {


  /* <변수>정의 */
  var email        = "";
  var displayName  = "";
  var photoURL     = "";
  var providerId   = "";

  /* <함수> 유저정보 가져오기 */
  void Get_User_info(){
    /* 파이어베이스 유저 객체 가져오기 */
    final FirebaseAuth auth = FirebaseAuth.instance; // 유저 객체 가져오기
    final User? user = auth.currentUser;// 유저 전체 정보 가져오기

    /* 유저정보 맵핑 */
    email       = user!.email!;
    displayName = user.displayName!;
    photoURL    = user.photoURL ?? "https://www.rentit.kr/static/images/profile.jpg"; // 사진이 없을 경우 임의의 사진 띄워준다
    providerId  = user.providerData[0].providerId;

    update();
  }


  /* <함수> 닉네임 변경하기 */
  Future<void> Change_displayName(context, displayName) async {
    // 로딩화면 띄우기
    EasyLoading.show(status: 'loading...');

    /* 파이어베이스 유저 객체 가져오기 */
    final FirebaseAuth auth = FirebaseAuth.instance; // 유저 객체 가져오기
    final User? user = auth.currentUser;// 유저 전체 정보 가져오기

    /* 닉네임 업데이트 모듈 */
    await user!.updateDisplayName(displayName);

    /* 유저정보 다시 가져오기 */
    Get_User_info();

    //모달창 닫기
    Navigator.pop(context);

    /* 변경완료 토스트(toast) 띄우기 */
    PopToast("닉네임 변경이 완료되었습니다.");

    // 로딩화면 종료
    EasyLoading.dismiss();
  }


}