


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserMainPage extends StatelessWidget {
  const UserMainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Page"),
      ),
      body: TextButton(
        child: Text("로그아웃"),
        onPressed: () {
          FirebaseAuth.instance.signOut();
        },
      ),
    );
  }
}
