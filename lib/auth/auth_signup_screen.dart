


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthSignUpScreen extends StatelessWidget {
  const AuthSignUpScreen({Key? key}) : super(key: key);

  /* 이메일 회원가입 모듈 */
  void signUpWithEmail(String email, String pwd) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email, password: pwd);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            /* 이메일 */
            TextField(),
            /* 닉네임 */
            TextField(),
            /* 비밀번호 */
            TextField(),
            /* 비밀번호 확인 */
            TextField(),
            /* 회원가입 버튼 */
            OutlinedButton(
                onPressed: (){
                  signUpWithEmail("hicor@naver.com", "dlacodnr1!");
                },
                child: Text("회원가입"))
          ],
        ),
      ),
    );
  }
}
