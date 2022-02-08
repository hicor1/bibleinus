
/* 구글 로그인 모듈 */
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

/* 이메일 로그인 모듈 */
void signInWithEmail(String email, String pwd) async {
  // 로딩화면 띄우기
  EasyLoading.show(status: 'loading...');
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email, password: pwd);
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      print('No user found for that email.');
    } else if (e.code == 'wrong-password') {
      print('Wrong password provided for that user.');
    }
  }
  // 로딩화면 종료
  EasyLoading.dismiss();
}

