import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram/models/user.dart';
import 'package:instagram/pages/activity_feed.dart';
import 'package:instagram/pages/home.dart';
import 'package:instagram/widgets/progress.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchcontroller=TextEditingController();
  Future<QuerySnapshot> searchresultfuture;
  handlesearch(String query){
    Future<QuerySnapshot> users=usersref.where("displayname",isGreaterThanOrEqualTo: query).getDocuments();
    setState(() {
      searchresultfuture=users;
    });
  }
  clearsearch(){
    searchcontroller.clear();
  }
  AppBar buildsearchfield() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchcontroller,
        decoration: InputDecoration(
            hintText: "Search for a user...",
            filled: true,
            prefixIcon: Icon(
              Icons.account_box,
              size: 28,
            ),
            suffixIcon: IconButton(icon: Icon(Icons.clear), onPressed: clearsearch)),
            onFieldSubmitted: handlesearch,
      ),
    );
  }

  buildnocontent() {
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SvgPicture.asset(
              "images/search.svg",
              height: 300,
            ),
            Text(
              "Find Users",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                  fontSize: 60),
            )
          ],
        ),
      ),
    );
  }
  buildsearchresults(){
    return FutureBuilder(
      future: searchresultfuture,
      builder: (context,snapshot){
        if(!snapshot.hasData){
          return circularProgress();
        }
        List<UserResult> searchresults=[];
        snapshot.data.documents.forEach((doc){
            User user=User.fromDocument(doc);
            UserResult searchresult=UserResult(user);
            searchresults.add(searchresult);


        });
        return ListView(
            children: searchresults,
        );
        
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.lightBlue.withOpacity(0.4),
        appBar: buildsearchfield(),
        body:searchresultfuture==null? buildnocontent():buildsearchresults());
  }
}

class UserResult extends StatelessWidget {
  final User user;
  UserResult(this.user);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue.withOpacity(0.5),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: ()=>showProfile(context,profileId: user.id),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(user.photourl),
              ),
              title: Text(user.displayname,style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold
              ),),
              subtitle:Text(user.username,style: TextStyle(color: Colors.white),) ,
            ),
          ),
          Divider(
            height: 2.0,
            color: Colors.white54,
          )
        ],
      ),
    );
  }
}
