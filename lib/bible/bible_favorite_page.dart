import 'package:bible_in_us/bible/bible_controller.dart';
import 'package:bible_in_us/general/general_controller.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:get/get.dart';


// Gex컨트롤러 객체 초기화
final GeneralCtr = Get.put(GeneralController());
final BibleCtr = Get.put(BibleController());

class BibleFavoritePage extends StatelessWidget {
  const BibleFavoritePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("!!"),
          Container(
          height: 50,
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.all(20),
          child: Center(
            child: ListView.builder(
                shrinkWrap: true, // 등간격 정렬하기 위해 위에 "Center"위젯과 함께 사용
                scrollDirection: Axis.horizontal,
                itemCount: BibleCtr.ColorCode.length,
                itemBuilder: (context, index) {
                  // 색깔 선택이 가능하도록 "InkWell" 위젯으로 감싸기
                  return InkWell(
                    splashColor: Colors.white,
                    onTap: (){BibleCtr.ColorCode_choice(index);},
                    child: Container(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            // 선택한 색깔 테두리 강조
                              color: BibleCtr.ColorCode_choiced_index == index ? Colors.grey : Colors.transparent,
                              width: 2)
                      ),
                      // 젤 처음 아이콘은 "X"표시로 변경
                      child: Icon(
                          index != 0 ? FontAwesome5.highlighter : Entypo.cancel,
                          color: BibleCtr.ColorCode[index], size: 40),
                    ),
                  );
                }
            ),
          )
      )
        ],
      ),
    );
  }
}
