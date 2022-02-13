import 'package:bible_in_us/diary/diary_controller.dart';
import 'package:bible_in_us/general/general_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/typicons_icons.dart';
import 'package:fluttericon/web_symbols_icons.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:word_break_text/word_break_text.dart';
import 'package:kpostal/kpostal.dart';

// Gex컨트롤러 객체 초기화
final GeneralCtr = Get.put(GeneralController());
final DiaryCtr = Get.put(DiaryController());


/* 입력 컨테이터 _ 폼필드 (formfield)에 필요한 각종 변수 정의 */
final _formKey = GlobalKey<FormState>();// 폼에 부여할 수 있는 유니크한 글로벌 키를 생성한다.
String title = ""; // 이메일 주소 저장
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
                    onPressed: (){},
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
                  GFCarousel(
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

                    items: [1,null].map(
                          (id) {

                        /* 성경 구절 카드에 담아서 보여주기 */
                            /* 1. 정보가 "null"이 아니면, 구절 정보 담아서 보여준다 */
                        return id != null ? Container(
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
                                    Text("  [예레미야 29:11]"),
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
                                        },

                                        /* 옵션 버튼 _ 하위 메뉴 스타일 */
                                        itemBuilder: (context) => [
                                          PopupMenuItem(child: Row(children: [Icon(FontAwesome.trash_empty, size: GeneralCtr.Textsize*0.9), Text(" 삭제", style: TextStyle(fontSize: GeneralCtr.Textsize*0.9))]), value: "삭제"),
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
                                    content: WordBreakText('여를 향한 나생각을 한 니라 너희에의 생각을 한 나의 생각을 내가 니라 너희에평안이요 내가 니요 재앙이 아니니라게 미래와 희망을 주는 것이니라',style:TextStyle(height: 1.5)),
                                  ),
                                ),
                              ],
                            )
                          ),
                        )

                        /* 2. 정보가 "null"이면, 구절 정보 담아서 보여준다 */
                            :
                        Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, size: 30, color: Colors.grey,)
                            ],
                          ),
                        );
                      },
                    ).toList(),
                    onPageChanged: (index) {
                      /* 카드 넘어갈때 이벤트 */
                    },
                  ),

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

                    height: 600,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [

                        /* 칼라코드 보여주기 */
                        Container(
                          padding: EdgeInsets.fromLTRB(15, 20, 0, 5),
                          height : 60,
                          child: ListView.builder(
                            //physics: const NeverScrollableScrollPhysics(), // 빌더 내부에서 별도로 스크롤 관리할지, 이게 활성화 된경우 전체 스크롤보다 해당 스크롤이 우선되므로 일단은 비활성화가 좋다
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
                                  padding: EdgeInsets.fromLTRB(0, 20, 0, 5),
                                  height : 60,
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
