
import 'package:bible_in_us/general/general_controller.dart';
import 'package:bible_in_us/my/my_component.dart';
import 'package:bible_in_us/my/my_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/iconic_icons.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';


// Gex컨트롤러 객체 초기화
final GeneralCtr = Get.put(GeneralController());
final MyCtr = Get.put(MyController());

/* 닉네임 변경 모달 _ 폼필드 (formfield)에 필요한 각종 변수 정의 */
final Update_displayname_formkey = GlobalKey<FormState>();// 폼에 부여할 수 있는 유니크한 글로벌 키를 생성한다.
String displayname = ""; // 이메일 주소 저장

/* <메인 위젯> 메인 위젯 뿌리기 */
class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainWidget();
  }
}


/* <서브위젯> 메인 위젯 정의 */
class MainWidget extends StatelessWidget {
  const MainWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /* GetX컨트롤러 불러오기 */
    return GetBuilder<MyController>(
        init: MyController(),
        builder: (_){
          return Scaffold(
            appBar: AppBar(
              title: Text("프로필 변경하기", style: GeneralCtr.Style_title),
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(
                color: GeneralCtr.MainColor, //change your color here
              ),
              elevation: 1.5,
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

                      Text("  유저정보", style: TextStyle(fontSize: GeneralCtr.fontsize_normal)),
                      /* 유저 정보 보여주기 컨테이터 */
                      Container(
                        decoration: BoxDecoration(
                          /* 메인 컨테이너 배경색 */
                            color: GeneralCtr.MainColor.withOpacity(0.06),
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
                                Text("닉네임", style: TextStyle(fontSize: GeneralCtr.fontsize_normal)),
                                Text("${MyCtr.displayName}", style: TextStyle(fontSize: GeneralCtr.fontsize_normal))
                              ],
                            ),
                            Divider(),
                            /* 이메일 */
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("이메일", style: TextStyle(fontSize: GeneralCtr.fontsize_normal)),
                                Text("${MyCtr.email}", style: TextStyle(fontSize: GeneralCtr.fontsize_normal))
                              ],
                            ),
                          ],
                        ),
                      ),


                      /* 사회적 거리두기 */
                      SizedBox(height: 25),


                      /* 정보 수정하기 컨테이너 */
                      Container(
                        decoration: BoxDecoration(
                          /* 메인 컨테이너 배경색 */
                            color: GeneralCtr.MainColor.withOpacity(0.06),
                            border: Border.all(
                              color: Colors.transparent,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(5))
                        ),
                        margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: Column(
                          children: [

                            /* 프로필 이미지 수정 */
                            InkWell(
                              onTap: (){
                                /* 닉네임 변경 모달 띄우기 */
                                FlutterDialog(context);

                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("프로필 이미지 수정", style: TextStyle(fontSize: GeneralCtr.fontsize_normal)),
                                  Icon(Icons.chevron_right, size:  GeneralCtr.fontsize_normal)
                                ],
                              ),
                            ),
                            Divider(),

                            /* 닉네임 수정 */
                            InkWell(
                              onTap: (){
                                /* 닉네임 변경 모달 띄우기 */
                                showCupertinoModalBottomSheet( // 모달창 옵션
                                    enableDrag: true, // 아래로 끌어내릴수 있음
                                    bounce: true, // 이건잘 모르겠음 ㄷㄷㄷ
                                    backgroundColor: Colors.white,
                                    closeProgressThreshold: 0.6,
                                    duration: Duration(milliseconds: 500), // 모달창이 올라오는 시간
                                    expand: false, // 높이와 상관없이 화면 끝까지 늘리는 기능
                                    context: context, // 아래부터 모달창에 보여줄 내용
                                    builder: (context) => DisplayNameModalWigdet() // 모달위젯 뿌리기
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("닉네임 수정", style: TextStyle(fontSize: GeneralCtr.fontsize_normal)),
                                  Icon(Icons.chevron_right, size:  GeneralCtr.fontsize_normal)
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    ],
                  )

                ],
              ),
            ),
          ); //return은 필수
        }
    );
  }
}




// <서브위젯_모달> 닉네임 변경 모달 정의
class DisplayNameModalWigdet extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return
      Padding(
        /* 키패드가 올라오면 자연스럽게 모달창이 위로 올라가도록 "padding" 을 잡아준다 */
        padding: MediaQuery.of(context).viewInsets,
        child: SizedBox(
          height: 280, // 전체 모달창 크기 설정
          child: Column(
            children: [
              /* 메인 이미지 띄우기 */
              Image.asset("assets/img/logo/app_icon.png",height: 100),

              /* 안내 텍스트 */
              Text("멋진 닉네임으로 변경해보세요",
                  style: TextStyle(fontSize: GeneralCtr.fontsize_normal),
                  textAlign: TextAlign.center),

              /* 사회적 거리두기 */
              SizedBox(height: 10),

              /* 닉네임 적는곳 */
              Container(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Column(
                  children: [
                    /* 1. 닉네임 입력 */
                    Form(
                      /* Form을 위한 key(키) 할당 */
                      key: Update_displayname_formkey,
                      child: TextFormField(
                        maxLength: 10,
                        /* 저장 버튼("_formKey.save()" 눌렀을 때 이벤트 정의 */
                        onSaved: (val){
                          displayname = val!; // 닉네임 값 저장
                        },
                        /* 스타일 정의 */
                        decoration: InputDecoration(
                          prefixIcon: Icon(Iconic.user, size: GeneralCtr.fontsize_normal, color: Colors.grey.withOpacity(0.7)), // 전방배치 아이콘
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueAccent, width: 1),
                          ),
                          labelText: '닉네임', // 라벨
                          labelStyle: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: GeneralCtr.fontsize_normal, ), // 라벨 스타일
                          floatingLabelStyle: TextStyle(fontSize: GeneralCtr.fontsize_normal), // 포커스된 라벨 스타일
                        ),
                        /* 닉네임 유효성 검사 */
                        validator: (val) {
                          if(val!.length < 1) {
                            return '닉네임은 필수사항입니다.';
                          }
                          if(val.length < 2){
                            return '2자 이상 입력해주세요!';
                          } return null;
                        },
                      ),
                    ),

                    /* 사회적 거리두기 */
                    SizedBox(height: 10),

                    /* 2. 닉네임 재설정 버튼 */
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(50), // 좌우로 쫙 늘리고 높이는 지정
                        primary: GeneralCtr.MainColor,
                      ),
                      child: Text("확인", style: TextStyle(fontSize: GeneralCtr.fontsize_normal)),
                      onPressed: (){
                        /* 닉네임 재설정 모듈 작동 */
                        // 텍스트폼필드의 상태가 적합한지 확인
                        if (Update_displayname_formkey.currentState!.validate()) {
                          /* Form값 가져오기 */
                          Update_displayname_formkey.currentState!.save();
                          /* 닉네임 재설정 함수 호출 */
                          MyCtr.Change_displayName(context, displayname);
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