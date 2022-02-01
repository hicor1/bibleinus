import 'package:bible_in_us/bible/bible_tab_page.dart';
import 'package:bible_in_us/general/general_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Gex컨트롤러 객체 초기화
final GeneralCtr = Get.put(GeneralController());

class TabPage extends StatefulWidget {
  const TabPage({Key? key}) : super(key: key);

  @override
  _TabPageState createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  List pages = [
    BibleTabPage(),
    Text("MY페이지"),
  ];

  @override
  Widget build(BuildContext context) {
    return
      //GetX빌더 소환
      GetBuilder<GeneralController>(
          init: GeneralController(), // GetX초기화
          builder: (_){
            return Scaffold(
              body: Center(child: pages[GeneralCtr.selectedPageIndex]),
              bottomNavigationBar: Container(
                  height: 70, // 네비바 높이
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.white)],
                      // 네비바 위쪽상단 희미한 그림자 느낌 주기
                      border: BorderDirectional(
                          top: BorderSide(
                              color: Colors.grey,
                              width: 0.4,
                              style: BorderStyle.solid))),
                  child: BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    unselectedItemColor: Colors.grey, // 비활성 아이콘 색깔
                    selectedItemColor: GeneralCtr.MainColor,  // 활성 아이콘 색깔
                    unselectedFontSize: 10, // 비활성 텍스트 크기
                    selectedFontSize: 13, // 활성 텍스트 크기
                    // 탭 클릭 이벤트
                    onTap: (index) {
                      GeneralCtr.PageChanged(index);
                    },
                    currentIndex: GeneralCtr.selectedPageIndex,
                    //Tab 아이템 정의
                    items: const [
                      BottomNavigationBarItem(
                          icon: Icon(Icons.bookmarks, size: 35), label: '성경'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.person_rounded, size: 35), label: 'MY'),
                      //BottomNavigationBarItem(icon: Icon(Icons.account_circle, size: 30), label:'더보기'),
                    ],
                  )
              ),
            );
          }
      );
  }
}
