import 'package:bible_in_us/general/general_controller.dart';
import 'package:bible_in_us/hymn/hymn_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../bible/bible_controller.dart';

// Gex컨트롤러 객체 초기화
final GeneralCtr = Get.put(GeneralController());
final HymnCtr = Get.put(HymnController());


class HymnScorePage extends StatelessWidget {
  const HymnScorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return
      GetBuilder<HymnController>(
          init: HymnController(),
          builder: (_){
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 5),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("[${HymnCtr.selected_type_name}] ${HymnCtr.selected_hymn_number}. ${HymnCtr.selected_hymn_name}",
                            style: TextStyle(
                                fontSize: GeneralCtr.Textsize+5,

                            ), textAlign: TextAlign.center),
                      ],
                    ),

                    SizedBox(height: 30),

                    Flexible(child: Image.asset(HymnCtr.selected_hymn_path)),
                  ],
                ),
              ),
            );; //return은 필수
          }
      );
  }
}
