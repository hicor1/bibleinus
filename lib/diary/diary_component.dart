// 검색 글자수 모자람 경고창 띄우기
import 'package:bible_in_us/bible/bible_component.dart';
import 'package:bible_in_us/diary/diary_controller.dart';
import 'package:bible_in_us/diary/diary_tab_page.dart';
import 'package:bible_in_us/diary/diray_view_page.dart';
import 'package:bible_in_us/general/general_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:numberpicker/numberpicker.dart';


final DiaryCtr   = Get.put(DiaryController());
final GeneralCtr = Get.put(GeneralController());

/* 안내창 띄우기 */
void DiaryDialog(context, String msg) {
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
                msg,
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



// 일기 작성페이지에서 "초기화" 할건지 한번더 묻는 안내창
Future<void> IsInit(context) async {
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
          content: Text("작성내용을 초기화 하겠습니까?"),
          actions: <Widget>[
            OutlinedButton(
              child: new Text("확인"),
              onPressed: () {
                // 1. 초기화 모듈 작동
                DiaryCtr.diray_write_screen_init();
                // 2. 안내 메세지
                PopToast("페이지 초기화 안료");
                // 3. 팝업창 닫기
                Navigator.pop(context);
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



// 일기 뷰(view)페이지에서 "삭제" 할건지 한번더 묻는 안내창
Future<void> Delete_check_Dialog(context, Docid, index) async {
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
          content: Text("선택한 일기를 삭제 하겠습니까?"),
          actions: <Widget>[
            OutlinedButton(
              child: new Text("확인"),
              onPressed: () {
                // 1. 삭제 모듈 작동
                DiaryCtr.DeleteAction(Docid, index);
                // 2. 안내 메세지
                PopToast("삭제 안료");
                // 3. 팝업창 닫기
                Navigator.pop(context);
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



// 일기 작성페이지에서 "수정 또는 저장" 할건지 한번더 묻는 안내창
Future<void> Save_check_Dialog(context) async {
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
          content: Text(DiaryCtr.NewOrModify == "new" ? "새로운 일기를 등록 하시겠습니까?" : "일기를 수정 하시겠습니까?"),
          actions: <Widget>[
            OutlinedButton(
              child: Text("확인"),
              onPressed: () {
                // 1. 저장 모듈 작동
                // 1-1. 신규 저장인경우
                if(DiaryCtr.NewOrModify=="new"){
                  DiaryCtr.Firebase_save();
                // 1-2. 수정 저장인경우
                }else if(DiaryCtr.NewOrModify=="modify"){
                  DiaryCtr.diary_modify_save();
                }
                // 2. 팝업창 닫기
                Navigator.pop(context);
                // 3. 일기view 페이지로 돌아가기
                Get.offAll(() => DiaryTabPage());
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


// <위젯> 카메 또는 갤러리 선택 모듈
Future<void> GalleryOrCam(context, index) async {
  await showDialog(
      context: context,
      //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SizedBox(
          child: AlertDialog(
            // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            //Dialog Main Title
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("사진/카메라", style: TextStyle(fontSize: GeneralCtr.fontsize_normal, fontWeight:FontWeight.bold)),
              ],
            ),
            content: SizedBox(
              height: 100,
              child: Column(
                children: [
                  InkWell(
                    onTap: (){
                      /* 갤러리 열기 */
                      DiaryCtr.GalleryOrCam_choice("gallery");
                      DiaryCtr.galleryImagePicker(index);
                      Navigator.pop(context);
                    },
                    child: Container(
                        padding: EdgeInsets.all(15),
                        width: MediaQuery.of(context).size.width,
                        child: Text("앨범에서 사진 선택", style: TextStyle(fontSize: GeneralCtr.fontsize_normal*0.8))
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      /* 카메라 열기 */
                      DiaryCtr.GalleryOrCam_choice("camera");
                      DiaryCtr.galleryImagePicker(index);
                      Navigator.pop(context);
                    },
                    child: Container(
                        padding: EdgeInsets.all(15),
                        width: MediaQuery.of(context).size.width,
                        child: Text("카메라에서 사진 촬영", style: TextStyle(fontSize: GeneralCtr.fontsize_normal*0.8))
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      });
}


// 일기 작성(write)페이지에서 "이젠페이지" 돌아갈건지 한번더 묻는 안내창
Future<void> Getback_check_Dialog(context) async {
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
          content: Text("작성중인 내용이 있습니다.\n이전 페이지로 돌아가시겠습니까?"),
          actions: <Widget>[
            OutlinedButton(
              child: new Text("확인"),
              onPressed: () {
                // 1. 일기 작성(write)페이지 초기화
                DiaryCtr.diray_write_screen_init();
                // 2. 이전 페이지 돌아가기
                Get.back();
                // 3. 팝업창 닫기
                Navigator.pop(context);
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


// 일기 작성(write)페이지에서 "날짜선택"  안내창
Future<void> Date_picker_Dialog(context) async {
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
              new Text("날짜 선택"),
            ],
          ),
          content: 
          /* 날짜 선택 위젯 띄우기 */
          Container(
            width: 300,
            height: 250,
            child: SfDateRangePicker(

              monthFormat: 'M월', // 월 표기 서식
              controller: DiaryCtr.datePickerController, // 컨트롤러 할당
              showActionButtons: false, //"확인", "취소"버튼 보이기
              cancelText: "취소",
              confirmText: "확인",
              //onSelectionChanged: _onSelectionChanged,
              showNavigationArrow: true,
              showTodayButton: false, // 오늘 날짜 선택 할수 있는 버튼
              view: DateRangePickerView.month,
              selectionMode: DateRangePickerSelectionMode.single,
            ),
          ),
          actions: <Widget>[
            OutlinedButton(
              child: new Text("확인"),
              onPressed: () {
                /* 1. 선택된 날짜로 설정 */
                DiaryCtr.SelectedDate_change();
                // 2. 팝업창 닫기
                Navigator.pop(context);
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

// 일기 뷰(view)페이지에서 "날짜선택(년, 월 까지만 )"  안내창
Future<void> Date_picker_Dialog_For_View_page(context) async {
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
              new Text(
                "언제로 이동할까요?",
                style: TextStyle(fontSize: GeneralCtr.fontsize_normal, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content:
          /* 날짜 선택 위젯 띄우기 */
          GetBuilder<DiaryController>(
              init: DiaryController(),
              builder: (_){
                return
                  Container(
                    width: 300,
                    height: 150,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /* 년도(Year) 선택하는 부분 */
                        NumberPicker(
                            infiniteLoop: true,
                            itemCount: 3, // 한번에 보여질 숫자 갯수
                            haptics: false, //??????
                            textMapper: (s){
                              return "$s년";
                            },
                            textStyle: TextStyle(color: Colors.grey),
                            selectedTextStyle: TextStyle(color: GeneralCtr.MainColor, fontSize: GeneralCtr.fontsize_normal, fontWeight: FontWeight.bold),
                            value: DiaryCtr.diary_view_selected_year_temp,
                            minValue: 2001,
                            maxValue: 2100,
                            onChanged: (value) {DiaryCtr.ViewPage_Select_Year_Temp(value);}
                        ),
                        /* 월(Month) 선택하는 부분 */
                        NumberPicker(
                            infiniteLoop: true,
                            itemCount: 3, // 한번에 보여질 숫자 갯수
                            haptics: false, //??????
                            textMapper: (s){
                              return "$s월";
                            },
                            textStyle: TextStyle(color: Colors.grey),
                            selectedTextStyle: TextStyle(color: GeneralCtr.MainColor, fontSize: GeneralCtr.fontsize_normal, fontWeight: FontWeight.bold),
                            value: DiaryCtr.diary_view_selected_month_temp,
                            minValue: 1,
                            maxValue: 12,
                            onChanged: (value) {DiaryCtr.ViewPage_Select_Month_Temp(value);}
                        ),
                      ],
                    )

                  ); //return은 필수
              }
          ),
          actions: <Widget>[
            OutlinedButton(
              child: new Text("확인"),
              onPressed: () {
                /* 1. 선택된 년, 월 로 설정 */
                DiaryCtr.ViewPage_Date_Select_Confirm();
                // 2. 팝업창 닫기
                Navigator.pop(context);
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