import 'package:bible_in_us/auth/auth_login_page.dart';
import 'package:bible_in_us/general/tab_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class AuthCheckPage extends StatelessWidget {
  const AuthCheckPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
            /* 1. 파이어 베이스 로그아웃 상태일 때 페이지 */
            if (!snapshot.hasData) {
              return AuthLoginPage();
            } else {
            /* 2. 파이어 베이스 로그인 상태일 때 페이지 */
              return TabPage();
            }
          },
        ),
      ),
    );
  }
}

