import 'package:flutter/material.dart';

AppBar header({istitle, String text}) {
  return AppBar(
    automaticallyImplyLeading: false,
    centerTitle: true,
    backgroundColor: Colors.lightBlue,
    title: Text(

      istitle ? "PashaGram" : text,
      style: TextStyle(
          color: Colors.white,
          fontFamily: istitle ? "Signatra" : "",
          fontSize: istitle ? 40 : 22),
          overflow: TextOverflow.ellipsis,
    ),
  );
}
