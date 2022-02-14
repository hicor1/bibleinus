


import 'package:bible_in_us/bible/bible_favorite_page.dart';
import 'package:flutter/material.dart';

class BibleFavoriteScreen extends StatelessWidget {
  const BibleFavoriteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: GeneralCtr.MainColor
        ),
        title: Text("즐겨찾기", style: TextStyle(color: GeneralCtr.MainColor),),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,

      ),
      body: BibleFavoritePage(),
    );
  }
}
