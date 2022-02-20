

// 검색 글자수 모자람 경고창 띄우기
import 'package:bible_in_us/general/general_controller.dart';
import 'package:bible_in_us/my/my_main_page.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:get/get.dart';

final GeneralCtr = Get.put(GeneralController());

/* 프로필 이미지 수정 팝업창 */
void FlutterDialog(context) {
  showDialog(
      context: context,
      barrierDismissible: true, //Dialog를 제외한 다른 화면 터치로 창닫기
      builder: (BuildContext context) {
        return AlertDialog(
          // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0)),

          /* 경고창에 들어갈 제목 */
          title: Text("프로필 이미지 수정", textAlign: TextAlign.center),

          /* 경고창에 들어갈 내용 */
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              /* 사회적 거리두리 */
              SizedBox(height: 10),

              /* 새 이미지 선택 */
              InkWell(
                onTap: (){
                  /* 갤러리 이미지피커 모듈 */
                  MyCtr.ProfileImgUpdate(context);
                  
                },
                child: Row(
                  children: [
                    Icon(Entypo.picture, color: Colors.grey, size: GeneralCtr.fontsize_normal),
                    Text("    새 이미지 선택", style: TextStyle(fontSize: GeneralCtr.fontsize_normal)),
                  ],
                ),
              ),

              /* 사회적 거리두리 */
              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 10),

              /* 이미지 제거 */
              InkWell(
                onTap: (){
                  /* 프로필 이미지 삭제 모듈 */
                  MyCtr.ProfileImgDelete(context);
                },
                child: Row(
                  children: [
                    Icon(Elusive.trash, color: Colors.grey, size: GeneralCtr.fontsize_normal),
                    Text("    이미지 제거", style: TextStyle(fontSize: GeneralCtr.fontsize_normal)),
                  ],
                ),
              ),
            ],
          ),
        );
      });
}
