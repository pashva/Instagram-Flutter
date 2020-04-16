import 'package:flutter/material.dart';

Container circularProgress() {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top:10),
child: CircularProgressIndicator(
  valueColor: AlwaysStoppedAnimation(Colors.blue),
),
  );
}

linearProgress() {
  return  Container(
    padding: EdgeInsets.only(bottom:10),
child: LinearProgressIndicator(
  valueColor: AlwaysStoppedAnimation(Colors.blue),
),
  );
}