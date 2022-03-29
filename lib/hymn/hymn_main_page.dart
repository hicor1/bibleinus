import 'package:bible_in_us/general/general_controller.dart';
import 'package:bible_in_us/hymn/hymn_controller.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:get/get.dart';



// Gex컨트롤러 객체 초기화
final GeneralCtr = Get.put(GeneralController());
final HymnCtr = Get.put(HymnController());

class HymnMainWidget extends StatelessWidget {
  const HymnMainWidget({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    /* 페이지 로딩시에 한번 조회(전체리스트이므로 검색조건없이 조회) */
    HymnCtr.Get_type_count("");

    /* 아래부터 페이지 뿌려주기 */
    return
    /* 빌더 불러오기 */
      GetBuilder<HymnController>(
          init: HymnController(),
          builder: (_){
            return Padding(
              padding: EdgeInsets.fromLTRB(5, 10, 5, 0),
              child: Column(
                children: [
                  /* 검색부분 */
                  TextField(
                    /* 검색어를 입력 했을 때 액션 정의 */
                    onChanged: (keyword){
                      /* 조건에 맞는 찬송가 목록 가져오기 */
                      HymnCtr.Get_type_count(keyword);
                    },
                    controller: HymnCtr.searchtextController, // 텍스트값을 가져오기 위해 컨트롤러 할당
                    autofocus: false, // 자동으로 클릭할것인가
                    style: TextStyle(fontSize: GeneralCtr.fontsize_normal),
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            /* 클리어 버튼(X) 눌렀을 때 텍스트 비우기 */
                            HymnCtr.searchtextController.clear();
                            /* 조건에 맞는 찬송가 목록 가져오기 */
                            HymnCtr.Get_type_count(HymnCtr.searchtextController.text);
                          },
                        ),
                        hintText: '검색어를 입력해주세요',
                        hintStyle: GeneralCtr.TextStyle_normal_disable,
                        border: InputBorder.none),
                  ),

                  /* 사회적거리두기 표시선 */
                  Divider(indent: 0, endIndent: 0, height: 0),

                  /* 아래는 검색결과를 리스트로 보여주는 부분 */
                  Flexible(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /* 왼쪽 _ 찬송가 타입(type)이 보여지는 부분 */
                        Flexible(
                          child: Scrollbar(
                            child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(), // 빌더 내부에서 별도로 스크롤 관리할지, 이게 활성화 된경우 전체 스크롤보다 해당 스크롤이 우선되므로 일단은 비활성화가 좋다
                                shrinkWrap: true, //"hassize" 같은 ㅈ같은 오류 방지
                                scrollDirection: Axis.vertical, // 수직(vertical)  수평(horizontal) 배열 선택
                                //controller: ,// 스크롤 조작이 필요하다면 할당 ㄱㄱ
                                itemCount: HymnCtr.hymn_type_count.length,
                                itemBuilder: (context, index) {
                                  var result      = HymnCtr.hymn_type_count[index]; // 결과 할당, 이런식으로 변수 선언 가능, 아래 위젯에서 활용 가능

                                  return InkWell(
                                    onTap: (){
                                      /* 해당 타입을 눌렀을 때 이벤트 */
                                      // 1. 선택된 타입 저장
                                      HymnCtr.type_update(result['type']);
                                      // 2. 타입과 검색어에 맞는 찬송가 조회
                                      HymnCtr.Get_Hymn_list(HymnCtr.searchtextController.text);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.fromLTRB(5, 8, 5, 8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text("[${result['start']}-${result['end']}]",
                                                  style: result['type'] == HymnCtr.selected_type_name ?
                                                  GeneralCtr.TextStyle_normal_accent : GeneralCtr.TextStyle_normal_disable),
                                            ],
                                          ),
                                          Flexible(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Flexible(
                                                  child: Text("  ${result['type']} (${result['count']})",
                                                      style: result['type'] == HymnCtr.selected_type_name ?
                                                      GeneralCtr.TextStyle_normal_accent : GeneralCtr.TextStyle_normal_disable),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ); // "=>"이 아닌 "{}"을 쓸때는 반드시 return을 써줘야한다!!
                                }
                            ),
                          ),
                        ),

                        /* 사회적 거리두기 위젯 */
                        VerticalDivider(indent: 10, endIndent: 10),

                        /* 오른쪽 _ 찬송가 제목 (title)이 보여지는 부분 */
                        Flexible(
                          child: Scrollbar(
                            child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(), // 빌더 내부에서 별도로 스크롤 관리할지, 이게 활성화 된경우 전체 스크롤보다 해당 스크롤이 우선되므로 일단은 비활성화가 좋다
                                shrinkWrap: true, //"hassize" 같은 ㅈ같은 오류 방지
                                scrollDirection: Axis.vertical, // 수직(vertical)  수평(horizontal) 배열 선택
                                //controller: ,// 스크롤 조작이 필요하다면 할당 ㄱㄱ
                                itemCount: HymnCtr.hymn_list.length,
                                itemBuilder: (context, index) {
                                  var result = HymnCtr.hymn_list[index]; // 결과 할당, 이런식으로 변수 선언 가능, 아래 위젯에서 활용 가능
                                  return InkWell(
                                    onTap: (){
                                      /* 해당 악보로 이등하는 이벤트 */
                                      HymnCtr.hymn_click (result['number'], result['title']);
                                      },
                                    child: Column(
                                      children: [
                                        Container(
                                            padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text("${result['number']}. ",
                                                  style: TextStyle(fontSize: GeneralCtr.fontsize_normal),),
                                                //Icon(Entypo.note, size: GeneralCtr.Textsize*0.8),
                                                Flexible(
                                                  child: Text("${result['title']}",
                                                    style: TextStyle(fontSize: GeneralCtr.fontsize_normal),),
                                                )
                                              ],
                                            )
                                        ),
                                        Divider(indent: 5, endIndent: 5),
                                      ],
                                    ),
                                  ); // "=>"이 아닌 "{}"을 쓸때는 반드시 return을 써줘야한다!!
                                }
                            ),
                          ),
                        ),
                        /* 찬송가 제목 리스트 보여주기 */
                      ],
                    ),
                  )
                ],
              ),
            ); //return은 필수
          }
      );
  }
}
