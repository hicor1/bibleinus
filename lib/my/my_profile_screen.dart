
import 'package:bible_in_us/general/general_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


// Gex컨트롤러 객체 초기화
final GeneralCtr = Get.put(GeneralController());

//파이어베이스 유저 객체 가져오기
final FirebaseAuth auth = FirebaseAuth.instance; // 유저 객체 가져오기
final User? user = auth.currentUser;// 유저 전체 정보 가져오기
final uid = user!.uid; // 유저 아이디

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("프로필 변경하기"),
        backgroundColor: GeneralCtr.MainColor,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
        child: Column(
          children: [
            /* 사회적 거리두기 */
            SizedBox(height: 25),

            /* 유저 정보 테이블*/
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("  유저정보"),
                /* 메인 컨테이너 */
                Container(
                  decoration: BoxDecoration(
                      color: GeneralCtr.MainColor.withOpacity(0.07),
                      border: Border.all(
                        color: Colors.transparent,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(5))
                  ),
                  margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Column(
                    children: [
                      /* 닉네임 */
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("닉네임"),
                          Text("${user!.displayName}")
                        ],
                      ),
                      Divider(),
                      /* 이메일 */
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("이메일"),
                          Text("${user!.email}")
                        ],
                      ),
                    ],
                  ),
                )
              ],
            )

          ],
        ),
      ),
    );
  }
}
