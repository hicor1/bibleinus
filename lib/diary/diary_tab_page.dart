import 'package:bible_in_us/diary/diary_calendar_screen.dart';
import 'package:bible_in_us/diary/diary_controller.dart';
import 'package:bible_in_us/diary/diary_write_srceen.dart';
import 'package:bible_in_us/diary/diray_view_page.dart';
import 'package:bible_in_us/general/general_controller.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/octicons_icons.dart';
import 'package:get/get.dart';

// Gex컨트롤러 객체 초기화
final GeneralCtr = Get.put(GeneralController());
final DiaryCtr = Get.put(DiaryController());

/* <메인위젯> */
class DiaryTabPage extends StatelessWidget {
  const DiaryTabPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    /* 메인 위젯 뿌려주기 */
    return MainWidget();
  }
}

/* <서브위젯> 메인 위젯 정의 */
class MainWidget extends StatelessWidget {
  const MainWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return
    /* GexX 빌더 소환 */
      GetBuilder<DiaryController>(
          init: DiaryController(),
          builder: (_){
            return DefaultTabController(
              initialIndex: 0,
              length: 2,
              child: Scaffold(

                /*  메인 스크롤  */
                  body: NestedScrollView(
                    headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                      return <Widget>[
                        // 수직으로 스크롤 가능하도록 설정
                        SliverAppBar(
                          title: Text('일기', style: GeneralCtr.Style_title),
                          backgroundColor: Colors.white,
                          floating: true, // 최상단 앱바까지 감출지 여부
                          pinned: true, // 탭까지 모두 감출지 여부
                          snap: false, // 잠깐다시올릴때 앱바 보여주기
                          // 앱바 액숀 버튼
                          actions: [
                            /* 일기 달력으로 보여주기 */
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: IconButton(
                                onPressed: (){
                                  //모드선택 ( 신규(new) 또는 수정(modify) )
                                  DiaryCtr.select_NewOrModify("new");
                                  // 작성하기 스크린으로 이동
                                  Get.to(() => DiaryCalendarScreen());
                                },
                                icon: Icon(FontAwesome.calendar, size: 20.0, color: Colors.indigoAccent,),
                              ),
                            ),
                            /* 작성하기(+) 버튼 */
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                              child: IconButton(
                                onPressed: (){
                                  //모드선택 ( 신규(new) 또는 수정(modify) )
                                  DiaryCtr.select_NewOrModify("new");
                                  // 작성하기 스크린으로 이동
                                  Get.to(() => DiaryWriteScreen());
                                },
                                icon: Icon(Octicons.plus_small, size: 35.0, color: Colors.indigoAccent,),
                              ),
                            ),
                          ],



                          // "TabBar"는 기본적으로 Evenly 정렬이므로, 좌측정렬이 안됨. 따라서 PreferredSize를 사용해서 인위적으로 좌측 정렬 시킴
                          bottom: PreferredSize(
                            preferredSize: const Size.fromHeight(49),
                            child: Align(
                              alignment: Alignment.centerLeft, // 탭 메뉴들 왼쪽 정렬
                              child: TabBar(
                                /* 탭 변경 이벤트 */
                                onTap: (index){

                                },//
                                //controller: HymnCtr.tabController, // 컨트롤러 정의
                                labelColor: Colors.black, // 활성 탭 색
                                //labelStyle: TextStyle(fontSize: 17.0), // 활성 탭 스타일
                                //unselectedLabelStyle:TextStyle(fontSize: 14.0), // 비활성 탭 스타일
                                unselectedLabelColor: Colors.grey, // 비활성 탭 색
                                indicatorSize: TabBarIndicatorSize.label, // 아래 강조표시 길이
                                indicatorWeight: 3.0, // 아래 강조표시 두께
                                indicatorColor: GeneralCtr.MainColor, // 아래 강조표시 색깔
                                isScrollable: true, // 수평으로 스크롤가능여부
                                tabs: [
                                  Tab(child: Text('나의 일기', style: TextStyle(fontSize: GeneralCtr.fontsize_normal))),
                                  Tab(child: Text('Live 일기', style: TextStyle(fontSize: GeneralCtr.fontsize_normal))),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ];
                    },
                    body: TabBarView(
                      //controller: HymnCtr.tabController, // 컨트롤러 정의
                      children: <Widget>[
                        /* Tab메뉴 전환시 보여줄 메인 */
                        DiaryViewPage(),
                        Text("준비중인 기능입니다."),

                      ],
                    ),
                  )),
            ); //return은 필수
          }
      );
  }
}
