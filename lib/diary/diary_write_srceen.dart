import 'package:bible_in_us/bible/bible_controller.dart';
import 'package:bible_in_us/bible/bible_favorite_page.dart';
import 'package:bible_in_us/bible/bible_favorite_screen.dart';
import 'package:bible_in_us/bible/bible_search_screen.dart';
import 'package:bible_in_us/diary/diary_controller.dart';
import 'package:bible_in_us/general/general_controller.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/iconic_icons.dart';
import 'package:fluttericon/typicons_icons.dart';
import 'package:fluttericon/web_symbols_icons.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:kpostal/kpostal.dart';
import 'package:word_break_text/word_break_text.dart';

// Gex컨트롤러 객체 초기화
final GeneralCtr = Get.put(GeneralController());
final DiaryCtr = Get.put(DiaryController());
final BibleCtr = Get.put(BibleController());


/* 입력 컨테이터 _ 폼필드 (formfield)에 필요한 각종 변수 정의 */
final _formKey  = GlobalKey<FormState>();// 폼에 부여할 수 있는 유니크한 글로벌 키를 생성한다.
String title    = ""; // 이메일 주소 저장
String contents = ""; // 비밀번호 저장

/* <메인위젯> */
class DiaryWriteScreen extends StatelessWidget {
  const DiaryWriteScreen({Key? key}) : super(key: key);

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
    /* GexX 빌더 소환 */
    return GetBuilder<DiaryController>(
        init: DiaryController(),
        builder: (_){

          return Scaffold(
            backgroundColor: GeneralCtr.MainColor.withOpacity(0.03),
            appBar: AppBar(
              iconTheme: IconThemeData(
                color: GeneralCtr.MainColor
              ),
              title: Text("기록남기기", style: TextStyle(color: GeneralCtr.MainColor),),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              actions: [
                /* 저장 버튼 */
                TextButton(
                    onPressed: (){
                      /* 저장버튼 클릭 이벤트 */
                      /*1. 텍스트폼필드의 상태가 적함한지 확인 */
                      if (_formKey.currentState!.validate()) {
                        /* Form값 가져오기 */
                        _formKey.currentState!.save();
                        /* 관련정보 넘기기 */
                        print("$title\n$contents");

                      } else return null;

                    },
                    child: Text("저장")
                )
              ],
            ),
            /* 메인 바디 정의 */
            body: SingleChildScrollView(
              //physics: NeverScrollableScrollPhysics(), // 키패드가 올라와서 화면 가려도 오류나지 않도록 ㄱㄱ
              child: Column(
                children: [

                  /* 아래부터 선택한 성경 카드로 보여주기 *///https://docs.getwidget.dev/gf-carousel/
                  ViewVerses(),

                  /* 사회적 거리두기 */
                  SizedBox(height: 30),

                  /* 정보 입력 컨테이너 시작 */
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft : Radius.circular(15.0),
                          topRight: Radius.circular(15.0)
                      ),
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.zero,

                    height: 1000,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [

                        /* 칼라코드 보여주기 */
                        Container(
                          padding: EdgeInsets.fromLTRB(15, 20, 0, 5),
                          height : 60,
                          child: ListView.builder(
                            //physics: const NeverScrollableScrollPhysics(), // 빌더 내부에서 별도로 스크롤 관리할지, 이게 활성화 된경우 전체 스크롤보다 해당 스크롤이 우선되므로 일단은 비활성화가 좋다
                              //reverse: true,
                              shrinkWrap: true, //"hassize" 같은 ㅈ같은 오류 방지
                              scrollDirection: Axis.horizontal, // 수직(vertical)  수평(horizontal) 배열 선택
                              //controller: ,// 스크롤 조작이 필요하다면 할당 ㄱㄱ
                              itemCount: DiaryCtr.ColorCode.length,
                              itemBuilder: (context, index) {
                                var result = DiaryCtr.ColorCode[index]; // 결과 할당, 이런식으로 변수 선언 가능, 아래 위젯에서 활용 가능
                                return Row(
                                  children: [
                                    InkWell(
                                      /* 칼라 선택 이벤트 */
                                      onTap : (){
                                        DiaryCtr.update_dirary_screen_color_index(index);
                                      },
                                      /* 칼라코드 보여주기 */
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        decoration: new BoxDecoration(
                                            color: result, 
                                            shape: BoxShape.circle, 
                                            /* 선태된 색 강조 */
                                            border: index == DiaryCtr.dirary_screen_color_index
                                                ? Border.all(color: Colors.black26, width: 3) : null,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10)
                                  ],
                                );
                              }
                          ),
                        ),

                        /* 사회적 거리두기 */
                        SizedBox(height: 10),

                        /* 제목, 내용 등 텍스트 필드 */
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: Form(
                            /* Form을 위한 key(키) 할당 */
                            key: _formKey,
                            child: Column(
                              // 컬럼내 위젯들을 왼쪽부터 정렬함
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[

                                /* 제목 입력 */
                                TextFormField(
                                  /* 저장 버튼("_formKey.save()" 눌렀을 때 이벤트 정의 */
                                  onSaved: (val){
                                    title = val!; // 이메일 값 저장
                                  },
                                  /* 스타일 정의 */
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Elusive.pencil, size: 15, color: Colors.grey.withOpacity(0.7)), // 전방배치 아이콘
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.blueAccent, width: 1),
                                    ),
                                    labelText: '성경일기 제목을 적어주세요', // 라벨
                                    labelStyle: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 13), // 라벨 스타일
                                    floatingLabelStyle: TextStyle(fontSize: 15), // 포커스된 라벨 스타일
                                  ),
                                  /* 제목 유효성 검사 */
                                  validator: (val) {
                                    if(val!.length < 1) {
                                      return '제목은 필수사항입니다.';
                                    }
                                    if(val.length < 2){
                                      return '2자 이상 입력해주세요!';
                                    }return null;
                                  },
                                ),

                                /* 사회적 거리두리 */
                                SizedBox(height: 10),

                                /* 내용 입력 */
                                Container(
                                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.grey.withOpacity(0.1),
                                  ),
                                  child: TextFormField(
                                    maxLines: 10,
                                    /* 저장 버튼("_formKey.save()" 눌렀을 때 이벤트 정의 */
                                    onSaved: (val){
                                      contents = val!; // 비밀번호 값 저장
                                    },
                                    style: TextStyle(color: Colors.black),
                                    /* 스타일 정의 */
                                    decoration: InputDecoration(
                                      hintText: '내용을 적어주세요', // 라벨,
                                      hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 13),
                                      // 언더라인 없애기
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.transparent),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.transparent),
                                      ),
                                    ),
                                    /* 내용 유효성 검사 */
                                    validator: (val) {
                                      if(val!.length < 1) {
                                        return '내용은 필수사항입니다.';
                                      }
                                      if(val.length < 2){
                                        return '2자 이상 입력해주세요!';
                                      }return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),



                        
                        
                        
                        /* 사회적 거리두기 */
                        SizedBox(height: 5),

                        /* 사진 추가 하는곳 */
                        Container(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /* 사진이 입력된 컨테이너 */
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [

                                    /* 사진이 입력된 컨테이너 */
                                    Stack( // 사진 위에 취소(calcle)버튼 겹치기
                                      alignment: Alignment.topRight,
                                      children: [
                                        SizedBox(
                                          height: MediaQuery.of(context).size.width/3.5,
                                          width: MediaQuery.of(context).size.width/3.5,
                                          child: Image.asset("assets/img/logo/temp.jpg"),
                                        ),
                                        IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: BoxConstraints(),
                                            splashColor: Colors.blueAccent,
                                            onPressed: (){
                                              /* 이미지 삭제 모듈 */
                                              print("!!");
                                            },
                                            icon:Icon(WebSymbols.cancel_circle, color: Colors.black.withOpacity(0.7), size: 20))
                                      ],
                                    ),
                                    SizedBox(width: 5),

                                    /* 사진이 입력된 컨테이너 */
                                    Stack( // 사진 위에 취소(calcle)버튼 겹치기
                                      alignment: Alignment.topRight,
                                      children: [
                                        SizedBox(
                                          height: MediaQuery.of(context).size.width/3.5,
                                          width: MediaQuery.of(context).size.width/3.5,
                                          child: Image.asset("assets/img/logo/temp.jpg"),
                                        ),
                                        IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: BoxConstraints(),
                                            splashColor: Colors.blueAccent,
                                            onPressed: (){
                                              /* 이미지 삭제 모듈 */
                                              print("!!");
                                              },
                                            icon:Icon(WebSymbols.cancel_circle, color: Colors.black.withOpacity(0.7), size: 20))
                                      ],
                                    ),
                                    SizedBox(width: 5),

                                    /* 사진이 미입력된 컨테이너 */
                                    DottedBorder(
                                      borderType: BorderType.RRect,
                                      radius: Radius.circular(4),
                                      color: Colors.grey.withOpacity(0.4),
                                      strokeWidth: 1,
                                      child: SizedBox(
                                        height: MediaQuery.of(context).size.width/3.5,
                                        width: MediaQuery.of(context).size.width/3.5,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.add,color: Colors.grey.withOpacity(0.4))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                        ),







                        /* 사회적 거리두기 */
                        SizedBox(height: 20),

                        /* 이 시간에 추천해요  */
                        Container(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("이 시간에 추천해요", style: TextStyle(fontWeight: FontWeight.bold)),
                                /* 추천 태그 보여주기 */
                                Container(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
                                  height : 50,
                                  child: ListView.builder(
                                    //physics: const NeverScrollableScrollPhysics(), // 빌더 내부에서 별도로 스크롤 관리할지, 이게 활성화 된경우 전체 스크롤보다 해당 스크롤이 우선되므로 일단은 비활성화가 좋다
                                      shrinkWrap: true, //"hassize" 같은 ㅈ같은 오류 방지
                                      scrollDirection: Axis.horizontal, // 수직(vertical)  수평(horizontal) 배열 선택
                                      //controller: ,// 스크롤 조작이 필요하다면 할당 ㄱㄱ
                                      itemCount: DiaryCtr.TimeTag.length,
                                      itemBuilder: (context, index) {
                                        var result = DiaryCtr.TimeTag[index]; // 결과 할당, 이런식으로 변수 선언 가능, 아래 위젯에서 활용 가능
                                        return Container(
                                          margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                          child: OutlinedButton(
                                            onPressed: (){
                                              /* 타임태그 선택 이벤트 */
                                              DiaryCtr.update_dirary_screen_timetag_index(index);
                                            },
                                            /* 선택된 태그 강조해주기 */
                                            child: Text("# ${result}",
                                                style: TextStyle(
                                                    color: index == DiaryCtr.dirary_screen_timetag_index
                                                        ? Colors.black : Colors.grey,
                                                    fontSize: 13)
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20.0),
                                              ),
                                              side: BorderSide(
                                                  width: 1,
                                                  color: index == DiaryCtr.dirary_screen_timetag_index
                                                      ? Colors.black : Colors.grey,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                  ),
                                ),
                              ],
                            )
                        ),

                        /* 사회적 거리두기 */
                        SizedBox(height: 20),

                        /* 여기 있어요  */
                        Container(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("여기 있어요", style: TextStyle(fontWeight: FontWeight.bold)),
                                /* 카카오 주소 검색 */
                                TextButton(
                                  onPressed: () async {
                                    /* 주소검색 API 호출 */
                                    Kpostal result = await Navigator.push(context, MaterialPageRoute(builder: (_) => KpostalView()));
                                    /* 주소 저장 모듈 */
                                    DiaryCtr.update_dirary_screen_address(result.address);
                                  },
                                    /* 주소가 있으면 표시하고 없으면 검색 활성화*/
                                    child: DiaryCtr.dirary_screen_address == "" ?
                                    Text("+ 주소 찾기") :
                                        /* 선택된 주소가 있다면 아래와 같이 표기 */
                                        Row(
                                          children: [
                                            Icon(Elusive.location, size: 15),
                                            Text("  ${DiaryCtr.dirary_screen_address}"),
                                            /* 옵션 버튼 */
                                            PopupMenuButton(
                                                icon: Icon(Icons.more_vert_sharp, size: GeneralCtr.Textsize*1.2, color: Colors.black54), // pop메뉴 아이콘
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(5)),
                                                padding: EdgeInsets.zero,
                                                tooltip: "주소 삭제",
                                                color: Colors.white, // pop메뉴 배경색
                                                elevation: 10,// pop메뉴 그림자
                                                onSelected: (value) {
                                                  switch(value){
                                                    /* 주소삭제 버튼 클릭이벤트 */
                                                    case"삭제" : DiaryCtr.update_dirary_screen_address(""); break;
                                                  }
                                                  print(value);
                                                },

                                                /* 옵션 버튼 _ 하위 메뉴 스타일 */
                                                itemBuilder: (context) => [
                                                  PopupMenuItem(
                                                      child: Row(
                                                          children: [
                                                            Icon(FontAwesome.trash_empty, size: GeneralCtr.Textsize*0.9),
                                                            Text("  주소 삭제",
                                                                style: TextStyle(fontSize: GeneralCtr.Textsize*0.9))]),
                                                      value: "삭제"),
                                                ]
                                            )
                                          ],
                                        )
                                ),
                              ],
                            )
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ); //return은 필수
        }
    );

  }
}



//<서비위젯> 성경 카드 뿌려주기
/* 아래부터 선택한 성경 카드로 보여주기 *///https://docs.getwidget.dev/gf-carousel/
class ViewVerses extends StatelessWidget {
  const ViewVerses({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GFCarousel(
      height: 180,
      passiveIndicator: GeneralCtr.MainColor, // 이미지 하단 페이지 비활성 인디케이터 색깔
      activeIndicator : Colors.black, // 이미지 하단 페이지 활성 인디케이터 색깔
      pagerSize: 7.0, // 이미지 하단 페이지 인디케이터 크기
      enableInfiniteScroll: false, // 무한스크롤
      aspectRatio: 20, // 사진 비율
      enlargeMainPage: true, // 자동 확대
      pagination: true, // 이미지 하단 페이지 인디케이터 표시여부
      autoPlayInterval: Duration(milliseconds: 5000), // 자동 넘기기 주기(시간)
      autoPlay: true, // 자동 넘기기 on/off
      pauseAutoPlayOnTouch: Duration(milliseconds: 5000), // 클릭하면 자동넘기기 일시 정지

      /* 선택된 구절 갯수만큼 카드 만들어주기 */
      items: DiaryCtr.dirary_screen_selected_verses_id.map(
            (id) {
          /* 필터링으로 구절정보 하나씩 가져오기 */
          var result = DiaryCtr.selected_contents_data.where((f)=>f["_id"]==id).toList();

          /* 성경 구절 카드에 담아서 보여주기 */
          /* 1. 정보가 "null"이 아니면, 구절 정보 담아서 보여준다 */
          if (id != 99999) {
            return Container(
              decoration: BoxDecoration(
                color: DiaryCtr.ColorCode[DiaryCtr.dirary_screen_color_index].withOpacity(0.4), // 카드 색깔
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.fromLTRB(5, 0, 5, 0), // 좌우 카드끼리 간격 띄우기
              child: SingleChildScrollView(
                  child: Column(
                    children: [
                      /* 수정 버튼 보여주기 */
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          /* 구절 정보 */
                          Text("  [${result[0]['국문']}(${result[0]['영문']}) ${result[0]['cnum']}장 ${result[0]['vnum']}절]"),
                          /* 옵션 버튼 */
                          PopupMenuButton(
                              icon: Icon(Icons.more_vert_sharp, size: GeneralCtr.Textsize*1.2, color: Colors.black54), // pop메뉴 아이콘
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              padding: EdgeInsets.zero,
                              tooltip: "추가기능",
                              color: Colors.white, // pop메뉴 배경색
                              elevation: 10,// pop메뉴 그림자
                              onSelected: (value) {
                                /* 자유검색 상태값 변경해주기 ( diary app에서 호출했음을 알리기 위해 ) */
                                BibleCtr.update_from_which_app("diary");
                                /* 수정모드 입력 */
                                DiaryCtr.update_mode_select("replace", id);
                                var temp = "";
                                /* 경우의 수에 맞게 이벤트 정의 */
                                switch(value){
                                /* 해당 구절 삭제 이동 */
                                  case"삭제" :
                                    DiaryCtr.remove_verses_id(id);  break;
                                /* 자유검색 페이지 선택값으로 !수정! */
                                  case"검색" :
                                    Get.to(() => BibleSearchScreen());  break;
                                /* 즐겨찾기 페이지 선택값으로 !수정! */
                                  case"즐겨찾기" :
                                    Get.to(() => BibleFavoriteScreen()); break;
                                }
                              },

                              /* 옵션 버튼 _ 하위 메뉴 스타일 */
                              itemBuilder: (context) => [
                                /*삭제*/
                                PopupMenuItem(child: Row(children: [Icon(FontAwesome.trash_empty, size: 20), Text(" 삭제", style: TextStyle(fontSize: GeneralCtr.Textsize*0.9))]), value: "삭제"),
                                /*검색*/
                                PopupMenuItem(child: Row(children: [Icon(Entypo.search, size: 20), Text(" 검색", style: TextStyle(fontSize: GeneralCtr.Textsize*0.9))]), value: "검색"),
                                /*즐겨찾기*/
                                PopupMenuItem(child: Row(children: [Icon(FontAwesome.bookmark_empty, size: 20), Text(" 즐겨찾기", style: TextStyle(fontSize: GeneralCtr.Textsize*0.9))]), value: "즐겨찾기"),

                              ]
                          )
                        ],
                      ),

                      /* 성경 구절 메인 보여주기 */
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        /* 성경 구절 담기 */
                        child: GFCard(
                          padding: EdgeInsets.fromLTRB(5, 5, 5, 5), // 하얀카드 안쪽 텍스트 패딩
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 25), // 컨테이너 자체 마진
                          boxFit: BoxFit.fitHeight,
                          /* 구절 내영 */
                          content: WordBreakText('${result[0][BibleCtr.Bible_choiced]}',style:TextStyle(height: 1.5)),
                        ),
                      ),
                    ],
                  )
              ),
            );

            /* 2. 정보가 "null"이면, 검색 버튼을 보여준다 */
          } else {
            return AddVerses(id: id);
          }
        },
      ).toList(),
      onPageChanged: (index) {
        /* 카드 넘어갈때 이벤트 */
      },
    );
  }
}





//<서브위젯> 구절추가 빈 컨테이너
class AddVerses extends StatelessWidget {
  const AddVerses({Key? key, required this.id}) : super(key: key);

  final id;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //
          /* 옵션 버튼 */
          PopupMenuButton(
              icon: Icon(Icons.add, size: 50, color: Colors.black54), // pop메뉴 아이콘
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              padding: EdgeInsets.zero,
              tooltip: "추가기능",
              color: Colors.white, // pop메뉴 배경색
              elevation: 10,// pop메뉴 그림자
              /* 구절 조회할 옵션 선택 ( 자유 검색 또는 즐찾 ) */
              onSelected: (value) {
                /* 자유검색 상태값 변경해주기 ( diary app에서 호출했음을 알리기 위해 ) */
                BibleCtr.update_from_which_app("diary");
                /* 신규모드 입력 */
                DiaryCtr.update_mode_select("add", id);
                /* 경우의 수에 맞게 이벤트 정의 */
                switch(value){
                /* 자유검색 페이지로 이동 */
                  case"검색" : Get.to(() => BibleSearchScreen());  break;
                /* 즐겨찾기 페이지로 이동 */
                  case"즐겨찾기" : Get.to(() => BibleFavoriteScreen()); break;
                }
              },

              /* 옵션 버튼 _ 하위 메뉴 스타일 */
              itemBuilder: (context) => [
                PopupMenuItem(child: Row(children: [Icon(Entypo.search, size: 20), Text(" 검색", style: TextStyle(fontSize: GeneralCtr.Textsize*0.9))]), value: "검색"),
                PopupMenuItem(child: Row(children: [Icon(FontAwesome.bookmark_empty, size: 20), Text(" 즐겨찾기", style: TextStyle(fontSize: GeneralCtr.Textsize*0.9))]), value: "즐겨찾기"),
              ]
          )
        ],
      ),
    );
  }
}
