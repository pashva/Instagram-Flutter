import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:instagram/models/user.dart';
import 'package:instagram/pages/activity_feed.dart';
import 'package:instagram/pages/create_account.dart';
import 'package:instagram/pages/profile.dart';
import 'package:instagram/pages/search.dart';
import 'package:instagram/pages/timeline.dart';

import 'package:instagram/pages/upload.dart';

final GoogleSignIn googleSignin = GoogleSignIn();
final StorageReference storageref=FirebaseStorage.instance.ref();
final usersref = Firestore.instance.collection("users");
final postref=Firestore.instance.collection("posts");
final commentsRef = Firestore.instance.collection('comments');
final activityFeedRef = Firestore.instance.collection('feed');
final followersRef = Firestore.instance.collection('followers');
final followingRef = Firestore.instance.collection('following');
final timelineref = Firestore.instance.collection('timeline');
final timestamp=DateTime.now();
User currentuser;
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;

  login() {
    googleSignin.signIn();
  }

  logout() {
    googleSignin.signOut();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(pageIndex,
        duration: Duration(milliseconds: 250), curve: Curves.easeInOut);
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          Timeline(currentuser:currentuser),
          ActivityFeed(),
          Upload(currentUser:currentuser),
          Search(),
          Profile(profileid: currentuser?.id,)
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Colors.lightBlue,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.whatshot)),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active)),
          BottomNavigationBarItem(
              icon: Icon(
            Icons.photo_camera,
            size: 35,
          )),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle))
        ],
      ),
    );
  }

  buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Colors.teal, Colors.purple])),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "PashaGram",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 90,
                fontFamily: "Signatra",
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: login,
              child: Container(
                width: 200,
                height: 40,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("images/google_signin_button.png"),
                        fit: BoxFit.cover)),
              ),
            )
          ],
        ),
      ),
    );
  }

  createuserinfirestore() async {
    final GoogleSignInAccount user = googleSignin.currentUser;
    DocumentSnapshot doc = await usersref.document(user.id).get();
    if (!doc.exists) {
      final username = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));

          usersref.document(user.id).setData({
            "id":user.id,
            "username":username,
            "photourl":user.photoUrl,
            "email":user.email,
            "displayname":user.displayName,
            "bio":"",
            "timestamp":timestamp
          });
          doc = await usersref.document(user.id).get();
    }
     

    currentuser= User.fromDocument(doc);
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 0);
    googleSignin.onCurrentUserChanged.listen((account)async  {
      if (account != null) {
      await createuserinfirestore();
        setState(() {
          isAuth = true;
        });
      } else {
        setState(() {
          isAuth = false;
        });
      }
    });
    googleSignin.signInSilently(suppressErrors: false).then((account)async  {
      if (account != null) {
        await createuserinfirestore();
        setState(() {
          isAuth = true;
        });
      } else {
        setState(() {
          isAuth = false;
        });
      }
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
