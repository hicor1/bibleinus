import 'package:bible_in_us/diary/diary_controller.dart';
import 'package:bible_in_us/diary/diary_write_srceen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';


final DiaryCtr = Get.put(DiaryController());

class GeneralController extends GetxController {

    /* <함수> 초기화 함수 */
    void init (){
        AppLocalNotificator_init(); // 앱 알림 플러그인 초기화
        dailyAtTimeNotification(); // 정기적인 앱 알림 등록
    }

    /* SharedPrefs 저장하기(save) */
    Future<void> SavePrefsData() async {
        //1. 객체 불러오기
        final prefs = await SharedPreferences.getInstance();
        //2. 상태값 저장할 목록 및 저장 수행
        prefs.setDouble('Textsize', Textsize);
        prefs.setDouble('Textheight', Textheight);
    }

    /* SharedPrefs 불러오기(load) */
    Future<void> LoadPrefsData() async {

        //1. 객체 불러오기
        final prefs = await SharedPreferences.getInstance();
        //2. 불러올 상태값 목록 및 데이터 업데이트
        Textsize   = prefs.getDouble('Textsize') == null ? Textsize : prefs.getDouble('Textsize')!;
        Textheight = prefs.getDouble('Textheight') == null ? Textheight : prefs.getDouble('Textheight')!;
        update(); // 상태업데이트 내용이 반영되어 로딩이 끝났음을 알려줘야함 ㄱㄱ
    }

    /* 메인컬러 정의 */
    var MainColor = Color(0xff9966ff); // 앱 전반적으로 사용될 메인 컬러 # 0xFF9966ff # 969FF3 #00c896
    var GreenColor = Color(0xff00c896); // 앱 전반적으로 사용될 메인 컬러 # 0xFF9966ff # 969FF3 #00c896
    var BlueColor = Color(0xff52dbff); // 블루계열 색상 # 0xff2196f3 # 0xff2196f3 # 0xff2979ff # 0xff536dfe # 0xff52dbff # 0xff6ec1f8

    /* 메인 텍스트 스타일 정의 */
    var Style_title       = TextStyle(color: Color(0xff9966ff), fontSize: 28, fontWeight: FontWeight.bold);
    var fontsize_normal   = 21.0;

    /* 모달창 텍스트 스타일 */
    var TextStyle_normal_accent = TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w900); // 일반적인 텍스트 스타일 정의
    var TextStyle_normal_disable = TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w300); // 일반적인 텍스트 스타일 정의

    /*  메인에 보여지는 성경구절 스타일 */
    var Textsize = 20.0; // 팝업창에서 설정할 전체 텍스트 사이즈
    var Textheight = 2.0; // 팝업창에서 설정할 전체 텍스트 높이

    var selectedPageIndex = 0; // 현재 선택된 탭
    
    /* 앱 알림 */
    late FlutterLocalNotificationsPlugin  _flutterLocalNotificationsPlugin; // 플러그인 할당

    //<함수> 탭 전환 이벤트
    void PageChanged(index){
        selectedPageIndex = index;
        update();
    }

    //<모듈> 슬라이더를 이용한 글씨크기 변경 함수
    void TextSizeChanged(newvalue){
        Textsize = newvalue;
        update();
    }
    //<모듈> 슬라이더를 이용한 글씨높이 변경 함수
    void TextHeightChanged(newvalue){
        Textheight = newvalue;
        update();
    }

   //<함수> 앱 알림 _ 초기화 # https://velog.io/@gwd0311/Flutter-%ED%91%B8%EC%8B%9C%EC%95%8C%EB%A6%BC-%EA%B5%AC%ED%98%84
    void AppLocalNotificator_init(){
        //안드로이드용 아이콘파일 이름
        var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
        //ios에서 앱 로드시 유저에게 권한요청하려면
        var initializationSettingsIOS = IOSInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
        );

        var initializationSettings = InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS
        );
        _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
        _flutterLocalNotificationsPlugin.initialize(
            initializationSettings,
            //onSelectNotification: 함수명추가
            /* 알림 누르면 오늘 일기 쓰는 페이지로 바로 이동 */
            onSelectNotification: (payload){
                //모드선택 ( 신규(new) 또는 수정(modify) )
                DiaryCtr.select_NewOrModify("new");
                // 작성하기 스크린으로 이동
                Get.to(() => DiaryWriteScreen());
            }
        );
    }


    //<함수> 앱 알림 _ 기본 알림
    Future<void> showNotification() async {
        var android = AndroidNotificationDetails(
            'your channel id', // 유니크한 알림 채널 ID
            'your channel name', // 알림종류 설명
            channelDescription : "this is my app",
            importance: Importance.max,
            priority: Priority.high,
            //color: MainColor,
            ticker: 'ticker'
        );
        var ios = IOSNotificationDetails(
            subtitle: "IOS subtitle",
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
        );
        var detail = NotificationDetails(
            android: android,
            iOS: ios);
        await _flutterLocalNotificationsPlugin.show(
            0, // 알림 id ??
            '일기쓸 시간이에요', // 제목
            '오늘 하루는 어땠나요?', // 내용
            detail,
            payload: '성경 일기',// 부가정보
        );
    }

    //<함수> 앱 알림 _ 매일 같은 시간 알림을 알려줍니다.
    Future<void> dailyAtTimeNotification() async {
        //시간은 24시간으로 표시합니다아.
        var time = Time(22, 00, 00); // 시간, 분, 초

        var android = AndroidNotificationDetails(
            'your channel id', // 유니크한 알림 채널 ID
            'your channel name', // 알림종류 설명
            channelDescription : "this is my app",
            importance: Importance.max,
            priority: Priority.high,
            //color: MainColor,
            ticker: 'ticker'
        );
        var ios = IOSNotificationDetails(
            subtitle: "IOS subtitle",
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
        );
        var detail = NotificationDetails(
            android: android,
            iOS: ios);

        await _flutterLocalNotificationsPlugin.showDailyAtTime(
            0, // 알림 id ??
            '일기쓸 시간이에요', // 제목
            '오늘 하루는 어땠나요?', // 내용
            time,
            detail,
            payload: '성경 일기',// 부가정보
        );
    }

}