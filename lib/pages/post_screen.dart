import 'package:flutter/material.dart';
import 'package:instagram/pages/home.dart';
import 'package:instagram/widgets/header.dart';
import 'package:instagram/widgets/post.dart';
import 'package:instagram/widgets/progress.dart';

class PostScreen extends StatelessWidget {
  final String userId;
  final String postId;

  PostScreen({this.userId, this.postId});

  @override
  Widget build(BuildContext context) {
    print(userId);
    print(postId);
    return FutureBuilder(
      future: postref
          .document(userId)
          .collection('userposts')
          .document(postId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        Post post = Post.fromDocument(snapshot.data);
        return Center(
          child: Scaffold(
            appBar: header(istitle:false,text: post.description),
            body: ListView(
              children: <Widget>[
                Container(
                  child: post,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}