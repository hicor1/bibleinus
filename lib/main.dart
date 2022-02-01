import 'package:bible_in_us/bible/bible_controller.dart';
import 'package:bible_in_us/general/general_controller.dart';
import 'package:bible_in_us/general/root_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';



// Gex컨트롤러 객체 초기화
final GeneralCtr = Get.put(GeneralController());
final BibleCtr = Get.put(BibleController());


// (앱 기동)
void main() {
  runApp(MyApp());
}

// (앱생성)
class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    BibleCtr.LoadPrefsData(); // 설정값 불러오기
    GeneralCtr.LoadPrefsData(); // 설정값 불러오기
    BibleCtr.init();// 컨트롤러 초기화
    
    return GetMaterialApp(
      // 디버그 모드 해제
      debugShowCheckedModeBanner: false,
      title: 'Echo',
      home: RootPage(),
      builder: EasyLoading.init(),
    );
  }
}
