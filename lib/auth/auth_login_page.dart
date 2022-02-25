import 'package:bible_in_us/auth/auth_component.dart';
import 'package:bible_in_us/general/general_controller.dart';
import 'package:bible_in_us/auth/auth_signup_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/typicons_icons.dart';
import 'package:get/get.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Gex컨트롤러 객체 초기화
final GeneralCtr = Get.put(GeneralController());

/* 로그인 컨테이터 _ 폼필드 (formfield)에 필요한 각종 변수 정의 */
final _formKey = GlobalKey<FormState>();// 폼에 부여할 수 있는 유니크한 글로벌 키를 생성한다.
String email = ""; // 이메일 주소 저장
String password = ""; // 비밀번호 저장

/* 비밀번호 찾기 모달 _ 폼필드 (formfield)에 필요한 각종 변수 정의 */
final Pass_RE_formkey = GlobalKey<FormState>();// 폼에 부여할 수 있는 유니크한 글로벌 키를 생성한다.
String Pass_RE_email = ""; // 이메일 주소 저장


// https://debaeloper.tistory.com/63?category=1030542
class AuthLoginPage extends StatelessWidget {

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
                            style: TextStyle(color: Colors.black),
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
                        onPressed: (){
                          /* 비밀번호 찾는 안내 모달(modal)창 띄우기 */
                          showCupertinoModalBottomSheet( // 모달창 옵션
                              enableDrag: true, // 아래로 끌어내릴수 있음
                              bounce: true, // 이건잘 모르겠음 ㄷㄷㄷ
                              backgroundColor: Colors.white,
                              closeProgressThreshold: 0.6,
                              duration: Duration(milliseconds: 500), // 모달창이 올라오는 시간
                              expand: false, // 높이와 상관없이 화면 끝까지 늘리는 기능
                              context: context, // 아래부터 모달창에 보여줄 내용
                              builder: (context) => ModalWigdet() // 모달위젯 뿌리기
                          );
                        },
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /* 구글 로그인 */
                        SizedBox(
                          width: 150,
                          child: SignInButton(
                            Buttons.Google,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                              side: BorderSide(
                                width: 1,
                                color: Colors.transparent,
                                style: BorderStyle.solid,
                              ),
                            ),
                            text: "Google 로그인",
                            onPressed: signInWithGoogle,
                          ),
                        ),

                        /* 사회적 거리두기 */
                        SizedBox(width: 10),

                        /* 페이스북 로그인 */
                        SizedBox(
                          width: 150,
                          child: SignInButton(
                            Buttons.FacebookNew,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                              side: BorderSide(
                                width: 1,
                                color: Colors.transparent,
                                style: BorderStyle.solid,
                              ),
                            ),
                            text: "Facebook 로그인",
                            onPressed: signInWithFacebook,
                          ),
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


// <서브위젯_모달>모달 위젯 정의
class ModalWigdet extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return
      Padding(
        /* 키패드가 올라오면 자연스럽게 모달창이 위로 올라가도록 "padding" 을 잡아준다 */
        padding: MediaQuery.of(context).viewInsets,
        child: SizedBox(
          height: 320, // 전체 모달창 크기 설정
          child: Column(
            children: [
              /* 메인 이미지 띄우기 */
              Image.asset("assets/img/logo/app_icon.png",height: 100),

              /* 안내 텍스트 */
              Text("비밀번호를 잊으셨나요?\n입력해주신 이메일로 비밀번호 재설정 메일을 발송해 드릴게요\n\n(이메일, 비밀번호로 직접 가입한 경우에만 재설정이 가능해요!)",
                style: TextStyle(fontSize: 13),
                textAlign: TextAlign.center),

              /* 사회적 거리두기 */
              SizedBox(height: 10),

              /* 이메일 적는 곳 */
              Container(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    children: [
                      /* 1. 이메일 입력 */
                      Form(
                        /* Form을 위한 key(키) 할당 */
                        key: Pass_RE_formkey,
                        child: TextFormField(
                          /* 저장 버튼("_formKey.save()" 눌렀을 때 이벤트 정의 */
                          onSaved: (val){
                            Pass_RE_email = val!; // 이메일 값 저장
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
                      ),

                      /* 사회적 거리두기 */
                      SizedBox(height: 10),

                      /* 2. 비밀번호 재설정 이메일 전송 버튼 */
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size.fromHeight(50), // 좌우로 쫙 늘리고 높이는 지정
                          primary: GeneralCtr.MainColor,
                        ),
                        child: Text("이메일로 로그인", style: TextStyle(fontSize: 13)),
                        onPressed: (){
                          /* 비밀번호 재설정 모듈 동작 */
                          // 텍스트폼필드의 상태가 적함하는
                          if (Pass_RE_formkey.currentState!.validate()) {
                            /* Form값 가져오기 */
                            Pass_RE_formkey.currentState!.save();
                            /* 비밀번호 재설정 함수 호출 */
                            resetPassword(context, Pass_RE_email);
                          } else return null;
                        },
                      ),
                    ],
                  )
              ),


            ],
          ),
        ),
      );
  }
}