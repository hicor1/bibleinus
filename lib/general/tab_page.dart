import 'package:bible_in_us/bible/bible_tab_page.dart';
import 'package:bible_in_us/diary/diary_tab_page.dart';
import 'package:bible_in_us/general/general_controller.dart';
import 'package:bible_in_us/hymn/hymn_tab_page.dart';
import 'package:bible_in_us/my/my_main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

// Gex컨트롤러 객체 초기화
final GeneralCtr = Get.put(GeneralController());

class TabPage extends StatefulWidget {
  const TabPage({Key? key}) : super(key: key);

  @override
  _TabPageState createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  /* WillPopScope 함수 변수 정의 */
  late DateTime backbuttonpressedTime;

  /* Tab페이지 정의 */
  List pages = [
    DiaryTabPage(),
    BibleTabPage(),
    HymnTabPage(),
    MyMainPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return
      //GetX빌더 소환
      GetBuilder<GeneralController>(
          init: GeneralController(), // GetX초기화
          builder: (_){
            return Scaffold(
              /* 뒤로가기버튼으로 App이 종료되는것을 방지하기 위해 "WillPopScope"으로 감싸준다.(https://dkswnkk.tistory.com/43) */
              body: WillPopScope(
                  onWillPop: _onWillPop,
                  child: Center(child: pages[GeneralCtr.selectedPageIndex])
              ),
              bottomNavigationBar: Container(
                  height: 60, // 네비바 높이
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.white)],
                      // 네비바 위쪽상단 희미한 그림자 느낌 주기
                      border: BorderDirectional(
                          top: BorderSide(
                              color: Colors.grey,
                              width: 0.2,
                              style: BorderStyle.solid))),
                  child: BottomNavigationBar(
                    backgroundColor: Colors.white,
                    type: BottomNavigationBarType.fixed,
                    unselectedItemColor: Colors.grey, // 비활성 아이콘 색깔
                    selectedItemColor: GeneralCtr.MainColor,  // 활성 아이콘 색깔
                    unselectedFontSize: 13, // 비활성 텍스트 크기, 텍스트를 안쓸거기때문에 가장작게한다!
                    selectedFontSize: 13, // 활성 텍스트 크기, 텍스트를 안쓸거기때문에 가장작게한다!
                    // 탭 클릭 이벤트
                    onTap: (index) {
                      GeneralCtr.PageChanged(index);
                    },
                    currentIndex: GeneralCtr.selectedPageIndex,
                    //Tab 아이템 정의
                    items: const [
                      BottomNavigationBarItem(
                          icon: Icon(Elusive.pencil, size: 25), label: '일기'),
                      BottomNavigationBarItem(
                          icon: Icon(FontAwesome5.bible, size: 25), label: '성경'),
                      BottomNavigationBarItem(
                          icon: Icon(Elusive.music , size: 25), label: '찬송가'),
                      BottomNavigationBarItem(icon: Icon(FontAwesome5.user, size: 25), label:'MY'),
                    ],
                  )
              ),
            );
          }
      );
  }


  /*<함수> 앱을 종료하시겠습니까? */
  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('앱 종료', style: TextStyle(fontSize: GeneralCtr.fontsize_normal, fontWeight: FontWeight.bold)),
        content: new Text('앱을 종료하시겠습니까?', style: TextStyle(fontSize: GeneralCtr.fontsize_normal)),
        actions: <Widget>[
          new OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('아니요!', style: TextStyle(fontSize: GeneralCtr.fontsize_normal*0.9)),
          ),
          new OutlinedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: new Text('네', style: TextStyle(fontSize: GeneralCtr.fontsize_normal*0.9)),
          ),
        ],
      ),
    )) ?? false;
  }

}


