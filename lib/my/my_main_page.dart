import 'package:bible_in_us/general/general_controller.dart';
import 'package:bible_in_us/hymn/hymn_controller.dart';
import 'package:bible_in_us/my/my_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';  //
import 'package:flutter/material.dart';
import 'package:fluttericon/linearicons_free_icons.dart';
import 'package:get/get.dart';


//파이어베이스 유저 객체 가져오기
final FirebaseAuth auth = FirebaseAuth.instance; // 유저 객체 가져오기
final User? user = auth.currentUser;// 유저 전체 정보 가져오기
final uid = user!.uid; // 유저 아이디

// Gex컨트롤러 객체 초기화
final GeneralCtr = Get.put(GeneralController());
final HymnCtr = Get.put(HymnController());

// 해당 페이지에서만 사용하는 일반 변수들 정의
var Icon_text_space = 10.0; // 아이콘과 텍스트 사이 벌어진 거리


class MyMainPage extends StatelessWidget {
  const MyMainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {



    return Scaffold(
      appBar: AppBar(
        title: Text('프로필', style: TextStyle(color: GeneralCtr.MainColor, fontSize: 25, fontWeight: FontWeight.bold)),
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
                Image.asset("assets/img/logo/app_icon.png",height: 150),
                Text("${user!.displayName}")
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
                        child: Text("프로필 변경하기", style: TextStyle(color: Colors.grey)))
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
                        child: Text("로그아웃", style: TextStyle(color: Colors.grey)))
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
