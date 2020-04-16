import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/user.dart';
import 'package:instagram/pages/activity_feed.dart';
import 'package:instagram/pages/comments.dart';
import 'package:instagram/pages/home.dart';
import 'package:instagram/pages/timeline.dart';
import 'package:instagram/widgets/custom_image.dart';
import 'package:instagram/widgets/progress.dart';

class Post extends StatefulWidget {
  final String postid;
  final String ownerid;
  final String username;
  final String location;
  final String description;
  final String mediaurl;
  final dynamic likes;

  Post({
    this.postid,
    this.ownerid,
    this.username,
    this.location,
    this.description,
    this.mediaurl,
    this.likes,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postid: doc['PostId'],
      ownerid: doc['ownerid'],
      username: doc['username'],
      location: doc['location'],
      description: doc['description'],
      mediaurl: doc['mediaurl'],
      likes: doc['likes'],
    );
  }

  int getLikeCount(likes) {
    // if no likes, return 0
    if (likes == null) {
      return 0;
    }
    int count = 0;
    // if the key is explicitly set to true, add a like
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
        postid: this.postid,
        ownerid: this.ownerid,
        username: this.username,
        location: this.location,
        description: this.description,
        mediaurl: this.mediaurl,
        likes: this.likes,
        likeCount: getLikeCount(this.likes),
      );
}

class _PostState extends State<Post> {
  final String currentUserId = currentuser?.id;

  final String postid;
  final String ownerid;
  final String username;
  final String location;
  final String description;
  final String mediaurl;
  int likeCount;
  Map likes;
  bool isLiked;
  bool showheart = false;

  _PostState({
    this.postid,
    this.ownerid,
    this.username,
    this.location,
    this.description,
    this.mediaurl,
    this.likes,
    this.likeCount,
  });

  buildPostHeader() {
    return FutureBuilder(
      future: usersref.document(ownerid).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
         bool isPostOwner = currentUserId == ownerid;

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.photourl),
            backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
            onTap: () => showProfile(context,profileId: user.id),
            child: Text(
              user.username,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          subtitle: Text(location),
          trailing:  isPostOwner
              ? IconButton(
                  onPressed: () => handleDeletePost(context),
                  icon: Icon(Icons.more_vert),
                )
              : Text(''),
        );
      },
    );
  }
    handleDeletePost(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Remove this post?"),
            children: <Widget>[
              SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                    deletePost();
                  },
                  child: Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  )),
              SimpleDialogOption(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel')),
            ],
          );
        });
  }

  // Note: To delete post, ownerId and currentUserId must be equal, so they can be used interchangeably
  deletePost() async {
    // delete post itself
    postref
        .document(ownerid)
        .collection('userposts')
        .document(postid)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // delete uploaded image for thep ost
    storageref.child("post_$postid.jpg").delete();
    // then delete all activity feed notifications
    QuerySnapshot activityFeedSnapshot = await activityFeedRef
        .document(ownerid)
        .collection("feedItems")
        .where('postid', isEqualTo: postid)
        .getDocuments();
    activityFeedSnapshot.documents.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // then delete all comments
    QuerySnapshot commentsSnapshot = await commentsRef
        .document(postid)
        .collection('comments')
        .getDocuments();
    commentsSnapshot.documents.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

     Navigator.push(context, MaterialPageRoute(builder: (context)=>Timeline()));
  }

  handleLikePost() {
    bool _isLiked = likes[currentUserId] == true;

    if (_isLiked) {
      postref
          .document(ownerid)
          .collection('userposts')
          .document(postid)
          .updateData({'likes.$currentUserId': false});
          removeLikeFromActivityFeed();
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[currentUserId] = false;
      });
    } else if (!_isLiked) {
      postref
          .document(ownerid)
          .collection('userposts')
          .document(postid)
          .updateData({'likes.$currentUserId': true});
          addLikeToActivityFeed();
      setState(() {
        likeCount += 1;
        isLiked = true;
        likes[currentUserId] = true;
        showheart = true;
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showheart = false;
        });
      });
    }
  }
  addLikeToActivityFeed() {
    // add a notification to the postOwner's activity feed only if comment made by OTHER user (to avoid getting notification for our own like)
    bool isNotPostOwner = currentUserId != ownerid;
    if (isNotPostOwner) {
      activityFeedRef
          .document(ownerid)
          .collection("feedItems")
          .document(postid)
          .setData({
        "type": "like",
        "username": currentuser.username,
        "userId": currentuser.id,
        "userProfileImg": currentuser.photourl,
        "postId": postid,
        "mediaUrl": mediaurl,
        "timestamp": timestamp,
      });
    }
  }

  removeLikeFromActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerid;
    if (isNotPostOwner) {
      activityFeedRef
          .document(ownerid)
          .collection("feedItems")
          .document(postid)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: handleLikePost,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          cachedNetworkImage(mediaurl),
          showheart?Animator(
            duration: Duration(milliseconds: 300),
            tween: Tween(begin: 0.8, end: 1.4),
            curve: Curves.elasticOut,
            cycles: 0,
            builder: (anim) => Transform.scale(
              scale: anim.value,
              child: Icon(
                  Icons.favorite,
                  size: 60,
                  color: Colors.pink,
                )
            ),
          ):Text("")
         
        ],
      ),
    );
  }
  showComments(BuildContext context,
    {String postId, String ownerId, String mediaUrl}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Comments(
      postId: postId,
      postOwnerId: ownerId,
      postMediaUrl: mediaUrl,
    );
  }));
}

  buildPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 40.0, left: 20.0)),
            GestureDetector(
              onTap: handleLikePost,
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 28.0,
                color: Colors.pink,
              ),
            ),
            Padding(padding: EdgeInsets.only(right: 20.0)),
            GestureDetector(
              onTap: ()=>showComments(
                context,
                postId: postid,
                ownerId: ownerid,
                mediaUrl: mediaurl,
              ),

              child: Icon(
                Icons.chat,
                size: 28.0,
                color: Colors.blue[900],
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$likeCount likes",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$username ",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(child: Text(description))
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentUserId] == true);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter()
      ],
    );
  }
}
