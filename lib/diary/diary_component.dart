// 검색 글자수 모자람 경고창 띄우기
import 'package:bible_in_us/bible/bible_component.dart';
import 'package:bible_in_us/diary/diary_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final DiaryCtr   = Get.put(DiaryController());

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