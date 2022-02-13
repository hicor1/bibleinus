import 'dart:io';

import 'package:bible_in_us/bible/bible_component.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart';


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


  /* <함수> 갤러리에서 프로필 이미지 가져와서 업뎃 */
  Future<void> ProfileImgUpdate(context) async {
    // 로딩화면 띄우기
    EasyLoading.show(status: 'loading...');

    /* 파이어베이스 유저 객체 가져오기 */
    final FirebaseAuth auth = FirebaseAuth.instance; // 유저 객체 가져오기
    final User? user = auth.currentUser; // 유저 전체 정보 가져오기

    /* 이미지 피커 객체 불러오기 */
    final ImagePicker _picker = ImagePicker();
    /* 갤러리에서 이미지 선택하기 */
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery); // https://firebase.flutter.dev/docs/storage/usage/
    /* 이미지 파일 임시 할당 */
    var _imageFile = File(image!.path);
    /* 이미지 파일 저장할 이름 */
    var ImgName = user!.uid; // 저장할 파일이름은 사용자 고유번호인, UID로 한다.
    /* 이미지 파일 저장경로 */
    var ImgSavePath = "${'profilePhoto/$ImgName'}"; // 저장 경로 설정, 파일이름은 UID로 한다. 사람당 1개만 저장해줄것이므로

    /* 파이어베이스 storage에 이미지 파일 업로드(https://firebase.flutter.dev/docs/storage/usage/) */
    try {
      /* 파이어베이스 스토리지 객체 가져오기 */
      await firebase_storage.FirebaseStorage.instance
          .ref()
          .child(ImgSavePath) // 저장 경로 설정, 파일이름은 UID로 한다. 사람당 1개만 저장해줄것이므로
          .putFile(_imageFile); // 저장할 이미지 파일 지정
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
    }

    /* 위에서 저장한 이미지를 불러올 수 있는 URL 가져오기 */
    String downloadURL = await firebase_storage.FirebaseStorage.instance
        .ref(ImgSavePath)
        .getDownloadURL();

    /* 프로필 정보에 URL정보 업데이트 해주기 */
    await user.updatePhotoURL(downloadURL);

    /* 유저정보 다시 가져오기 */
    Get_User_info();
    update();

    //모달창 닫기
    Navigator.pop(context);

    /* 변경완료 토스트(toast) 띄우기 */
    PopToast("프로필 이미지를 변경했습니다.");

    // 로딩화면 종료
    EasyLoading.dismiss();
  }

  /* <함수> 프로필 이미지 삭제 */
  Future<void> ProfileImgDelete(context) async {
    // 로딩화면 띄우기
    EasyLoading.show(status: 'loading...');

    // 파이어베이스 스토리지 이미지 삭제 모듈
    try {
      /* 파이어베이스 스토리지에서 이미지 삭제 */
      await firebase_storage.FirebaseStorage.instance
          .refFromURL(photoURL) // 파이어베이스 스토리지에서 이미지 삭제
          .delete().then((_) => print('Successfully deleted $photoURL storage item' ));
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
    }

    /* 유저정보 다시 가져오기 */
    Get_User_info();
    update();

    //모달창 닫기
    Navigator.pop(context);

    /* 변경완료 토스트(toast) 띄우기 */
    PopToast("프로필 이미지를 성공적으로 삭제했습니다.");

    // 로딩화면 종료
    EasyLoading.dismiss();

  }

}