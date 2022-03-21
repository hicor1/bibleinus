
import 'package:bible_in_us/bible/bible_controller.dart';
import 'package:bible_in_us/bible/bible_favorite_screen.dart';
import 'package:bible_in_us/bible/bible_recommend_screen.dart';
import 'package:bible_in_us/bible/bible_search_screen.dart';
import 'package:bible_in_us/diary/diary_component.dart';
import 'package:bible_in_us/diary/diary_controller.dart';
import 'package:bible_in_us/general/general_controller.dart';
import 'package:bible_in_us/my/my_controller.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/mfg_labs_icons.dart';
import 'package:fluttericon/typicons_icons.dart';
import 'package:fluttericon/web_symbols_icons.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:kpostal/kpostal.dart';
import 'package:hashtager/hashtager.dart';
import 'package:hashtager/widgets/hashtag_text_field.dart';



// Gex컨트롤러 객체 초기화
final GeneralCtr = Get.put(GeneralController());
final DiaryCtr   = Get.put(DiaryController());
final BibleCtr   = Get.put(BibleController());
final MyCtr      = Get.put(MyController());


/* 입력 컨테이터 _ 폼필드 (formfield)에 필요한 각종 변수 정의 */
final _formKey  = GlobalKey<FormState>();// 폼에 부여할 수 있는 유니크한 글로벌 키를 생성한다.

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
            backgroundColor: GeneralCtr.MainColor.withOpacity(0.1),
            appBar: AppBar(
              iconTheme: IconThemeData(
                color: GeneralCtr.MainColor
              ),
              /* 뒤로가기 버튼 */
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    /* "신규"모드 일 떄만 물어본다. "수정"모드에서는 묻지 않기 */
                    if(DiaryCtr.NewOrModify == "new"){
                      /* 작성중인 내용이 있는데 그래도 돌아갈건지 묻는 팝업창 */
                      if(DiaryCtr.IsWriting()==true){
                        /* 1. 작성중인 내용이 있다면, */
                        Getback_check_Dialog(context);
                      }else{
                        /* 2. 작성중인 내용이 없다면, */
                        Get.back();
                      }
                    }else{
                      /* "수정"때문에 맵핑해놨던 정보 초기화 */
                      DiaryCtr.diray_write_screen_init();
                      /* 이전페이지로 돌아가기 */
                      Get.back();
                    }
                  },
                  child: Icon(MfgLabs.left, size: 20)
                ),
              ),
              title: Text(DiaryCtr.NewOrModify == "new" ? "일기 쓰기" : "일기 수정하기",
                  style: GeneralCtr.Style_title
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              actions: [
                /* 초기화 버튼 => 모드선택 ( 신규(new) 또는 수정(modify) ) */
                DiaryCtr.NewOrModify == "new" ? // 수정 모드에서는 초기화 버튼 안보이도록
                TextButton(
                  onPressed: (){
                    /* 초기화 묻는 안내창 띄우기 */
                    IsInit(context);
                    },
                  child: Text("초기화", style: TextStyle(fontSize: GeneralCtr.fontsize_normal)),
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ): SizedBox(),
                /* 저장 또는 수정 버튼 */
                TextButton(
                    onPressed: (){
                      /* 저장버튼 클릭 이벤트 */
                      /*1. 텍스트폼필드의 상태가 적함한지 확인 */
                      if (_formKey.currentState!.validate()) {
                        /* Form값 가져오기 */
                        _formKey.currentState!.save();
                        /* 관련정보 넘기기 */
                        DiaryCtr.SaveAction(context);
                      /*2. 입력정보 유효성검증이 안될경우, 안내창 띄우기 */
                      } else {
                        DiaryDialog(context, "필수입력 정보 확인");
                      }
                    },
                    child: Text(DiaryCtr.NewOrModify=="new" ? "등록" : "수정", style: TextStyle(fontSize: GeneralCtr.fontsize_normal))
                )
              ],
            ),
            /* 메인 바디 정의 */
            body: SingleChildScrollView(
              //physics: NeverScrollableScrollPhysics(), // 키패드가 올라와서 화면 가려도 오류나지 않도록 ㄱㄱ
              child: Column(
                children: [

                  /* 사회적 거리두기 */
                  SizedBox(height: 30),

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

                    //height: 800, // 전체 스크롤 크기 ( 상당히 중요함! )
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [

                        /* 사회적 거리두리 */
                        SizedBox(height: 10),

                        /* 날짜 선택 */
                        InkWell(
                          onTap: (){
                            /* 날짜 선택 팝업 띄우기 */
                            Date_picker_Dialog(context);
                          },
                          /* 선택된 날짜 보여주기 */
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  "${DiaryCtr.dirary_screen_selectedDate.year}년 "
                                  "${DiaryCtr.dirary_screen_selectedDate.month}월 "
                                  "${DiaryCtr.dirary_screen_selectedDate.day}일 "
                                  "(${DiaryCtr.ConvertWeekday(DiaryCtr.dirary_screen_selectedDate.weekday)})",
                                style: TextStyle(fontSize: GeneralCtr.fontsize_normal*1.0, fontWeight: FontWeight.bold),
                              ),
                              Icon(FontAwesome.down_dir, size: GeneralCtr.fontsize_normal, color: Colors.grey)
                            ],
                          ),
                        ),

                        /* 사회적 거리두기 */
                        SizedBox(height: 5),

                        /* 이 시간에 추천해요  */
                        Time_Choice(context),

                        /* 날씨 */
                        Weather_Choice(context),

                        /* 이미티콘 보여주는 위젯 */
                        Emoticon_Choice(context),

                        /* 칼라코드 보여주기 */
                        Color_code_choice(),

                        /* 사회적 거리두기 */
                        SizedBox(height: 15),

                        /* 감정 이모티콘 선택하기(이모지(#emoji #이모티콘 선택하는 위젯) */
                        //Emoji_choice(),


                        /* 제목, 내용 등 텍스트 필드 */
                        Padding(
                          padding: const EdgeInsets.fromLTRB(13, 0, 12, 0),
                          child: Form(
                            /* Form을 위한 key(키) 할당 */
                            key: _formKey,
                            child: Column(
                              // 컬럼내 위젯들을 왼쪽부터 정렬함
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[

                                /* 제목 입력 */
                                TextFormField(
                                  controller: DiaryCtr.TitletextController,
                                  /* 저장 버튼("_formKey.save()" 눌렀을 때 이벤트 정의 */
                                  onSaved: (val){
                                    DiaryCtr.dirary_screen_title = val!; // 이메일 값 저장
                                  },
                                  /* 최대 입력가능한 글자 수 제한 */
                                  maxLength: 40,
                                  //inputFormatters: [LengthLimitingTextInputFormatter(40)],
                                  /* 사람이 입력하는 텍스트 스타일 지정 */
                                  style: TextStyle(color: Colors.black, fontSize: GeneralCtr.fontsize_normal),
                                  /* 스타일 정의 */
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Elusive.pencil, size: 15, color: Colors.grey.withOpacity(0.7)), // 전방배치 아이콘
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.blueAccent, width: 1),
                                    ),
                                    labelText: '제목을 적어주세요', // 라벨
                                    labelStyle: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 20), // 라벨 스타일
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
                                  margin: EdgeInsets.zero,
                                  padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: GeneralCtr.GreenColor.withOpacity(0.05),
                                  ),
                                  child: TextFormField(
                                    /* 최대 입력가능한 글자 수 제한 */
                                    maxLength: 1500,
                                    //inputFormatters: [LengthLimitingTextInputFormatter(1500)],
                                    controller: DiaryCtr.ContentstextController,
                                    keyboardType: TextInputType.multiline, // 줄바꿈이 있는 키도드 보여주기
                                    minLines: 5,
                                    maxLines: null,
                                    autofocus: false,
                                    autocorrect: true,
                                    //maxLines: 10,
                                    /* 저장 버튼("_formKey.save()" 눌렀을 때 이벤트 정의 */
                                    onSaved: (val){
                                      DiaryCtr.dirary_screen_contents = val!; // 일기 내용(contents) 저장
                                    },
                                    /* 사람이 입력하는 텍스트 스타일 지정 */
                                    style: TextStyle(color: Colors.black, fontSize: GeneralCtr.fontsize_normal),
                                    /* 스타일 정의 */
                                    decoration: InputDecoration(
                                      hintText: '내용을 적어주세요', // 라벨,
                                      hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 20),
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

                        /* 사진 추가 하는곳 : 모드선택 ( 신규(new) 또는 수정(modify) )*/
                        Photo_Control_widget(),

                        /* 해쉬태그 추가하는곳(#hashtag  #해시 # 태그) */
                        HashTag(context),

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
                        /* 최하단 사회적 거리두기 */
                        SizedBox(height: 150)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ); //return은 필수
        }
    );

  }
}



//<서브위젯> 성경 카드 뿌려주기
/* 아래부터 선택한 성경 카드로 보여주기 *///https://docs.getwidget.dev/gf-carousel/
class ViewVerses extends StatelessWidget {
  const ViewVerses({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GFCarousel(
      height: 180,
      activeIndicator: GeneralCtr.MainColor,
      passiveIndicator: Colors.white,
      pagerSize: 7.0,// 이미지 하단 페이지 인디케이터 크기
      enableInfiniteScroll: false, // 무한스크롤
      viewportFraction: 0.9, // 전.후 이미지 보여주기 ( 1.0이면 안보여줌 )
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
                borderRadius: BorderRadius.circular(5),
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
                          Flexible(child: SelectableText("  [${result[0]['국문']}(${result[0]['영문']}) ${result[0]['cnum']}장 ${result[0]['vnum']}절]", style: TextStyle(fontSize: GeneralCtr.fontsize_normal*0.9),)),
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
                                /*검색*/
                                PopupMenuItem(child: Row(children: [Icon(Entypo.search, size: GeneralCtr.fontsize_normal*0.7), Text(" 검색", style: TextStyle(fontSize: GeneralCtr.fontsize_normal*0.7))]), value: "검색"),
                                /*즐겨찾기*/
                                PopupMenuItem(child: Row(children: [Icon(Typicons.star, size: GeneralCtr.fontsize_normal*0.7), Text(" 즐겨찾기", style: TextStyle(fontSize: GeneralCtr.fontsize_normal*0.7))]), value: "즐겨찾기"),
                                /*삭제*/
                                PopupMenuItem(child: Row(children: [Icon(FontAwesome.trash_empty, size: GeneralCtr.fontsize_normal*0.7), Text(" 삭제", style: TextStyle(fontSize: GeneralCtr.fontsize_normal*0.7))]), value: "삭제"),

                              ]
                          )
                        ],
                      ),

                      /* 사회적 거리두기 */
                      SizedBox(height: 5),

                      /* 성경 구절 메인 보여주기 */
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        /* 성경 구절 담기 */
                        child: GFCard(
                          padding: EdgeInsets.fromLTRB(5, 5, 5, 5), // 하얀카드 안쪽 텍스트 패딩
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 25), // 컨테이너 자체 마진
                          boxFit: BoxFit.fitHeight,
                          /* 구절 내용 */
                          content: SizedBox(
                              height: 80,
                              child: SelectableText('${result[0][BibleCtr.Bible_choiced]}',style: TextStyle(fontSize: GeneralCtr.fontsize_normal*0.9))),
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
                /* 즐겨찾기 페이지로 이동 */
                  case"추천" : Get.to(() => BibleRecommendScreen()); break;
                }
              },

              /* 옵션 버튼 _ 하위 메뉴 스타일 */
              itemBuilder: (context) => [
                PopupMenuItem(child: Row(children: [Icon(Entypo.search, size: 20), Text(" 검색", style: TextStyle(fontSize: GeneralCtr.fontsize_normal*0.7))]), value: "검색"),
                PopupMenuItem(child: Row(children: [Icon(FontAwesome.bookmark_empty, size: 20), Text(" 즐겨찾기", style: TextStyle(fontSize: GeneralCtr.fontsize_normal*0.7))]), value: "즐겨찾기"),
                PopupMenuItem(child: Row(children: [Icon(Typicons.tags, size: 20), Text(" 추천", style: TextStyle(fontSize: GeneralCtr.fontsize_normal*0.7))]), value: "추천"),
              ]
          )
        ],
      ),
    );
  }
}


//<서브위젯> 사진 추가 & 수정 작업 ("신규", "수정" 작성인 경우 모두 포함)
class Photo_Control_widget extends StatelessWidget {
  const Photo_Control_widget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        height: 150,
        width: MediaQuery.of(context).size.width,
        child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(), // 빌더 내부에서 별도로 스크롤 관리할지, 이게 활성화 된경우 전체 스크롤보다 해당 스크롤이 우선되므로 일단은 비활성화가 좋다
            shrinkWrap: true, //"hassize" 같은 ㅈ같은 오류 방지
            scrollDirection: Axis.horizontal, // 수직(vertical)  수평(horizontal) 배열 선택
            itemCount: 3,
            itemBuilder: (context, index) {
              /* 결과 할당, 이런식으로 변수 선언 가능, 아래 위젯에서 활용 가능 */
              var result = DiaryCtr.choiced_image_file[index];
              /* 타입정보로부터  파일타입(신규등록)인지, URL string타입(수정) 구분한다 */
              var type = result.runtimeType;
              /* 1. URL string타입(수정)인 경우 사진 보여주는 방식 */
              if (type == String) {
                if(result != ""){
                  /* 1. 유효한 이미지 경로가 있는경우 */
                  return Url_Img_view(context, result, index);
                }else{
                  /* 2. 유효한 이미지 경로가 없는경우 */
                  return Img_Add(context, index);
                }
              }
              /* 2. 파일타입(신규등록)인 경우 사진 보여주는 방식 */
              else {
                /* 1. 유효한 이미지 경로가 있는경우 */
                if (result.path.isEmpty == false) {
                  /* 1. 유효한 이미지 경로가 있는경우 */
                  return File_Img_view(context, result, index);
                } else {
                  /* 2. 유효한 이미지 경로가 없는경우 */
                  return Img_Add(context, index);
                }
              }
            }
        )
    );
  }
}

//<서브위젯> 칼라코드 선택하는 위젯
Widget Color_code_choice(){
  return
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
                  child: Stack(
                    alignment: Alignment.topLeft,
                    children: [
                      Icon(
                        FontAwesome5.book_medical,
                        color: result,
                        size: 35,
                      ),
                      /* 선태된 색 강조 */
                      Icon(
                          index == DiaryCtr.dirary_screen_color_index ? WebSymbols.ok : null,
                          color: Colors.deepOrangeAccent, size: 15
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 15)
              ],
            );
          }
      ),
    );
}

//<서브위젯> 이모지(#emoji #이모티콘) 선택하는 위젯
Widget Emoji_choice(){
  return
    Container(
      padding: EdgeInsets.fromLTRB(15, 10, 0, 5),
      height : 60,
      child: ListView.builder(
        //physics: const NeverScrollableScrollPhysics(), // 빌더 내부에서 별도로 스크롤 관리할지, 이게 활성화 된경우 전체 스크롤보다 해당 스크롤이 우선되므로 일단은 비활성화가 좋다
        //reverse: true,
          shrinkWrap: true, //"hassize" 같은 ㅈ같은 오류 방지
          scrollDirection: Axis.horizontal, // 수직(vertical)  수평(horizontal) 배열 선택
          //controller: ,// 스크롤 조작이 필요하다면 할당 ㄱㄱ
          itemCount: DiaryCtr.EmojiCode.length,
          itemBuilder: (context, index) {
            var result = DiaryCtr.EmojiCode[index]; // 결과 할당, 이런식으로 변수 선언 가능, 아래 위젯에서 활용 가능
            return Row(
              children: [
                InkWell(
                  onTap: (){
                    /* 이모지 코드 선택 이벤트 */
                    DiaryCtr.update_dirary_screen_emoji_index(index);
                    },
                    /* 이모지 코드 보여주기 */
                    child: Stack(
                      alignment: Alignment.topLeft,
                      children: [
                        Text("${result}", style: TextStyle(fontSize: 30)), // 이모지 크기
                        /* 선태된 이모지 강조 */
                        Icon(
                            index == DiaryCtr.dirary_screen_emoji_index ? WebSymbols.ok : null,
                            color: Colors.deepOrangeAccent, size: 15
                        ),
                      ],
                    )//
                ),
                SizedBox(width: 10)
              ],
            );
          }
      ),
    );
}


//<서브위젯> 사진 모듈 ( 이미지가 URL 인 경우 )
Widget Url_Img_view(context, result, index){
  return Row(
    children: [
      Stack( // 사진 위에 취소(cancel)버튼 겹치기
        alignment: Alignment.topRight,
        children: [
          SizedBox(
            height : MediaQuery.of(context).size.width / 4.8, // 4:3맞추기
            width  : MediaQuery.of(context).size.width / 3.6, // 4:3맞추기
            child  : Image.network(result),
          ),
          IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              splashColor: Colors.blueAccent,
              onPressed: () {
                /* 이미지 삭제 모듈 */
                DiaryCtr.DeleteImg(index);
              },
              icon: Icon(
                  WebSymbols.cancel_circle,
                  color: Colors.black.withOpacity(0.7), size: 20))
        ],
      ),
      SizedBox(width: 5.5)
    ],
  );
}


//<서브위젯> 사진 모듈 ( 이미지가 파일(file) 인 경우 )
Widget File_Img_view(context, result, index){
  return Row(
    children: [
      Stack( // 사진 위에 취소(cancel)버튼 겹치기
        alignment: Alignment.topRight,
        children: [
          SizedBox(
            height : MediaQuery.of(context).size.width / 4.8, // 4:3맞추기
            width  : MediaQuery.of(context).size.width / 3.6, // 4:3맞추기
            child  : Image.file(result),
          ),
          IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              splashColor: Colors.blueAccent,
              onPressed: () {
                /* 이미지 삭제 모듈 */
                DiaryCtr.DeleteImg(index);
              },
              icon: Icon(
                  WebSymbols.cancel_circle,
                  color: Colors.black.withOpacity(0.7), size: 20))
        ],
      ),
      SizedBox(width: 5.5)
    ],
  );
}


//<서브위젯> 사진 추가 모듈 ( 이미지가 없는 경우 )
Widget Img_Add(context, index){
  return Row(
    children: [
      /* 사진이 미입력된 컨테이너 */
      Material(
        child: InkWell(
          onTap: () {
            /* 갤러리 또는 카메라 팝업창 모듈 */
            GalleryOrCam(context, index);
          },
          child: DottedBorder(
            borderType: BorderType.RRect,
            radius: Radius.circular(4),
            color: Colors.grey.withOpacity(0.4),
            strokeWidth: 1,
            child: SizedBox(
              height: MediaQuery.of(context).size.width / 4.8,
              width: MediaQuery.of(context).size.width / 3.6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add,
                      color: Colors.grey.withOpacity(0.4))
                ],
              ),
            ),
          ),
        ),
      ),
      SizedBox(width: 5.5)
    ],
  );
}


//<서브위젯> 해시태그 입력 모듈
Widget HashTag(context){
  return
    Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("#해시태그", style: TextStyle(fontWeight: FontWeight.bold)),
            /* 해시태그 텍스트필드가 포커스 바뀔때마다 태그 유효성 검증 및 변경 */
            FocusScope(
              onFocusChange: (value) {
                if (!value) {
                  /* 변경 액션 _ 태그 클리닝 */
                  DiaryCtr.hash_tag_cleaning();
                }
              },
              child: HashTagTextField(
                /* 해시태그 작성 완료 버튼 누를 때마다 태그 유효성 검사 ㄱㄱ */
                onEditingComplete: (){DiaryCtr.hash_tag_cleaning();},
                /* 컨트롤러 할당 _ 결과값 저장을 위함 */
                controller:DiaryCtr.HashTagController,
                /* 해시태그 최대글자 수 제한 */
                inputFormatters: [LengthLimitingTextInputFormatter(35)],
                /* 스타일 정의 */
                decoration: InputDecoration(
                  isDense: false,
                  contentPadding: EdgeInsets.fromLTRB(0, 7, 0, 0),// 텍스트필드 패딩 없애기
                  labelText: '#해시 #태그 #추가', // 라벨
                  labelStyle: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: GeneralCtr.fontsize_normal*0.8), // 라벨 스타일
                  floatingLabelStyle: TextStyle(fontSize: 15), // 포커스된 라벨 스타일
                ),
                decoratedStyle: TextStyle(fontSize: GeneralCtr.fontsize_normal*0.85, color: Colors.blueAccent), // #해시태그 텍스트 스타일
                basicStyle: TextStyle(fontSize: GeneralCtr.fontsize_normal, color: Colors.black), // 일반 텍스트 스타일
              ),
            ),
          ],
        )
    );
}

//<서브위젯> 시간 선택 모듈
Widget Time_Choice(context){
  return
    /* 이 시간에 추천해요  */
    Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Text("지금은", style: TextStyle(fontWeight: FontWeight.bold)),
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
                                color: index == DiaryCtr.dirary_screen_timetag_index ? Colors.black : Colors.grey.withOpacity(0.5),
                                fontWeight: index == DiaryCtr.dirary_screen_timetag_index ? FontWeight.bold : null,
                                fontSize: GeneralCtr.fontsize_normal*0.8)
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          side: BorderSide(
                            width: 1,
                            color: index == DiaryCtr.dirary_screen_timetag_index ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                    );
                  }
              ),
            ),
          ],
        )
    );
}

//<서브위젯> 날씨 선택 모듈
Widget Weather_Choice(context){
  /* 오늘 날씨는  */
  return Container(
    padding: EdgeInsets.fromLTRB(15, 10, 0, 5),
    height : 60,
    child: ListView.builder(
      //physics: const NeverScrollableScrollPhysics(), // 빌더 내부에서 별도로 스크롤 관리할지, 이게 활성화 된경우 전체 스크롤보다 해당 스크롤이 우선되므로 일단은 비활성화가 좋다
      //reverse: true,
        shrinkWrap: true, //"hassize" 같은 ㅈ같은 오류 방지
        scrollDirection: Axis.horizontal, // 수직(vertical)  수평(horizontal) 배열 선택
        //controller: ,// 스크롤 조작이 필요하다면 할당 ㄱㄱ
        itemCount: DiaryCtr.WeatherName.length,
        itemBuilder: (context, index) {
          var result = DiaryCtr.WeatherName[index]; // 결과 할당, 이런식으로 변수 선언 가능, 아래 위젯에서 활용 가능
          return Row(
            children: [
              InkWell(
                  onTap: (){
                    /* 이모지 코드 선택 이벤트 */
                    DiaryCtr.update_dirary_screen_weather_index(index);
                  },
                  /* 이모지 코드 보여주기 */
                  child: Opacity(
                    /* 선택된 아이콘 강조 해주기 */
                    opacity: DiaryCtr.dirary_screen_weather_index == index? 1.0 : 0.3,
                    child: Image.asset(
                      "assets/img/icons/weather/$result.png",
                      height: 40.0,
                      width: 40.0,
                    ),
                  )//
              ),
              /* 아이콘 사회적 거리두기 */
              SizedBox(width: 20)
            ],
          );
        }
    ),
  );
}

//<서브위젯> 날씨 선택 모듈
Widget Emoticon_Choice(context){
  /* 오늘 날씨는  */
  return Container(
    padding: EdgeInsets.fromLTRB(15, 10, 0, 5),
    height : 60,
    child: ListView.builder(
      //physics: const NeverScrollableScrollPhysics(), // 빌더 내부에서 별도로 스크롤 관리할지, 이게 활성화 된경우 전체 스크롤보다 해당 스크롤이 우선되므로 일단은 비활성화가 좋다
      //reverse: true,
        shrinkWrap: true, //"hassize" 같은 ㅈ같은 오류 방지
        scrollDirection: Axis.horizontal, // 수직(vertical)  수평(horizontal) 배열 선택
        //controller: ,// 스크롤 조작이 필요하다면 할당 ㄱㄱ
        itemCount: DiaryCtr.EmoticonName.length,
        itemBuilder: (context, index) {
          var result = DiaryCtr.EmoticonName[index]; // 결과 할당, 이런식으로 변수 선언 가능, 아래 위젯에서 활용 가능
          return Row(
            children: [
              InkWell(
                  onTap: (){
                    /* 이모지 코드 선택 이벤트 */
                    DiaryCtr.update_dirary_screen_emoticon_index(index);
                  },
                  /* 이모지 코드 보여주기 */
                  child: Opacity(
                    /* 선택된 아이콘 강조 해주기 */
                    opacity: DiaryCtr.dirary_screen_emoticon_index == index? 1.0 : 0.3,
                    child: Image.asset(
                      "assets/img/icons/emoticon/$result.png",
                      height: 35.0,
                      width: 35.0,
                    ),
                  )//
              ),
              /* 아이콘 사회적 거리두기 */
              SizedBox(width: 25)
            ],
          );
        }
    ),
  );
}