

import 'package:bible_in_us/diary/diary_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../general/general_controller.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';



// Gex컨트롤러 객체 초기화
final GeneralCtr = Get.put(GeneralController());
final DiaryCtr = Get.put(DiaryController());

class DiaryCalendarScreen extends StatelessWidget {
  const DiaryCalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DiaryCtr.calendar_data_mapping();
    return MainWidget();
  }
}

/* 달력에 표기할 이벤트 만들어주기 위한 맵핑 클래스, Meeting클래스인 "source"를 인풋으로 받는다 */
class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }
  @override
  DateTime getStartTime(int index) {return _getMeetingData(index).from;}
  @override
  DateTime getEndTime(int index) {return _getMeetingData(index).to;}
  @override
  String getSubject(int index) {return _getMeetingData(index).eventName;}
  @override
  Color getColor(int index) {return _getMeetingData(index).background;}
  @override
  bool isAllDay(int index) {return _getMeetingData(index).isAllDay;}

  Meeting _getMeetingData(int index) {
    final dynamic meeting = appointments![index];
    late final Meeting meetingData;
    if (meeting is Meeting) {
      meetingData = meeting;
    }
    return meetingData;
  }
}

/* <서브위젯> 메인위젯 */
Widget MainWidget(){
  return
    GetBuilder<DiaryController>(
        init: DiaryController(),
        builder: (_){
          return Scaffold(
            appBar: AppBar(
              title: Text("일기 달력", style: GeneralCtr.Style_title),
              iconTheme: IconThemeData(
                  color: GeneralCtr.MainColor
              ),
              elevation: 0,
              backgroundColor: Colors.white),
            body: Container(
              padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: SfCalendar(
                view: CalendarView.month,
                allowViewNavigation: false, // 클릭하면 상세내용으로 이동
                showNavigationArrow: true, // 날짜 전환 화살표 포함 여부
                allowedViews: [CalendarView.month, CalendarView.schedule], // "월", "일정" 등 옵션버튼
                dataSource: MeetingDataSource(DiaryCtr.meetings),
                viewHeaderHeight: 50, // 날짜와 아래 달력 거리
                headerDateFormat: 'M', // 년월 표기 서식
                monthViewSettings: MonthViewSettings(
                  //appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                  showAgenda: true,
                ),
                scheduleViewSettings: ScheduleViewSettings(
                  hideEmptyScheduleWeek: true,
                ),
                showDatePickerButton: true, // 날짜 선택 팝업 여부

                todayHighlightColor: GeneralCtr.MainColor, // 오늘 표시 색깔
                cellBorderColor: GeneralCtr.MainColor.withOpacity(0.0), // 테두리 색깔


              ),
            ),
          ); //return은 필수
        }
    );

}
