import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final String photourl;
  final String username;
  final String displayname;
  final String bio;

  User({
    this.id,
    this.username,
    this.bio,
    this.photourl,
    this.displayname,
    this.email
  });

  factory User.fromDocument(DocumentSnapshot doc){
    return User(
      id: doc["id"],email: doc["email"],
      bio: doc["bio"],username: doc["username"],
      photourl: doc["photourl"],displayname: doc["displayname"]

    );

  }


}