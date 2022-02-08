import 'package:bible_in_us/auth/auth_component.dart';
import 'package:bible_in_us/general/general_controller.dart';
import 'package:bible_in_us/auth/auth_signup_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/typicons_icons.dart';
import 'package:get/get.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

// Gex컨트롤러 객체 초기화
final GeneralCtr = Get.put(GeneralController());


// https://debaeloper.tistory.com/63?category=1030542
class AuthLoginPage extends StatelessWidget {

  /* 폼필드 (formfield)에 필요한 각종 변수 정의 */
  final _formKey = GlobalKey<FormState>();// 폼에 부여할 수 있는 유니크한 글로벌 키를 생성한다.
  String email = ""; // 이메일 주소 저장
  String password = ""; // 비밀번호 저장


  /* 아래부터 메인 위젯 */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(), // 키패드가 올라와서 화면 가려도 오류나지 않도록 ㄱㄱ
        child: Padding(
          padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
          child: Center(

            /* 메인 칼럼 */
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /* 로그인 안내 텍스트 */
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("로그인", style: TextStyle(fontSize: 30, fontFamily: "cafe")
                  ),
                ),

                /* 메인 이미지 */
                Image.asset("assets/img/logo/app_icon.png",height: 150),

                /* 로그인 관련 칼럼 묶음 */
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /* 이메일 & 비밀번호 입력 form */
                    Form(
                      /* Form을 위한 key(키) 할당 */
                      key: _formKey,
                      child: Column(
                        // 컬럼내 위젯들을 왼쪽부터 정렬함
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[

                          /* 이메일 입력 */
                          TextFormField(
                            /* 저장 버튼("_formKey.save()" 눌렀을 때 이벤트 정의 */
                            onSaved: (val){
                              email = val!; // 이메일 값 저장
                            },
                            /* 스타일 정의 */
                            decoration: InputDecoration(
                              prefixIcon: Icon(FontAwesome.mail_alt, size: 15, color: Colors.grey.withOpacity(0.7)), // 전방배치 아이콘
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blueAccent, width: 1),
                              ),
                              labelText: '이메일', // 라벨
                              labelStyle: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 13, ), // 라벨 스타일
                              floatingLabelStyle: TextStyle(fontSize: 15), // 포커스된 라벨 스타일
                            ),
                            /* 이메일 유효성 검사 */
                            validator: (val) {
                              if(val!.isEmpty) {
                                return '이메일은 필수사항입니다.';
                              }
                              if(!RegExp(
                                  r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                                  .hasMatch(val)){
                                return '잘못된 이메일 형식입니다.';
                              } else return null;
                            },
                          ),

                          /* 사회적 거리두리 */
                          SizedBox(height: 20),

                          /* 비밀번호 입력 */
                          TextFormField(
                            /* 저장 버튼("_formKey.save()" 눌렀을 때 이벤트 정의 */
                            onSaved: (val){
                              password = val!; // 비밀번호 값 저장
                            },
                            obscureText: true, // 비밀번호 이므로 가려서 보여준다
                            /* 스타일 정의 */
                            decoration: InputDecoration(
                              prefixIcon: Icon(Typicons.lock_filled, size: 17, color: Colors.grey.withOpacity(0.7)), // 전방배치 아이콘
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blueAccent, width: 1),
                              ),
                              labelText: '비밀번호', // 라벨
                              labelStyle: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 13), // 라벨 스타일
                              floatingLabelStyle: TextStyle(fontSize: 15), // 포커스된 라벨 스타일
                            ),
                            /* 비밀번호 유효성 검사 */
                            validator: (val) {
                              if(val!.length < 1) {
                                return '비밀번호는 필수사항입니다.';
                              }
                              if(val.length < 8){
                                return '8자 이상 입력해주세요!';
                              }return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    /* 사회적 거리두리 */
                    SizedBox(height: 10),

                    /* 이메일 로그인 버튼 */
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(50), // 좌우로 쫙 늘리고 높이는 지정
                        primary: GeneralCtr.MainColor,
                      ),
                      child: Text("이메일로 로그인", style: TextStyle(fontSize: 13)),
                      onPressed: (){
                        // 텍스트폼필드의 상태가 적함하는
                        if (_formKey.currentState!.validate()) {
                          /* Form값 가져오기 */
                          _formKey.currentState!.save();
                          /* 이메일 로그인 함수 호출 */
                          signInWithEmail(email,password);
                        } else return null;
                      },
                    ),

                    /* 비밀번호찾기 안내 */
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: (){},
                        child: Text("비밀번호를 잊으셨나요?",
                            style: TextStyle( decoration: TextDecoration.underline, fontSize: 13, color: Colors.black)
                        ),
                      ),
                    ),

                    /* 사회적 거리두리 */
                    SizedBox(height: 20),

                    /* SNS로그인 안내 텍스트 */
                    Stack(
                      children: <Widget>[
                        Positioned(
                          child: Align(
                            alignment: Alignment.center,
                            child: Divider(indent: 5, endIndent: 5, thickness: 0.5),
                          ),
                        ),
                        Positioned(
                          child:Align(
                            alignment: Alignment.center,
                            child: Container(
                                padding: EdgeInsets.fromLTRB(15, 0, 15, 11),
                                color: Colors.white,
                                child: Text("다음 계정으로 로그인", style: TextStyle(fontSize: 13))
                            ),
                          ),
                        ),
                      ],
                    ),

                    /* SNS로그인 버튼 배치 */
                    Column(
                      children: [
                        /* 구글 로그인 */
                        SignInButton(
                          Buttons.Google,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: BorderSide(
                              width: 2,
                              color: Colors.transparent,
                              style: BorderStyle.solid,
                            ),
                          ),
                          text: "Google 로그인",
                          onPressed: signInWithGoogle,
                        ),
                        /* 페이스북 로그인 */
                        SignInButton(
                          Buttons.FacebookNew,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: BorderSide(
                              width: 2,
                              color: Colors.transparent,
                              style: BorderStyle.solid,
                            ),
                          ),
                          text: "Facebook 로그인",
                          onPressed: signInWithFacebook,
                        ),
                      ],
                    ),
                  ],
                ),

                /* 사회적 거리두리 */
                SizedBox(height: 20),

                /* 회원가입 페이지로 이동하기 */
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("계정이 없으신가요?", style: TextStyle( fontSize: 13, color: Colors.black)),
                    TextButton(
                        onPressed: (){
                          Get.to(() => AuthSignUpScreen());
                        },
                        child: Text("회원가입", style: TextStyle( decoration: TextDecoration.underline, fontSize: 13, color: Colors.black))
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
