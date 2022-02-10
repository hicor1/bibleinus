import 'package:bible_in_us/bible/bible_component.dart';
import 'package:bible_in_us/bible/bible_controller.dart';
import 'package:bible_in_us/bible/bible_favorite_page.dart';
import 'package:bible_in_us/bible/bible_main_page.dart';
import 'package:bible_in_us/bible/bible_memo_page.dart';
import 'package:bible_in_us/bible/bible_search_screen.dart';
import 'package:bible_in_us/general/general_controller.dart';
import 'package:bible_in_us/hymn/hymn_controller.dart';
import 'package:bible_in_us/hymn/hymn_score_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/typicons_icons.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:get/get.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:bible_in_us/hymn/hymn_main_page.dart';


// Gex컨트롤러 객체 초기화
final GeneralCtr = Get.put(GeneralController());
final HymnCtr = Get.put(HymnController());

class HymnTabPage extends StatefulWidget {
  const HymnTabPage({Key? key}) : super(key: key);

  @override
  _HymnTabPageState createState() => _HymnTabPageState();
}

class _HymnTabPageState extends State<HymnTabPage> with TickerProviderStateMixin {

  //탭 컨트롤러 초기화 및 종료
  @override
  void initState() {
    HymnCtr.tabController = TabController(length: 2, vsync: this); // 메인 페이지 탭
    super.initState();
  }
  @override
  void dispose() {
    HymnCtr.tabController.dispose();
    super.dispose();
  }
  // 메인위젯 뿌리기
  @override
  Widget build(BuildContext context) {
    return
      // GetX 사용하기
      GetBuilder<GeneralController>(
          init: GeneralController(),
          builder: (_){
            // 메인위젯 뿌리기
            return Mainwidget();
          }
      );
  }
}

// <서브위젯>메인 위젯 정의
class Mainwidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(

          /*  메인 성경이 뿌려짐  */
          body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                // 수직으로 스크롤 가능하도록 설정
                SliverAppBar(
                  title: Text('찬송가', style: TextStyle(color: GeneralCtr.MainColor, fontSize: 25, fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.white,
                  floating: true, // 최상단 앱바까지 감출지 여부
                  pinned: false, // 탭까지 모두 감출지 여부
                  snap: true, // 잠깐다시올릴때 앱바 보여주기

                  // "TabBar"는 기본적으로 Evenly 정렬이므로, 좌측정렬이 안됨. 따라서 PreferredSize를 사용해서 인위적으로 좌측 정렬 시킴
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(kToolbarHeight),
                    child: Align(
                      alignment: Alignment.centerLeft, // 탭 메뉴들 왼쪽 정렬
                      child: TabBar(
                        /* 탭 변경 이벤트 */
                        onTap: (index){

                        },//
                        controller: HymnCtr.tabController, // 컨트롤러 정의
                        labelColor: GeneralCtr.MainColor, // 활성 탭 색
                        labelStyle: TextStyle(fontSize: 17.0), // 활성 탭 스타일
                        unselectedLabelColor: Colors.grey, // 비활성 탭 색
                        unselectedLabelStyle:TextStyle(fontSize: 14.0), // 비활성 탭 스타일
                        indicatorSize: TabBarIndicatorSize.label, // 아래 강조표시 길이
                        indicatorWeight: 3.0, // 아래 강조표시 두께
                        indicatorColor: GeneralCtr.MainColor, // 아래 강조표시 색깔
                        isScrollable: true, // 수평으로 스크롤가능여부
                        tabs: [
                          Tab(child: Text('찬송가')),
                          Tab(child: Text('악보')),
                        ],
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: HymnCtr.tabController, // 컨트롤러 정의
              children: <Widget>[
                HymnMainWidget(), // 메인 페이지 호출
                HymnScorePage(),
              ],
            ),
          )),
    );
  }
}

