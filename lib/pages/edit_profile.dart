import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:instagram/models/user.dart';
import 'package:instagram/pages/home.dart';
import 'package:instagram/widgets/progress.dart';

class EditProfile extends StatefulWidget {
  final String currentid;
  EditProfile({this.currentid});
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldkey=GlobalKey<ScaffoldState>();
  bool _biovalid = true;
  bool _displanamevalid = true;
  TextEditingController displaynamecontroller = TextEditingController();

  TextEditingController biocontroller = TextEditingController();
  bool isloading = false;
  User user;
 

  @override
  void initState() {
    super.initState();
    getuser();
  }
   getuser() async {
    setState(() {
      isloading = true;
    });
    DocumentSnapshot doc = await usersref.document(widget.currentid).get();
    user = User.fromDocument(doc);
    displaynamecontroller.text = user.displayname;
    biocontroller.text = user.bio;
    setState(() {
      isloading = false;
    });
  }

  Column buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              "Display Name",
              style: TextStyle(color: Colors.grey),
            )),
        TextField(
          
          controller: displaynamecontroller,
          decoration: InputDecoration(
            errorText: _displanamevalid? null:"Display name too short",
            hintText: "Update Display Name",
          ),
        )
      ],
    );
  }

  Column buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              "Bio",
              style: TextStyle(color: Colors.grey),
            )),
        TextField(
          controller: biocontroller,
          decoration: InputDecoration(
            errorText: _biovalid? null:"Bio too long",
            hintText: "Update Bio",
          ),
        )
      ],
    );
  }
  logout() async {
    await googleSignin.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }

  updateprofiledata() {
    setState(() {
      displaynamecontroller.text.trim().length < 3 ||
              displaynamecontroller.text.isEmpty
          ? _displanamevalid = false
          : _displanamevalid = true;

      biocontroller.text.length > 100 ? _biovalid = false : _biovalid = true;

      if(_displanamevalid && _biovalid){
        usersref.document(widget.currentid).updateData({
          "displayname":displaynamecontroller.text,
          "bio":biocontroller.text
        });
        SnackBar s=SnackBar(content: Text("ProfileUpdated"),);
        _scaffoldkey.currentState.showSnackBar(s);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    
    
    return Scaffold(
        key: _scaffoldkey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "Edit Profile",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.done,
                  size: 30,
                  color: Colors.green,
                ),
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>Home()));
                })
          ],
        ),
        body: isloading
            ? circularProgress()
            : ListView(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Padding(
                          child: CircleAvatar(
                            radius: 50.0,
                            backgroundImage:
                                CachedNetworkImageProvider(user.photourl),
                          ),
                          padding: EdgeInsets.only(top: 16, bottom: 8)),
                      Padding(
                          child: Column(
                            children: <Widget>[
                              buildDisplayNameField(),
                              buildBioField(),
                            ],
                          ),
                          padding: EdgeInsets.all(16)),
                      RaisedButton(
                        onPressed: updateprofiledata,
                        child: Text(
                          "Update Profile",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: FlatButton.icon(
                          onPressed: logout,
                          icon: Icon(Icons.cancel, color: Colors.red),
                          label: Text(
                            "Logout",
                            style: TextStyle(color: Colors.red, fontSize: 20.0),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ));
  }
}
