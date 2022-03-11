

import 'package:bible_in_us/auth/auth_check_page.dart';
import 'package:bible_in_us/bible/bible_component.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

/* 이메일 로그인 모듈 */
void signInWithEmail(String email, String pwd) async {
  // 로딩화면 띄우기
  EasyLoading.show(status: 'loading...');
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email, password: pwd);
  } on FirebaseAuthException catch (e) {
    print(e.code);
    if (e.code == 'user-not-found') {
      /* 이메일 주소가 존재하지 않음 */
      PopToast('이메일 주소가 정확하지 않습니다.');
    } else if (e.code == 'wrong-password') {
      /* 비밀번호가 일치하지 않음 */
      PopToast('비밀번호가 일치하지 않습니다.');
    }
  }
  // 로딩화면 종료
  EasyLoading.dismiss();
}



/* 이메일 회원가입 모듈 */
void signUpWithEmail(String displayname, String email, String pwd) async {
  // 로딩화면 띄우기
  EasyLoading.show(status: 'loading...');

  // 이메일 회원가입 모듈 호출
  try {
    // 정상 작동 시 아래 모듈 작동

    //1. 파이어베이스 이메일 회원가입
    UserCredential userCred =
    await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: pwd);

    //2. 회원 객체에 닉네임 업데이트 해주기
    await userCred.user!.updateDisplayName(displayname);

    //3. 메인탭으로 이동
    Get.to(() => AuthCheckPage());
    
    // 에러 발생시 안내 메세지 팝업
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      /* 보안에 취약한 비밀번호 */
      PopToast('비밀번호가 보안에 취약합니다.');
    } else if (e.code == 'email-already-in-use') {
      /* 존재하는 이메일 주소 */
      PopToast('존재하는 메일 주소입니다.');
    }
  } catch (e) {
    print(e);
  }

  // 로딩화면 종료
  EasyLoading.dismiss();

}
/* 이메일 비밀번호 재설정 모듈(https://firebase.flutter.dev/docs/auth/usage) */
@override
Future<void> resetPassword(context, String email) async {
  // 로딩화면 띄우기
  EasyLoading.show(status: 'loading...');

  // 이메일 비밀번호 재설정 모듈 호출
  try {
    // 정상 작동 시 아래 모듈 작동
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    PopToast('$email 으로 메일이 발송되었습니다.');
    Navigator.pop(context); //모달창 닫기

    // 에러 발생시 안내 메세지 팝업
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      PopToast('이메일 주소가 정확하지 않습니다.');
    } else null;
  }
  
  // 로딩화면 종료
  EasyLoading.dismiss();
}


/* 구글 로그인 모듈 */
Future<UserCredential> signInWithGoogle() async {
  // 로딩화면 띄우기
  EasyLoading.show(status: 'loading...');

  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  // 로딩화면 종료
  EasyLoading.dismiss();

  // Once signed in, return the UserCredential
  return await FirebaseAuth.instance.signInWithCredential(credential);
}

/* 페이스북 로그인 모듈 */
Future<UserCredential> signInWithFacebook() async {
  // 로딩화면 띄우기
  EasyLoading.show(status: 'loading...');

  // Trigger the sign-in flow
  final LoginResult loginResult = await FacebookAuth.instance.login();

  // Create a credential from the access token
  final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.token);

  // 로딩화면 종료
  EasyLoading.dismiss();

  // Once signed in, return the UserCredential
  return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
}



