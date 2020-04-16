import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/user.dart';
import 'package:instagram/pages/edit_profile.dart';
import 'package:instagram/widgets/header.dart';
import 'package:instagram/widgets/post.dart';
import 'package:instagram/widgets/post_tile.dart';
import 'package:instagram/widgets/progress.dart';
import 'package:instagram/pages/home.dart';

class Profile extends StatefulWidget {
  final String profileid;
  Profile({this.profileid});
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isfollowing = false;
  String postorientation = "grid";
  bool isloading = false;
  int postcount = 0;
  List<Post> posts = [];
  int followerCount = 0;
  int followingCount = 0;
  getprofileposts() async {
    setState(() {
      isloading = true;
    });
    QuerySnapshot snapshot = await postref
        .document(widget.profileid)
        .collection("userposts")
        .orderBy("timestamp", descending: true)
        .getDocuments();
    setState(() {
      isloading = false;
      postcount = snapshot.documents.length;
      posts = snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

    @override
  void initState() {
    super.initState();
    getprofileposts();
    getFollowers();
    getFollowing();
    checkIfFollowing();
  }
  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .document(widget.profileid)
        .collection('userFollowers')
        .document(currentuserid)
        .get();
    setState(() {
      isfollowing = doc.exists;
    });
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .document(widget.profileid)
        .collection('userFollowers')
        .getDocuments();
    setState(() {
      followerCount = snapshot.documents.length;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .document(widget.profileid)
        .collection('userFollowing')
        .getDocuments();
    setState(() {
      followingCount = snapshot.documents.length;
    });
  }


  final String currentuserid = currentuser?.id;

  Column buildCountColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  editProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditProfile(
                  currentid: currentuserid,
                )));
  }

  Container buildButton({String text, Function function}) {
    return Container(
      padding: EdgeInsets.only(top: 2.0),
      child: FlatButton(
        onPressed: function,
        child: Container(
          width: 200.0,
          height: 27.0,
          child: Text(
            text,
            style: TextStyle(
              color: isfollowing ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isfollowing ? Colors.white : Colors.blue,
            border: Border.all(
              color: isfollowing ? Colors.grey : Colors.blue,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }

    handleUnfollowUser() {
    setState(() {
      isfollowing = false;
    });
    // remove follower
    followersRef
        .document(widget.profileid)
        .collection('userFollowers')
        .document(currentuserid)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // remove following
    followingRef
        .document(currentuserid)
        .collection('userFollowing')
        .document(widget.profileid)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // delete activity feed item for them
    activityFeedRef
        .document(widget.profileid)
        .collection('feedItems')
        .document(currentuserid)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }
  handlefollow() {
    setState(() {
      isfollowing = true;
    });
    followersRef
        .document(widget.profileid)
        .collection("userFollowers")
        .document(currentuserid)
        .setData({});

    followingRef
        .document(currentuser.id)
        .collection("userFollowing")
        .document(widget.profileid)
        .setData({});
        activityFeedRef
        .document(widget.profileid)
        .collection('feedItems')
        .document(currentuserid)
        .setData({
      "type": "follow",
      "ownerId": widget.profileid,
      "username": currentuser.username,
      "userId": currentuserid,
      "userProfileImg": currentuser.photourl,
      "timestamp": timestamp,
    });


  }

  buildProfileButton() {
    bool isprofileowner = currentuserid == widget.profileid;
    if (isprofileowner) {
      return buildButton(text: "Edit Profile", function: editProfile);
    } else if (isfollowing) {
      return buildButton(text: "Unfollow", function: handleUnfollowUser);
    } else if (!isfollowing) {
      return buildButton(text: "Follow", function: handlefollow);
    }
  }

  buildProfileHeader() {
    return FutureBuilder(
      future: usersref.document(widget.profileid).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user1 = User.fromDocument(snapshot.data);
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 40.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user1.photourl),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildCountColumn("posts", postcount),
                            buildCountColumn("followers", followerCount),
                            buildCountColumn("following", followingCount),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildProfileButton(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 12.0),
                child: Text(
                  user1.username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 4.0),
                child: Text(
                  user1.displayname,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 2.0),
                child: Text(
                  user1.bio,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  buildprofileposts() {
    if (isloading) {
      return circularProgress();
    } else if (postorientation == "grid") {
      List<GridTile> gridtiles = [];
      posts.forEach((element) {
        gridtiles.add(GridTile(child: PostTile(post: element)));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridtiles,
      );
    } else if (postorientation == "list") {
      return Column(children: posts);
    }
  }

  setpostori(String ori) {
    setState(() {
      this.postorientation = ori;
    });
  }

  buildtogglepostorientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
            icon: Icon(Icons.grid_on,
                color: postorientation == "grid" ? Colors.blue : Colors.grey),
            onPressed: () => setpostori("grid")),
        IconButton(
            icon: Icon(Icons.list,
                color: postorientation == "list" ? Colors.blue : Colors.grey),
            onPressed: () => setpostori("list"))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: header(istitle: false, text: "Profile"),
        body: ListView(
          children: <Widget>[
            buildProfileHeader(),
            Divider(),
            buildtogglepostorientation(),
            Divider(
              height: 0.02,
            ),
            buildprofileposts()
          ],
        ));
  }
}
