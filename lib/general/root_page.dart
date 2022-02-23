import 'package:bible_in_us/diary/diary_controller.dart';
import 'package:bible_in_us/my/my_controller.dart';
import 'package:flutter/material.dart';
import 'package:bible_in_us/general/tab_page.dart';
import 'package:get/get.dart';
//import 'package:hicor_1/pages/auth_login_page.dart';

final MyCtr = Get.put(MyController());
final DiaryCtr = Get.put(DiaryController());


class RootPage extends StatelessWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    MyCtr.init();// 컨트롤러 초기화
    DiaryCtr.init();// 컨트롤러 초기화

    return TabPage();
  }
}
