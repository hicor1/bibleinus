import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:bible_in_us/bible/bible_component.dart';
import 'package:bible_in_us/bible/bible_controller.dart';
import 'package:bible_in_us/diary/diary_component.dart';
import 'package:bible_in_us/diary/diary_write_srceen.dart';
import 'package:bible_in_us/my/my_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:bible_in_us/bible/bible_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

final BibleCtr = Get.put(BibleController());
final MyCtr = Get.put(MyController());

class DiaryController extends GetxController {

  //<함수> 초기화
  void init(){
  }

  /* <변수>정의 */
  var dirary_screen_address = ""; // 성경일기 작성 페이지 _ 선택된 주소
  var dirary_screen_color_index = 0; // 성경일기 작성 페이지 _ 선택된 색깔 인덱스
  var dirary_screen_timetag_index = 0; // 성경일기 작성 페이지 _ 선택된 시간태그 인덱스
  var dirary_screen_title = "";    //성경일기 작성 페이지 _ 일기 제목 ( title )
  var dirary_screen_contents = ""; //성경일기 작성 페이지 _ 일기 내용 ( contents )

  var dirary_screen_selected_verses_id = [99999]; // 성경일기 작성 페이지 _ 선택된 구절 인덱스 리스트

  var Temp_selected_contents_id   = 0; // 구절 id 수정을 위한  선택된 구절 아이디값 임시저장
  var mode_select                 = ""; // "add" or "replace" 중 모드 선택
  var selected_contents_data      = []; // DB에서 조회한 선택된 구절 정보 담는공간
  var choiced_image_file = [File(""),File(""),File("")]; // 선택된 사진 3장 경로 저장(빈경로), ( 3장으로 제한 )

  var diary_view_contents = []; // 성경일기 뷰 페이지 _ 데이터 로드
  var diary_view_timediffer = []; // 성경일기 뷰 페이지 _ 시간경과 산출데이터 저장

  /* 칼라코드 정의 */
  var ColorCode = [Color(0xFFBFBFBF), // 젤 처음은 흑백 칼라
    Color(0xFFffd700).withOpacity(0.8),
    Color(0xFF00bfff).withOpacity(0.8),
    Color(0xFF32cd32).withOpacity(0.8),
    Color(0xff9966ff).withOpacity(0.8),
    Color(0xFFF781D8).withOpacity(0.8),

    Color(0xFFFFBF00).withOpacity(0.8),
    Color(0xFF6495ED).withOpacity(0.8),
    Color(0xFF9FE2BF).withOpacity(0.8),
    Color(0xFFE9967A).withOpacity(0.8),
    Color(0xFFFFA07A).withOpacity(0.8),
    Color(0xFFE9967A).withOpacity(0.8),

    Color(0xFF808000).withOpacity(0.8),
    Color(0xFF008000).withOpacity(0.8),
    Color(0xFF008080).withOpacity(0.8),
  ];

  /* 시간 추천 태크 정의 */
  var TimeTag = [
    "촉촉한 새벽","새로운 아침","나른한 낮 시간","빛나는 오후","설레는 퇴근","따뜻한 저녁","별 헤는 밤"
  ];

  //<함수> 성경일기 작성스크린 _ 주소 입력
  void update_dirary_screen_address(String address){
    dirary_screen_address = address;
    update();
  }

  //<함수> 성경일기 작성스크린 _ 색깔 인덱스 선택
  void update_dirary_screen_color_index(int index){
    dirary_screen_color_index = index;
    update();
  }

  //<함수> 성경일기 작성스크린 _ 타임태그 인덱스 선택
  void update_dirary_screen_timetag_index(int index){
    dirary_screen_timetag_index = index;
    update();
  }

  //<함수> 성경일기 작성스크린 _ 선택된 구절 아이디 초기화
  void init_selected_verses_id(){
    dirary_screen_selected_verses_id = [99999];
    update();
  }

  //<함수> 선택한 구절 id 정보 "추가(add)" 또는 "수정(replace)"하고 DB에서 재조회 하기
  Future<void> add_verses_id (int id) async {
    /* 더미(99999) 잠깐 지우기(순서 맞추기 위함) */
    dirary_screen_selected_verses_id.remove(99999);
    /* !!모드에 따라 다른 로직 적용!! */
    if(mode_select == "add"){
      /* 1. 추가 모드 */
      dirary_screen_selected_verses_id.add(id);/* 선택한 구절 id 담기 */
    }else if(mode_select == "replace"){
      /* 2. 수정 모드 */
      int index = dirary_screen_selected_verses_id.indexOf(Temp_selected_contents_id); // 선택한 구절 아이디가 전체 리스트에서 몇번째 인덱스인지 확인
      dirary_screen_selected_verses_id[index] = id; // 선택한 구절 아이디를 새로운 구절 아이돌 수정(replace)
    }

    /* 중복값 제거하기 */
    dirary_screen_selected_verses_id = dirary_screen_selected_verses_id.toSet().toList();
    /* 더미(99999) 다시 넣기 */
    dirary_screen_selected_verses_id.add(99999);
    /* 선택한 구절 DB 조회 */
    selected_contents_data = await BibleRepository.GetClickedVerses(dirary_screen_selected_verses_id, BibleCtr.Bible_choiced);
    update();
  }

  //<함수> bible메인화면에서 선택한 구절 id 리스트 정보 "추가(add)" 하고 DB에서 재조회 하기기
  Future<void> add_verses_idList() async {
    /* 선택된 구절 아이디 초기화 */
    init_selected_verses_id();
    /* Bible컨트롤러에서 선택한 구절 아이디 리스트 가져오기 */
    var idList = BibleCtr.ContentsIdList_clicked;
    /* 더미(99999) 잠깐 지우기(순서 맞추기 위함) */
    dirary_screen_selected_verses_id.remove(99999);
    /* for문 돌면서 선택한 구절 id 담기 */
    for(int i = 0; i < idList.length; i++){
      dirary_screen_selected_verses_id.add(idList[i]);
    }
    /* 중복값 제거하기 */
    dirary_screen_selected_verses_id = dirary_screen_selected_verses_id.toSet().toList();
    /* 더미(99999) 다시 넣기 */
    dirary_screen_selected_verses_id.add(99999);
    /* 선택한 구절 DB 조회 */
    selected_contents_data = await BibleRepository.GetClickedVerses(dirary_screen_selected_verses_id, BibleCtr.Bible_choiced);
    update();
    /* 일기쓰기 스크린으로 이동하기 */
    Get.to(() => DiaryWriteScreen());
  }


  //<함수> 선택한 구절 id 삭제하고 DB 재조회 하기
  Future<void> remove_verses_id (int id) async {
    /* 선택한 구절 id 담기 */
    dirary_screen_selected_verses_id.remove(id);
    /* 선택한 구절 DB 조회 */
    selected_contents_data = await BibleRepository.GetClickedVerses(dirary_screen_selected_verses_id, BibleCtr.Bible_choiced);
    /* 삭제 안내메세지 */
    PopToast("삭제 안료");
    update();
  }

  //<함수> 선택한 구절 id 수정하기 위한 현재 선택 인덱스 값 저장
  void update_mode_select(String mode, int id){
    mode_select = mode; // "add" or "replace" 중 모드 선택
    Temp_selected_contents_id = id; // 선택된 구절 아이디 값 저장
    update();
  }


  /* <함수> 갤러리에서 프로필 이미지 가져오기 */
  Future<void> galleryImagePicker(index)  async {

    /* 이미지 피커 객체 불러오기 */
    final ImagePicker _picker = ImagePicker();
    /* 갤러리에서 이미지 선택하기(용량을 줄이기 위해 이미지 리사이즈 시전) */
    final XFile? image =
    await _picker.pickImage(
        source: ImageSource.gallery,
        // 저장효율을 위해 이미지 크기 밎 퀄리티 제한
        maxHeight: 900,
        maxWidth: 1200,
    ); // https://firebase.flutter.dev/docs/storage/usage/
    /* 이미지 파일 임시 할당 */
    var _imageFile = File(image!.path);

    /* 이미지 경로 할당 */
    choiced_image_file[index] = _imageFile;
    update();
  }


  /* <함수> 사진 삭제버튼 클릭 */
  Future<void> DeleteImg( index)  async {
    /* 해당 인덱스 이미지 파일 초기화 */
    choiced_image_file[index] = File('');
    update();
  }


  /* <함수> 파이어베이스 데이터 저장 모듈  */
  Future<void> Firebase_save()  async {
    // 로딩화면 띄우기
    EasyLoading.show(status: 'loading...');

    /* 파이어스토어 객체 생성 */
    FirebaseFirestore firestore    = FirebaseFirestore.instance;
    /* 콜렉션 선택 */
    CollectionReference collection = firestore.collection('diary');

    /* 사진 이름 만들기 */
    var docID = collection.doc().id; // 파이어 스토어에 저장되는 문서 ID, 파일 저장 경로로 활용한다.
    var ImgUrl = []; // 최종 파일 downloadURL 이 저장될 공간
    for(int i = 0; i < choiced_image_file.length; i++){
      /* 이미지 경로가 비어있지 않다면 */
      var _imageFile = choiced_image_file[i]; // 이미지 파일 할당
      if(_imageFile.path.isEmpty == false){
        /* 경로 만들기 */
        var ImgSavePath = "${'diaryImg/${MyCtr.uid}/$docID/$i'}"; // 사용자UID → 문서ID → 이미지 순서 로 저장한다
        /* 파이어베이스 storage에 이미지 파일 업로드(https://firebase.flutter.dev/docs/storage/usage/) */
        try {
          /* 파이어베이스 스토리지 객체 가져오기 */
          await firebase_storage.FirebaseStorage.instance
              .ref()
              .child(ImgSavePath) // 저장 경로 설정, 파일이름은$docID/$i로 한다. 최대 3개만 저장가능하도록
              .putFile(_imageFile); // 저장할 이미지 파일 지정
        } on FirebaseException catch (e) {
          // e.g, e.code == 'canceled'
        }

        /* 위에서 저장한 이미지를 불러올 수 있는 URL 가져오기 */
        String downloadURL = await firebase_storage.FirebaseStorage.instance
            .ref(ImgSavePath)
            .getDownloadURL();

        /* 경로 모아주기 */
        ImgUrl.add(downloadURL);
      }else{
        /* 이미지 경로가 비어있다면 */
        null;
      }
    }

    /* 데이터 세이브 */
    collection.add({
      "uid":MyCtr.uid,
      "created_at":DateTime.now(),
      "dirary_screen_selected_verses_id": dirary_screen_selected_verses_id, // John Doe
      "dirary_screen_color_index": dirary_screen_color_index, // Stokes and Sons
      "dirary_screen_title": dirary_screen_title,
      "dirary_screen_contents":dirary_screen_contents,
      "choiced_image_file":ImgUrl,
      "dirary_screen_timetag_index":dirary_screen_timetag_index,
      "dirary_screen_address":dirary_screen_address,
    });

    // 리스트 다시 불러오기
    LoadAction();

    // 로딩화면 종료
    EasyLoading.dismiss();

    // 이전 페이지로 돌아가기
    Get.back();
  }

  /* <함수> 저장버튼 눌렀을 때 파이어베이스로 저장하기 */
  Future<void> SaveAction(context)  async {
    print(dirary_screen_selected_verses_id.length);

    /* 유효성 검사 */
    // 1. 최소 1개 이상의 구절 선택
    if(dirary_screen_selected_verses_id.length <= 1){
      DiaryDialog(context, "최소 1개 이상의 성경 구절을 선택해주세요");
    }else{
      /* 유효성검사를 통과했으므로 정상적인 저장 프로세스 진행 */
      Firebase_save();
      PopToast("일기가 등록되었어요!");// 안내메세지
      /* 페이지 입력된 정보 초기화(성공적으로 저장했으므로) */
      diray_write_screen_init();
    }
  }


  /* <함수> 개인별 일기 데이터 로드하기 */
  Future<void> LoadAction()  async {
    // 로딩화면 띄우기
    EasyLoading.show(status: 'loading...');

    /* 파이어스토어 객체 생성 */
    FirebaseFirestore firestore    = FirebaseFirestore.instance;
    /* 콜렉션 선택 */
    CollectionReference collection = firestore.collection('diary');
    /* 데이터 로드(조건) */
    collection
        .where("uid", isEqualTo: MyCtr.uid) // 본인이 작성한 글만 보이게
        .orderBy("created_at", descending:true) // 날짜로 내림차순 정렬
        .get().then((QuerySnapshot ds) {
          /*  불러온 데이터 할당 */
      diary_view_contents = ds.docs;
      /* 시간경과 산출 */
      diary_view_timediffer = []; // 시간 경과 저장 리스트 초기화
      for(int i = 0; i < diary_view_contents.length; i++){
        diary_view_timediffer.add(cal_time_differ(diary_view_contents[i]["created_at"]));
      }
    });// 필드명에 단어 포함

    /* 데이터 로드(단순) _ 이거는 필요없는데, 이걸 넣어줘야 오류가 안남??...ㅜ 이유는 몰겠음..*/
    var documentSnapshot = await collection.doc("test1").get();

    update();
    // 로딩화면 종료
    EasyLoading.dismiss();
  }

  /* <함수> 현재시간과의 시간차이 산출 _ 현재와의 시간차이 구하기 ( 방금_1분이내, xx시간전, xx일전, xx달전, xx년전 으로 구분 ) */
  String cal_time_differ(date){
    // 현재 시간
    var _toDay = DateTime.now();
    // 비교시간을 timestamp -> date로 형식 변환
    var target_date = date.toDate();
    // 1. 시간 산출결과 임시 저장공간
    var time_differ = "";
    // 2. 시간차이 계산 ( 분 기준으로 )
    int time_difference = int.parse(_toDay.difference(target_date).inMinutes.toString());
    // 3. 조건에 맞게 시간 재지정
    if(time_difference<=0){time_differ = "방금 전";} // 1분 미만
    else if (0 < time_difference &&  time_difference < 60){time_differ = "${time_difference}분 전";} // 1시간 미만
    else if (60 < time_difference &&  time_difference < 60*24){time_differ = "${(time_difference/60).round()}시간 전";} // 1일 미만
    else if (60*24 < time_difference &&  time_difference < 60*24*30){time_differ = "${(time_difference/(60*24)).round()}일 전";} // 1달 미만
    else if (60*24*30 < time_difference &&  time_difference < 60*24*30*12){time_differ = "${(time_difference/(60*24*30)).round()}달 전";} // 1년 미만
    else if (60*24*30*12 < time_difference){time_differ = "${(time_difference/(60*24*30*12)).round()}년 전";} // 1년 초과


    /* 결과 리턴 */
    return time_differ;
    }

  /* <함수> 일기쓰지 페이지 초기화 */
  void diray_write_screen_init(){
    dirary_screen_selected_verses_id = [99999];
    dirary_screen_color_index = 0; //
    dirary_screen_title = "";
    dirary_screen_contents = "";
    choiced_image_file = [File(""),File(""),File("")];
    dirary_screen_timetag_index = 0;
    dirary_screen_address = "";

    update();
  }

}