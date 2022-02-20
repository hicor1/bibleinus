// 토스트메세지 띄우기
import 'package:bible_in_us/bible/bible_controller.dart';
import 'package:bible_in_us/diary/diary_controller.dart';
import 'package:bible_in_us/general/general_controller.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/typicons_icons.dart';
import 'package:fluttericon/web_symbols_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:getwidget/getwidget.dart';


// Gex컨트롤러 객체 초기화
final GeneralCtr = Get.put(GeneralController());
final BibleCtr = Get.put(BibleController());
final DiaryCtr = Get.put(DiaryController());

// 페이지 없음 토스트 띄우기
void PopToast(String message){
  Fluttertoast.showToast(
      msg: message,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      fontSize: 20.0,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT
  );
}


// 검색 글자수 모자람 경고창 띄우기
void FlutterDialog(context) {
  showDialog(
      context: context,
      //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0)),
          //Dialog Main Title
          title: Column(
            children: <Widget>[
              new Text("안내 메세지"),
            ],
          ),
          //
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "검색어는 '최소 2 글자'로 해주세요.",
              ),
            ],
          ),
          actions: <Widget>[
            new ElevatedButton(
              child: new Text("확인"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      });
}

// 자유검색에서 선택한구절로 넘어갈지 묻는 경고창
Future<void> IsMoveDialog(context, result, index) async {
  var versesInfo = "${result['국문']}(${result['영문']}) :  ${result['cnum']}장";
  await showDialog(
      context: context,
      //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0)),
          //Dialog Main Title
          title: Column(
            children: <Widget>[
              new Text("안내 메세지"),
            ],
          ),
          //

          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("$versesInfo", style: TextStyle(fontWeight: FontWeight.bold),),
              Text("구절로 이동하시겠습니까"),
            ],
          ),
          actions: <Widget>[
            OutlinedButton(
              child: new Text("확인"),
              onPressed: () {
                // 1. 토스트메세지 띄우기
                PopToast("$versesInfo로 이동합니다.");
                // 2. 선택 구절을 메인에서 보여주기 위해 데이터 업데이트
                BibleCtr.MoveToContents(result);
                // 3. 팝업창 닫기
                Navigator.pop(context);
                // 4. 스크린 닫고 메인페이지로 이동하기
                BibleCtr.tabController.animateTo(0); // 메인 페이지에서 0번 째 탭으로 변경
                Get.back(); // 검색페이지는 "페이지"가 아닌, "스크린"이므로 돌아가기(back)으로 이동

              },
            ),
            ElevatedButton(
              child: new Text("취소"),
              onPressed: () {
                // "취소"인 경우, 바로 액션없이 팝업창 내리기
                Navigator.pop(context);
              },
            ),
          ],
        );
      });
}

// diary 앱에서 자유검색에서 선택한구절 담을지 묻는 경고창
Future<void> IsMoveDialog_from_diary(context, result, index) async {
  var versesInfo = "${result['국문']}(${result['영문']}) :  ${result['cnum']}장 ${result['vnum']}절";
  await showDialog(
      context: context,
      //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0)),
          //Dialog Main Title
          title: Column(
            children: <Widget>[
              new Text("안내 메세지"),
            ],
          ),
          //

          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("$versesInfo", style: TextStyle(fontWeight: FontWeight.bold),),
              Text("구절을 선택하시겠습니까"),
            ],
          ),
          actions: <Widget>[
            OutlinedButton(
              child: new Text("확인"),
              onPressed: () {
                // 1. 토스트메세지 띄우기
                PopToast("$versesInfo을 추가했습니다.");
                // 2. 선택 구절 담아주기
                DiaryCtr.add_verses_id(result["_id"]);
                // 3. 팝업창 닫기
                Navigator.pop(context);
                // 4. 이전 페이지로 돌아가기
                Get.back(); // 검색페이지는 "페이지"가 아닌, "스크린"이므로 돌아가기(back)으로 이동

              },
            ),
            ElevatedButton(
              child: new Text("취소"),
              onPressed: () {
                // "취소"인 경우, 바로 액션없이 팝업창 내리기
                Navigator.pop(context);
              },
            ),
          ],
        );
      });
}



// 설정 안내창띄우기 ( 메인 페이지 전용, 즐겨찾기 페이지는 성경 선택부분만 별도 관리해준다 ! )
void openPopup(context) {
  Alert(
      context: context,
      // 팝업창 스타일 조정
      style: AlertStyle(
        titleStyle: TextStyle(fontSize: 0, fontWeight: FontWeight.bold),
        animationDuration: Duration(milliseconds: 200),
        alertBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: BorderSide(color: Colors.grey, width: 3),
        ),
      ),
      title: "",
      content: Column(
          children: <Widget>[
            /* 0. 성경 선택 (BibleController에 집어넣기)*/
            GetBuilder<BibleController>(
                init: BibleController(),
                builder: (_){
                  return Container(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text("성경 선택", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 3),)
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.withOpacity(0.4), width: 2),
                              borderRadius: BorderRadius.circular(15)
                          ),
                          padding: EdgeInsets.all(10),
                          //height: 130,
                          child: Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.all(20),
                            child: DropdownButtonHideUnderline(
                              child: GFDropdown(
                                padding: const EdgeInsets.all(15),
                                borderRadius: BorderRadius.circular(5),
                                border: const BorderSide(color: Colors.black12, width: 1),
                                dropdownButtonColor: Colors.white,
                                /* 메인페이지와 즐겨찾기 페이지의 성경선택 변수를 따로 가져가자 ㄱㄱ*/
                                value:BibleCtr.Bible_choiced,
                                onChanged: (newValue) {
                                  /* 선택된 성경 업데이트 */
                                  BibleCtr.Bible_choice(newValue);
                                },
                                items: BibleCtr.Bible_list.map(
                                        (value) => DropdownMenuItem(
                                      value: value,
                                      child: Row(
                                        children: [
                                          Icon(FontAwesome5.bible, size: 15, color: Colors.grey,),
                                          Text("  $value")
                                        ],
                                      ), //
                                    )).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ); //return은 필수
                }
            ),
            SizedBox(height: 5),

            /* 1. 글씨크기 (GeneralController에 집어넣기)*/
            GetBuilder<GeneralController>(
                init: GeneralController(),
                builder: (_){
                  return Container(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text("글씨 크기", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 3),)
                          ],
                        ),
                        Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.withOpacity(0.4), width: 2),
                                borderRadius: BorderRadius.circular(15)
                            ),
                            padding: EdgeInsets.all(10),
                            //height: 130,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text("가나다abcABC", style: TextStyle(fontSize:GeneralCtr.Textsize),),
                                Container(
                                  width: 400,
                                  child: SfSlider(
                                    min: 10.0,
                                    max: 30.0,
                                    interval: 10,
                                    stepSize: 2,
                                    showTicks: false,
                                    minorTicksPerInterval: 1,
                                    showLabels: true,
                                    enableTooltip: true,
                                    tooltipShape: SfPaddleTooltipShape(),
                                    value: GeneralCtr.Textsize,
                                    onChanged: (dynamic newValue) {
                                      GeneralCtr.TextSizeChanged(newValue);
                                    },
                                  ),
                                ),
                              ],
                            )
                        ),
                      ],
                    ),
                  ); //return은 필수
                }
            ),

            SizedBox(height: 5),

            /* 2. 줄 간격 (GeneralController에 집어넣기)*/
            GetBuilder<GeneralController>(
                init: GeneralController(),
                builder: (_){
                  return Container(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text("줄 간격", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 3),)
                          ],
                        ),
                        Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.withOpacity(0.4), width: 2),
                                borderRadius: BorderRadius.circular(15)
                            ),
                            padding: EdgeInsets.all(10),
                            //height: 130,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text("가나다abcABC", style: TextStyle(fontSize:20),),
                                Text("가나다abcABC", style: TextStyle(fontSize:20, height:GeneralCtr.Textheight),),
                                Container(
                                  width: 400,
                                  child: SfSlider(
                                    min: 1.0,
                                    max: 3.0,
                                    interval: 1,
                                    stepSize: 0.2,
                                    showTicks: false,
                                    minorTicksPerInterval: 1,
                                    showLabels: true,
                                    enableTooltip: true,
                                    tooltipShape: SfPaddleTooltipShape(),
                                    value: GeneralCtr.Textheight,
                                    onChanged: (dynamic newValue) {
                                      /* 새로운 높이 업데이트 */
                                      GeneralCtr.TextHeightChanged(newValue);
                                    },
                                  ),
                                ),
                              ],
                            )
                        ),
                      ],
                    ),
                  ); //return은 필수
                }
            ),

            SizedBox(height: 10)
          ],
        ),
      buttons: [
        DialogButton(
          onPressed: () {
            //상태값 저장
            BibleCtr.SavePrefsData();
            GeneralCtr.SavePrefsData();
            //이전화면으로 돌아가기
            Navigator.pop(context);},
          child: Text(
            "확인",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ]).show();
}

/*  즐겨찾기 추가 팝업 _ from. 플로팅 액션 버튼 */
void AddFavorite(context) {
  Alert(
      context: context,
      // 팝업창 스타일 조정
      style: AlertStyle(
        titleStyle: TextStyle(fontSize: 0, fontWeight: FontWeight.bold),
        animationDuration: Duration(milliseconds: 200),
        alertBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: BorderSide(color: Colors.grey, width: 3),
        ),
      ),
      title: "",
      content: Column(
        children: <Widget>[
          /* 0. 성경 선택 (BibleController에 집어넣기)*/
          GetBuilder<BibleController>(
              init: BibleController(),
              builder: (_){
                return Column(
                  children: [
                    Row(
                      children: [
                        Text("즐겨찾기 추가", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 3),)
                      ],
                    ),
                    // 1. 선택된 구절 리스트
                    Container(
                      height: 200,
                      width: MediaQuery.of(context).size.width, // 요건 필수
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.withOpacity(0.4), width: 2),
                          borderRadius: BorderRadius.circular(15)
                      ),
                      padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                      //height: 130,
                      child: Scrollbar(
                        //isAlwaysShown: true,   //화면에 항상 스크롤바가 나오도록 한다
                        child: ListView.builder(
                            scrollDirection: Axis.vertical, // 수직(vertical)  수평(horizontal) 배열 선택
                            //controller: ,// 스크롤 조작이 필요하다면 할당 ㄱㄱ
                            itemCount: BibleCtr.ContentsDataList_clicked.length,
                            itemBuilder: (context, index) {
                              var result = BibleCtr.ContentsDataList_clicked[index]; // 결과 할당, 이런식으로 변수 선언 가능, 아래 위젯에서 활용 가능
                              return Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text("${result['cnum']}:${result['vnum']} | ", style: TextStyle(color: Colors.grey, fontSize: GeneralCtr.Textsize)),
                                      // 구절의 길이가 너무 길 경우, "...."으로 표현해준다.
                                      Flexible(
                                        // 색 코드에서 선택한 색상으로 배경색 변경해준다, 단 0번의 경우는 무색처리한다.
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(color: BibleCtr.ColorCode_choiced_index == 0 ? Colors.transparent : BibleCtr.ColorCode[BibleCtr.ColorCode_choiced_index]),
                                          child: Text("${result[BibleCtr.Bible_choiced]}",
                                              maxLines:2, overflow: TextOverflow.ellipsis, // 공간을 넘는 글자는 쩜쩜쩜(...)으로 표기한다.
                                              style: TextStyle(fontSize: GeneralCtr.Textsize, height: GeneralCtr.Textheight)
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(),
                                ],
                              );
                            }
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // 2. 하이라이트 색깔표 보여주기
                    Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.all(5),
                        child: Center(
                          child: ListView.builder(
                              shrinkWrap: true, // 등간격 정렬하기 위해 위에 "Center"위젯과 함께 사용
                              scrollDirection: Axis.horizontal,
                              itemCount: BibleCtr.ColorCode.length,
                              itemBuilder: (context, index) {
                                /* 각 색깔별 갯수 구하기 */
                                //1. 결과값 담을 변수 만들기
                                var colorCount = null;
                                //2. 빈값이면 "0"을 리턴하고, 그렇지 않으면 DB에서 받은값을 사용하기
                                if(BibleCtr.Favorite_Color_count.where((e)=>e['highlight_color_index']==index).isEmpty){
                                  colorCount = "0";
                                }else{
                                  colorCount = BibleCtr.Favorite_Color_count.where((e)=>e['highlight_color_index']==index).toList()[0]['count(highlight_color_index)'];
                                }
                                // 색깔 선택이 가능하도록 "InkWell" 위젯으로 감싸기
                                return InkWell(
                                  splashColor: Colors.white,
                                  onTap: (){BibleCtr.ColorCode_choice(index);},
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(6, 0, 6, 0),
                                    // 젤 처음 아이콘은 "X"표시로 변경
                                    child: Column(
                                      children: [
                                        /* 아이콘 배치(색깔에 맞게), 아이콘을 겹쳐서 강조표기해주기 */
                                        Stack(
                                            children:[
                                              Icon(
                                                  index != 0 ? FontAwesome5.star : Entypo.cancel,
                                                  color: BibleCtr.ColorCode[index], size: 25
                                              ),
                                              Icon(
                                                  BibleCtr.ColorCode_choiced_index == index ? WebSymbols.ok : null,
                                                  color: Colors.deepOrangeAccent, size: 20
                                              ),
                                            ]
                                        ),
                                        /* 색깔별 갯수 배치 (0번 인덱스는 갯수 표기 안함) */
                                        Text(
                                          index == 0 ? "취소" :
                                          " ${colorCount}", style: TextStyle(color: BibleCtr.ColorCode[index], fontSize: 15),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }
                          ),
                        )
                    ),
                    Divider(indent: 20, endIndent: 20, thickness: 3)
                  ],
                );
              }
          ),
          SizedBox(height: 30),

        ],
      ),
      buttons: [
        DialogButton(
          onPressed: () {
            // 선택결과 DB에 저장하기
            BibleCtr.ColorCode_DB_save();
            // 토스트메세지 띄우기
            PopToast("즐겨찾기 변경 완료");
            //이전화면으로 돌아가기
            Navigator.pop(context);
            },
          child: Text("확인", style: TextStyle(color: Colors.white, fontSize: 20)),
        ),
      ]).show();
}


/*  메모하기 팝업 _ from. 플로팅 액션 버튼 */
void AddMemo(context, id, action) {
  Alert(
      context: context,
      // 팝업창 스타일 조정
      style: AlertStyle(
        titleStyle: TextStyle(fontSize: 0, fontWeight: FontWeight.bold),
        animationDuration: Duration(milliseconds: 200),
        alertBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: BorderSide(color: Colors.grey, width: 3),
        ),
      ),
      title: "",
      content: Column(
        children: <Widget>[
          /* 0. 성경 선택 (BibleController에 집어넣기)*/
          GetBuilder<BibleController>(
              init: BibleController(),
              builder: (_){
                return Column(
                  children: [
                    Row(
                      children: [
                        Text("메모하기", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 3),)
                      ],
                    ),
                    /* 1. 선택된 구절 리스트 */
                    Container(
                      height: 200,
                      width: MediaQuery.of(context).size.width, // 요건 필수
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.withOpacity(0.4), width: 2),
                          borderRadius: BorderRadius.circular(15)
                      ),
                      padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
                      //height: 130,
                      child: Scrollbar(
                        //isAlwaysShown: true,   //화면에 항상 스크롤바가 나오도록 한다
                        child: ListView.builder(
                            scrollDirection: Axis.vertical, // 수직(vertical)  수평(horizontal) 배열 선택
                            //controller: ,// 스크롤 조작이 필요하다면 할당 ㄱㄱ
                            itemCount: BibleCtr.ContentsDataList_clicked.length,
                            itemBuilder: (context, index) {
                              var result = BibleCtr.ContentsDataList_clicked[index]; // 결과 할당, 이런식으로 변수 선언 가능, 아래 위젯에서 활용 가능
                              return Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text("${result['cnum']}:${result['vnum']} | ", style: TextStyle(color: Colors.grey, fontSize: GeneralCtr.Textsize)),
                                      // 구절의 길이가 너무 길 경우, "...."으로 표현해준다.
                                      Flexible(
                                        // 색 코드에서 선택한 색상으로 배경색 변경해준다, 단 0번의 경우는 무색처리한다.
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(color: result['highlight_color_index'] == 0 ? Colors.transparent : BibleCtr.ColorCode[result['highlight_color_index']]),
                                          child: Text("${result[BibleCtr.Bible_choiced]}",
                                              maxLines:3, overflow: TextOverflow.ellipsis, // 공간을 넘는 글자는 쩜쩜쩜(...)으로 표기한다.
                                              style: TextStyle(fontSize: GeneralCtr.Textsize, height: GeneralCtr.Textheight)
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider()
                                ],
                              );
                            }
                        ),
                      ),
                    ),

                    /* 사회적 거리두기 */
                    SizedBox(height: 10),


                    /* 2. 메모 입력 텍스트필드(Textfield) */
                    TextField(
                      minLines: 1,
                      maxLines: 5, // 이까지 늘어나고, 이걸 넘어서면 그냥 옆으로간다
                      controller: BibleCtr.MemotextController, // 텍스트값을 가져오기 위해 컨트롤러 할당
                      style: TextStyle(fontSize: GeneralCtr.Textsize, height: GeneralCtr.Textheight),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '메모(memo)',
                        errorText: BibleCtr.MemoErrorText,
                      )
                    )
                  ],
                );
              }
          ),
          SizedBox(height: 30),

        ],
      ),
      buttons: [
        DialogButton(
          onPressed: () {
            /* 최소 글자수 ( 2글자 ) 만족하는지 체크 */
            if(BibleCtr.MemotextController.text.length>=2){
              /* "NEW" 또는 "UPDATE" 중 액션 선택*/
              switch(action){
                // "NEW"케이스 : 메모내용 DB에 신규 저장(INSERT) 및 저장완료 Toast띄우기
                case"NEW":
                  BibleCtr.Memo_DB_save(BibleCtr.MemotextController.text);
                  PopToast("메모가 저장되었습니다.");
                  break;
                // "UPDATE"케이스 : 메모내용 DB에 수정(UPDATE) 및 수정완료 Toast띄우기
                case"UPDATE":
                  BibleCtr.Memo_update(id, BibleCtr.MemotextController.text);
                  PopToast("메모가 수정되었습니다.");
                  break;
              }
              //이전화면으로 돌아가기
              Navigator.pop(context);
            }else{
              /* 글자수 모자람 안내창 띄우기 */
              BibleCtr.MemoErrorText_update("최소 글자수는 '2글자'입니다.");
            }
          },
          child: Text("확인", style: TextStyle(color: Colors.white, fontSize: 20)),
        ),
      ]).show();
}


// 메모페이지 _ 팝업메뉴버튼에서 "삭제"버튼 누르면 띄워주는 안내창
Future<void> IsMemoDelete(context, memoId) async {
  await showDialog(
      context: context,
      //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0)),
          //Dialog Main Title
          title: Column(
            children: <Widget>[
              new Text("안내 메세지"),
            ],
          ),
          //
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("메모를 삭제하시겠습니까?"),
            ],
          ),
          actions: <Widget>[

            /* [확인]버튼 액션 정의 */
            OutlinedButton(
              child: new Text("확인"),
              onPressed: () {
                // 0. DB에서 지우기
                BibleCtr.Memo_DB_delete(memoId);
                // 1. 토스트메세지 띄우기
                PopToast("메모 삭제 완료했습니다.");
                // 2. 삭제 완료 후 창 내리기
                Navigator.pop(context);
              },
            ),
            /* [취소]버튼 액션 정의 */
            ElevatedButton(
              child: new Text("취소"),
              onPressed: () {
                // "취소"인 경우, 바로 액션없이 팝업창 내리기
                Navigator.pop(context);
              },
            ),
          ],
        );
      });
}