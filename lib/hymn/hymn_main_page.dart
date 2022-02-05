import 'package:bible_in_us/general/general_controller.dart';
import 'package:bible_in_us/hymn/hymn_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';



// Gex컨트롤러 객체 초기화
final GeneralCtr = Get.put(GeneralController());
final HymnCtr = Get.put(HymnController());

class HymnMainWidget extends StatelessWidget {
  const HymnMainWidget({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    /* 페이지 로딩시에 한번 조회 */
    HymnCtr.Get_type_count_init("");

    /* 아래부터 페이지 뿌려주기 */
    return
    /* 빌더 불러오기 */
      GetBuilder<HymnController>(
          init: HymnController(),
          builder: (_){
            return Padding(
              padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
              child: Column(
                children: [
                  /* 검색부분 */
                  TextField(
                    onChanged: (keyword){
                      /* 검색어를 입력 했을 때 액션 정의 */
                    },
                    controller: HymnCtr.searchtextController, // 텍스트값을 가져오기 위해 컨트롤러 할당
                    autofocus: false, // 자동으로 클릭할것인가
                    style: TextStyle(fontSize: GeneralCtr.Textsize),
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            /* 클리어 버튼(X) 눌렀을 때 텍스트 비우기 */
                            HymnCtr.searchtextController.clear();
                          },
                        ),
                        hintText: '검색어를 입력해주세요',
                        hintStyle: GeneralCtr.TextStyle_normal_disable,
                        border: InputBorder.none),
                  ),

                  /* 아래는 검색결과를 리스트로 보여주는 부분 */
                  Flexible(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Scrollbar(
                            child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(), // 빌더 내부에서 별도로 스크롤 관리할지, 이게 활성화 된경우 전체 스크롤보다 해당 스크롤이 우선되므로 일단은 비활성화가 좋다
                                shrinkWrap: true, //"hassize" 같은 ㅈ같은 오류 방지
                                scrollDirection: Axis.vertical, // 수직(vertical)  수평(horizontal) 배열 선택
                                //controller: ,// 스크롤 조작이 필요하다면 할당 ㄱㄱ
                                itemCount: HymnCtr.hymn_type_count_init.length,
                                itemBuilder: (context, index) {
                                  var result = HymnCtr.hymn_type_count_init[index]; // 결과 할당, 이런식으로 변수 선언 가능, 아래 위젯에서 활용 가능
                                  return InkWell(
                                    onTap: (){
                                      /* 해당 타입을 눌렀을 때 이벤트 */
                                      // 1. 선택된 타입 저장
                                      HymnCtr.type_update(result['type']);
                                      // 2. 타입과 검색어에 맞는 찬송가 조회
                                      HymnCtr.Get_Hymn_list(HymnCtr.searchtextController.text);
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text("${result['start']} : "),
                                            Text("${result['end']}"),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text("${result['type']}"),
                                            Text("(${result['count']})"),
                                          ],
                                        )
                                      ],
                                    ),
                                  ); // "=>"이 아닌 "{}"을 쓸때는 반드시 return을 써줘야한다!!
                                }
                            ),
                          ),
                        ),
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
                                  return Text("${result['title']}"); // "=>"이 아닌 "{}"을 쓸때는 반드시 return을 써줘야한다!!
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
