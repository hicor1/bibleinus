import 'package:bible_in_us/general/general_controller.dart';
import 'package:bible_in_us/hymn/hymn_controller.dart';
import 'package:bible_in_us/my/my_controller.dart';
import 'package:bible_in_us/my/my_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';  //
import 'package:flutter/material.dart';
import 'package:fluttericon/linearicons_free_icons.dart';
import 'package:get/get.dart';

// Gex컨트롤러 객체 초기화
final GeneralCtr = Get.put(GeneralController());
final MyCtr = Get.put(MyController());

// 해당 페이지에서만 사용하는 일반 변수들 정의
var Icon_text_space = 10.0; // 아이콘과 텍스트 사이 벌어진 거리

/* <메인 위젯> 메인 위젯 뿌리기 */
class MyMainPage extends StatelessWidget {
  const MyMainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /* 유저 기본정보 불러오기 */
    MyCtr.Get_User_info();

    /* GetX컨트롤러 불러오기 */
    return GetBuilder<MyController>(
        init: MyController(),
        builder: (_){
          return MainWidget(); //return은 필수
        }
    );
  }
}


/* <서브위젯> 메인 위젯 정의 */
class MainWidget extends StatelessWidget {
  const MainWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('프로필', style: GeneralCtr.Style_title),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: Column(
            children: [

              /* 프로필 보여주기 */
              Column(
                children: [
                  /* 프로필 이미지 */
                  Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      width: 100.0,
                      height: 100.0,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              fit: BoxFit.fill,
                              image: NetworkImage("${MyCtr.photoURL}")
                          )
                      )
                  ),
                  /* 닉네임 */
                  Text("${MyCtr.displayName}", style: TextStyle(color: Colors.black, fontSize: GeneralCtr.fontsize_normal)),
                ],
              ),

              /* 사회적 거리두기 */
              SizedBox(height:30),

              /* 프로필 변경 버튼 */
              Column(
                children: [
                  Row(
                    children: [
                      Icon(LineariconsFree.exit, color: Colors.grey, size: 20),
                      SizedBox(width: Icon_text_space),
                      TextButton(
                          onPressed: (){
                            /* 프로필 스크린으로 이동 */
                            Get.to(() => MyProfileScreen());
                          },
                          child: Text("프로필 변경하기", style: TextStyle(color: Colors.black54, fontSize: GeneralCtr.fontsize_normal)))
                    ],
                  ),
                  Divider(),
                ],
              ),

              /* 로그아웃 버튼 */
              Column(
                children: [
                  Row(
                    children: [
                      Icon(LineariconsFree.exit, color: Colors.grey, size: 20),
                      SizedBox(width: Icon_text_space),
                      TextButton(
                          onPressed: (){FirebaseAuth.instance.signOut();},
                          child: Text("로그아웃", style: TextStyle(color: Colors.black54, fontSize: GeneralCtr.fontsize_normal)))
                    ],
                  ),
                  Divider(),
                ],
              ),
            ],
          ),
        )
    );
  }
}

