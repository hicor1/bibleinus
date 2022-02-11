

// 검색 글자수 모자람 경고창 띄우기
import 'package:flutter/material.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:fluttericon/entypo_icons.dart';

void FlutterDialog(context) {
  showDialog(
      context: context,
      //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
      barrierDismissible: false,
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
                onTap: (){},
                child: Row(
                  children: [
                    Icon(Entypo.picture, color: Colors.grey),
                    Text("    새 이미지 선택"),
                  ],
                ),
              ),

              /* 사회적 거리두리 */
              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 10),

              /* 이미지 제거 */
              InkWell(
                onTap: (){},
                child: Row(
                  children: [
                    Icon(Elusive.trash, color: Colors.grey),
                    Text("    이미지 제거"),
                  ],
                ),
              ),
            ],
          ),
        );
      });
}