import 'package:flutter/material.dart';
import 'package:instagram/pages/post_screen.dart';
import 'package:instagram/widgets/custom_image.dart';
import 'package:instagram/widgets/post.dart';
class PostTile extends StatelessWidget {
  final Post post;
  PostTile({this.post});
  showPost(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          postId: post.postid,
          userId: post.ownerid,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:()=>showPost(context),
      child: cachedNetworkImage(post.mediaurl) ,
    );
  }
}