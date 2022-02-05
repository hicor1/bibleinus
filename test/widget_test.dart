// <서브위젯> 최근검색기록 보여주는 위젯 //
class History extends StatelessWidget {
  const History({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /*  GetX 불러오기 */
    return GetBuilder<GeneralController>(
        init: GeneralController(),
        builder: (_){
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              /* 버튼 등 최상단 표기*/
              Padding(padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                child: OutlinedButton(
                    onPressed: (){BibleCtr.FreeSearch_history_remove();},
                    child: Text("기록지우기", style: TextStyle(color: Colors.black),),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: EdgeInsets.fromLTRB(20, 3, 20, 3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      side: BorderSide(width: 1.0, color: GeneralCtr.MainColor),
                    )
                ),
              ),

              /* 히스토리 테이블 */
              Flexible(
                child: Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Scrollbar(
                      isAlwaysShown: true,   //화면에 항상 스크롤바가 나오도록 한다
                      child: Align(
                        // 가장 최신 히스토리가 위로 올라오도록 "reverse"시킴
                        // 배열이 뒤집혀 아래로 몰릴수 있으므로 "Align"위젯씌워서 "topcenter"로 재정렬
                        alignment: Alignment.topCenter,
                        child: ListView.builder(
                            reverse: true,
                            shrinkWrap: true,
                            itemCount: BibleCtr.FreeSearch_history_query.length,
                            itemBuilder: (context, index) {
                              //var result = FavoriteCtr.FavoriteList[index]; // 결과 할당, 이런식으로 변수 선언 가능, 아래 위젯에서 활용 가능
                              /* 아래부터 검색결과를 하나씩 컨테이너에 담아주기*/
                              return InkWell(
                                onTap: (){BibleCtr.History_click(index);},
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  color: Colors.transparent,
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          /* 검색결과 내용 표기 */
                                          Icon(Elusive.search, size: GeneralCtr.Textsize*0.9, color: GeneralCtr.MainColor),
                                          Flexible(
                                            child: Text(" ${BibleCtr.FreeSearch_history_query[index]}  ",
                                                style: TextStyle(fontSize: GeneralCtr.Textsize, color: Colors.black)),
                                          ),
                                          Icon(FontAwesome5.bible, size: GeneralCtr.Textsize*0.9, color: Colors.grey),
                                          Text(" ${BibleCtr.FreeSearch_history_bible[index]}",
                                              style: TextStyle(fontSize: GeneralCtr.Textsize*0.85, color: Colors.grey)),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Divider(height: 3,)
                                    ],
                                  ),
                                ),
                              );
                            }
                        ),
                      ),
                    )
                ),
              ),
            ],
          );
        }
    );
  }
}