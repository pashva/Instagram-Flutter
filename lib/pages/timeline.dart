import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/user.dart';
import 'package:instagram/widgets/header.dart';
import 'package:instagram/widgets/post.dart';
import 'package:instagram/widgets/progress.dart';
import 'package:instagram/pages/home.dart';

class Timeline extends StatefulWidget {
  final User currentuser;
  Timeline({this.currentuser});
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<Post> posts;
  gettimeline() async {
   QuerySnapshot snapshot=await  timelineref
        .document(widget.currentuser.id)
        .collection("timelinePosts")
        .orderBy("timestamp", descending: true)
        .getDocuments();
        List<Post> posts=snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    setState(() {
      this.posts=posts;
    });

  }

  @override
  void initState() {
    gettimeline();
    
    super.initState();
    
  }
  buildtimeline(){
    if(posts==null){
      return circularProgress();
    }else if(posts.isEmpty){
      return Text("No posts");
    }else{
      return ListView(
      children: posts,
    );

    }
    
  }
  logout() {
    googleSignin.signOut();
  }

  @override
  Widget build(context) {
    return Scaffold(
        appBar: header(istitle:true,text: "Timeline"),
        body: RefreshIndicator(
          child: buildtimeline(),
           onRefresh: ()=>gettimeline()));
  }
}
