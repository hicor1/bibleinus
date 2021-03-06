import 'package:bible_in_us/auth/auth_check_page.dart';
import 'package:bible_in_us/bible/bible_controller.dart';
import 'package:bible_in_us/diary/diary_controller.dart';
import 'package:bible_in_us/diary/diary_tab_page.dart';
import 'package:bible_in_us/general/general_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';



// Gex컨트롤러 객체 초기화
final GeneralCtr = Get.put(GeneralController());
final BibleCtr = Get.put(BibleController());
final DiaryCtr = Get.put(DiaryController());


// (앱 기동)
void main() {
  runApp(MyApp());
}

// (앱생성)
class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {

    /* 파이어베이스 코어 로드 체크를 위해 빌더 생성 */
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {

        /* 1. 비 정상 로딩인 경우 액션 정의 */
        if (snapshot.hasError) {
          return Center(
            child: Text("firebase load fail"),
          );
        }

        /* 2. 정상 로딩인 경우 액션 정의( 진짜 로그인 위젯 리턴 ) */
        if (snapshot.connectionState == ConnectionState.done) {
          return GetMaterialApp(

            /* 달력어플을 위한 한글언어 설정 */
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              SfGlobalLocalizations.delegate
            ],
            supportedLocales: [Locale('ko')],
            locale: Locale('ko'),

            /* 전체 어플 테마 설정 */
            theme: ThemeData(
                scaffoldBackgroundColor: const Color(0xFFFFFFFF), // 전체 하얀 배경
                fontFamily: 'gangwon', // 전체 폰트 설정
                textTheme: TextTheme(
                  titleSmall: TextStyle(backgroundColor: Colors.red),
                  //titleMedium: TextStyle(backgroundColor: Colors.red),
                  //titleLarge: TextStyle(backgroundColor: Colors.red),
                  //bodyText2: TextStyle(backgroundColor: Colors.red),
                  //bodyMedium:  TextStyle(backgroundColor: Colors.red),
                ),
                // brightness: Brightness.light,
                visualDensity: VisualDensity.adaptivePlatformDensity
            ),

            // 디버그 모드 해제
            debugShowCheckedModeBanner: false,
            title: 'Echo',

            /* 파이어베이스가 정상적으로 로드되었으므로 로그인 체크 화면으로 이동 */
            home: AuthCheckPage(),
            // 로딩페이지 정의 ( 이거 개꿀 )
            builder: EasyLoading.init(),
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}


