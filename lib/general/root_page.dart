import 'package:bible_in_us/diary/diary_controller.dart';
import 'package:bible_in_us/general/general_controller.dart';
import 'package:bible_in_us/my/my_controller.dart';
import 'package:flutter/material.dart';
import 'package:bible_in_us/general/tab_page.dart';
import 'package:get/get.dart';




/* 컨트롤러 불러오기 */
final MyCtr = Get.put(MyController());
final DiaryCtr = Get.put(DiaryController());
final GeneralCtr = Get.put(GeneralController());

class RootPage extends StatefulWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {


  @override
  Widget build(BuildContext context) {
    /* 컨트롤러 초기화 및 설정값 로드 */
    BibleCtr.LoadPrefsData(); // 설정값 불러오기
    GeneralCtr.LoadPrefsData(); // 설정값 불러오기
    DiaryCtr.LoadPrefsData(); // 설정값 불러오기
    GeneralCtr.init(); // 컨트롤러 초기화
    MyCtr.init();// 컨트롤러 초기화
    BibleCtr.init();// 컨트롤러 초기화
    DiaryCtr.init();// 컨트롤러 초기화
    return TabPage();
  }
}

