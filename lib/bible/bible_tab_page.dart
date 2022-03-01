import 'package:bible_in_us/bible/bible_component.dart';
import 'package:bible_in_us/bible/bible_controller.dart';
import 'package:bible_in_us/bible/bible_favorite_page.dart';
import 'package:bible_in_us/bible/bible_main_page.dart';
import 'package:bible_in_us/bible/bible_memo_page.dart';
import 'package:bible_in_us/bible/bible_search_screen.dart';
import 'package:bible_in_us/diary/diary_controller.dart';
import 'package:bible_in_us/general/general_controller.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/iconic_icons.dart';
import 'package:fluttericon/linecons_icons.dart';
import 'package:fluttericon/octicons_icons.dart';
import 'package:fluttericon/typicons_icons.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:fluttericon/web_symbols_icons.dart';
import 'package:get/get.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';


// Gex컨트롤러 객체 초기화
final GeneralCtr = Get.put(GeneralController());
final BibleCtr = Get.put(BibleController());
final DiaryCtr = Get.put(DiaryController());

class BibleTabPage extends StatefulWidget {
  const BibleTabPage({Key? key}) : super(key: key);

  @override
  _BibleTabPageState createState() => _BibleTabPageState();
}

class _BibleTabPageState extends State<BibleTabPage> with TickerProviderStateMixin {

  //탭 컨트롤러 초기화 및 종료
  @override
  void initState() {
    BibleCtr.tabController = TabController(length: 3, vsync: this); // 메인 페이지 탭
    super.initState();
  }
  // @override
  // void dispose() {
  //   BibleCtr.tabController.dispose();
  //   super.dispose();
  // }
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
      length: 3,
      child: Scaffold(

        /*  플로팅 액션버튼 ( 메인페이지 텍스트 클랙했을 때 각종 액숀 정의 ) */
          floatingActionButton:FlotingActionButton(),

          /*  메인 성경이 뿌려짐  */
          body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                // 수직으로 스크롤 가능하도록 설정
                SliverAppBar(
                  title: Text('성경', style: GeneralCtr.Style_title),
                  backgroundColor: Colors.white,
                  floating: true, // 최상단 앱바까지 감출지 여부
                  pinned: true, // 탭까지 모두 감출지 여부
                  snap: false, // 잠깐다시올릴때 앱바 보여주기
                  // 앱바 액숀 버튼
                  actions: [
                    /* 돋보기 버튼 */
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: IconButton(
                        onPressed: (){
                          /* 자유검색 상태값 변경해주기 ( bible app에서 호출했음을 알리기 위해 ) */
                          BibleCtr.update_from_which_app("bible");
                          // 버튼 동작
                          Get.to(() => BibleSearchScreen());
                        },
                        icon: Icon(Octicons.search, size: 23.0, color: GeneralCtr.MainColor),
                      ),
                    ),
                    /* 셋팅 버튼 */
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: IconButton(
                        onPressed: (){
                          // 버튼 동작
                          openPopup(context);
                        },
                        icon: Icon(FontAwesome.cog, size: 25.0, color: GeneralCtr.MainColor),
                      ),
                    ),
                  ],
                  // "TabBar"는 기본적으로 Evenly 정렬이므로, 좌측정렬이 안됨. 따라서 PreferredSize를 사용해서 인위적으로 좌측 정렬 시킴
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(49),
                    child: Align(
                      alignment: Alignment.centerLeft, // 탭 메뉴들 왼쪽 정렬
                      child: TabBar(
                        onTap: (index){
                          /* 자유검색 상태값 변경해주기 ( bible app에서 호출했음을 알리기 위해 ) */
                          BibleCtr.update_from_which_app("bible");
                          BibleCtr.FloatingAB_init(); // 탭 이동시 플로팅액션버튼 초기화
                        },//
                        controller: BibleCtr.tabController, // 컨트롤러 정의
                        labelColor: Colors.black, // 활성 탭 색
                        //labelStyle: GeneralCtr.Style_tab, // 활성 탭 스타일
                        //unselectedLabelStyle:GeneralCtr.Style_tab_unselected, // 비활성 탭 스타일
                        unselectedLabelColor: Colors.grey, // 비활성 탭 색
                        indicatorSize: TabBarIndicatorSize.label, // 아래 강조표시 길이
                        indicatorWeight: 3.0, // 아래 강조표시 두께
                        indicatorColor: GeneralCtr.MainColor, // 아래 강조표시 색깔
                        isScrollable: true, // 수평으로 스크롤가능여부
                        tabs: [
                          Tab(child: Text('성경읽기', style: TextStyle(fontSize: GeneralCtr.fontsize_normal))),
                          Tab(child: Text('즐겨찾기', style: TextStyle(fontSize: GeneralCtr.fontsize_normal))),
                          Tab(child: Text('메모', style: TextStyle(fontSize: GeneralCtr.fontsize_normal))),
                        ],
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: BibleCtr.tabController, // 컨트롤러 정의
              children: <Widget>[
                BibleMainPage(), // 메인 페이지 호출
                BibleFavoritePage(),
                BibleMemoPage(),
              ],
            ),
          )),
    );
  }
}


/* <서브위젯> 플로팅 액션버튼 정의 */
class FlotingActionButton extends StatelessWidget {
  const FlotingActionButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BibleController>(
        init: BibleController(),
        builder: (_){
          return AnimatedOpacity(
            opacity: BibleCtr.FAB_opacity, // 이부분을 조정해서 플로팅 버튼이 보이고&안보이게 조절 ㄱㄱ
            duration: Duration(milliseconds: 500),
            child: FabCircularMenu(
                key: BibleCtr.fabKey, // 위에서 정의한 컨트롤러 할당 // 닫기:fabKey.currentState!.close()
                ringColor: GeneralCtr.MainColor.withOpacity(0.7),
                ringDiameter: 350.0,
                ringWidth: 70.0, // 안쪽 하얀링 크기
                fabSize: 64.0, // 버튼 동그라미 지름
                fabElevation: 20.0, // 버튼 그림자
                fabIconBorder: CircleBorder(),
                fabCloseColor: GeneralCtr.MainColor.withOpacity(0.9), // 버튼 평소 색깔
                fabOpenIcon: Icon(Typicons.pin_outline, color: Colors.white), // 버튼 평소 아이콘
                fabOpenColor: Colors.white, // 버튼 활성화 색깔
                fabCloseIcon: Icon(Icons.close, color: Colors.black), // 버튼 활성화 아이콘
                fabMargin: EdgeInsets.fromLTRB(36.0,10,10,100), // 버튼 위치
                /* 플로팅액션 버틍을 눌렀을 떄 보이는 하위 메뉴들 */
                children: <Widget>[
                  // 1. 일기쓰기
                  RawMaterialButton(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(15.0),
                      child: SizedBox(
                        height: 60,
                        child: Column(
                          children: [
                            Icon(Elusive.pencil, color: Colors.white, size: 30),
                            SizedBox(height: 3),
                            Text('일기쓰기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      onPressed: () {
                        DiaryCtr.select_NewOrModify("new"); // 신규 작성모드로 변경
                        DiaryCtr.diray_write_screen_init();// 일기 쓰기 페이지 초기화
                        /* 일기쓰기 모듈 불러오기 */
                        DiaryCtr.add_verses_idList();
                      }
                  ),
                  // 2. 메모 남기기
                  RawMaterialButton(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(15.0),
                      child: SizedBox(
                        height: 60,
                        child: Column(
                          children: [
                            Icon(Elusive.edit, color: Colors.white, size: 30),
                            SizedBox(height: 3),
                            Text('메모하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      onPressed: () {
                        /* 0. 메모팝업초기화 */
                        BibleCtr.MemoPop_init();
                        /* 1. 메모팝업띄우기 */
                        AddMemo(context, null, "NEW"); // 신규등록이므로 "NEW"로 분류
                        /* 2. 선택 메모 리스트에 표기할 사람이 클릭한 구절 정보 받아오기 */
                        BibleCtr.GetClickedVerses();
                      }
                  ),
                  // 3. 즐겨찾기 버튼 추가
                  RawMaterialButton(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(15.0),
                      child: SizedBox(
                        height: 60,
                        child: Column(
                          children: [
                            Icon(FontAwesome5.star, color: Colors.white, size: 28),
                            SizedBox(height: 3),
                            Text('즐겨찾기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      onPressed: () {
                        /* 1. 즐겨찾기 팝업 띄우기 */
                        AddFavorite(context);
                        /* 2. 즐겨찾기 리스트에 표기할 사람이 클릭한 구절 정보 받아오기 */
                        BibleCtr.GetClickedVerses();
                      }
                  ),
                ]
            ),
          ); //return은 필수
        }
    );
  }
}
