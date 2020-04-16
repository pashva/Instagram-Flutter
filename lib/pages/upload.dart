import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/models/user.dart';
import 'package:instagram/pages/home.dart';

import 'package:instagram/widgets/progress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart'as im;
import 'package:uuid/uuid.dart';

class Upload extends StatefulWidget {
  final User currentUser;
  Upload({this.currentUser});
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  TextEditingController locationcontroller=TextEditingController();
  TextEditingController captioncontroller=TextEditingController();
  bool isuploading=false;
  File file;
  String PostId=Uuid().v4();
  handletakephoto() async {
    Navigator.of(context).pop();
    File file = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 675, maxWidth: 960);
    setState(() {
      this.file = file;
    });
  }

  handlegallerychoose() async {
    Navigator.of(context).pop();
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      this.file = file;
    });
  }

  selectImage(ctx) {
    return showDialog(
        context: ctx,
        builder: (context) {
          return SimpleDialog(
            title: Text("Create Post"),
            children: <Widget>[
              SimpleDialogOption(
                child: Text("Photo from camera"),
                onPressed: handletakephoto,
              ),
              SimpleDialogOption(
                child: Text("Photo from Galley"),
                onPressed: handlegallerychoose,
              ),
              SimpleDialogOption(
                  child: Text("Cancel"),
                  onPressed: () => Navigator.of(context).pop())
            ],
          );
        });
  }

  Container buildsplashscreen() {
    return Container(
      color: Colors.lightBlue.withOpacity(0.4),
      child: Column(
        children: <Widget>[
          SvgPicture.asset("images/upload.svg"),
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: RaisedButton(
                color: Colors.blue,
                child: Text(
                  "Upload Image",
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                onPressed: () => selectImage(context)),
          )
        ],
      ),
    );
  }

  clearimage() {
    setState(() {
      file = null;
      locationcontroller.clear();
      captioncontroller.clear();
    });
  }
  compressimage()async {
    final tempdir=await getTemporaryDirectory();
    final path=tempdir.path;
    im.Image imagefile=im.decodeImage(file.readAsBytesSync());
   final compressesimagefile=File("$path/img_$PostId.jpg",)..writeAsBytesSync(im.encodeJpg(imagefile,quality: 85));
    setState(() {
      file=compressesimagefile;
    });
  }
  Future<String> uploadimage(imagefile)async {
    StorageUploadTask uploadtask=storageref.child("post_$PostId.jpg").putFile(imagefile);
    StorageTaskSnapshot tasksnap=await uploadtask.onComplete;
    String downloadurl=await tasksnap.ref.getDownloadURL();
    return downloadurl;

  }
  createpostinfirestore({String mediaurl,String location,String description}){
    postref.document(widget.currentUser.id).collection("userposts").document(PostId).setData({
      "PostId":PostId,
      "ownerid":widget.currentUser.id,
      "username":widget.currentUser.username,
      "mediaurl":mediaurl,
      "description":description,
      "location":location,
      "timestamp":timestamp,
      "likes":{}


    });


  }
  handlesubmit()async {
    setState(() {
      isuploading=true;
    });
    await compressimage();
    String mediaurl=await uploadimage(file);
    createpostinfirestore(mediaurl: mediaurl,location: locationcontroller.text,description: captioncontroller.text);
    captioncontroller.clear();
    locationcontroller.clear();
    setState(() {
      file=null;
      isuploading=false;
      PostId=Uuid().v4();
    });
  }

  Scaffold buildupload() {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white70,
        leading: IconButton(icon: Icon(Icons.clear), onPressed: clearimage),
        title: Text(
          "Caption Post",
          style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          FlatButton(
              onPressed: isuploading? null:()=>handlesubmit(),
              child: Text(
                "Post",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlue,
                    fontSize: 20),
              ))
        ],
      ),
      body: ListView(
        children: <Widget>[
          isuploading? linearProgress():Text(""),
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 220,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: FileImage(file), fit: BoxFit.cover)),
                ),
              ),
            ),
          ),
          Padding(
            
            padding: EdgeInsets.only(top: 10)
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(widget.currentUser.photourl),
              
            ),
            title: Container(
              width: 250,
              child: TextField(
                controller: captioncontroller,
                decoration: InputDecoration(
                hintText: "Add a Caption",
                border: InputBorder.none

              ),),
            ),
          ),
          Divider(
            height: 2,

          ),
          ListTile(
            leading: Icon(Icons.pin_drop,color: Colors.black,size: 35,),
            title: Container(
              width: 250,
              child: TextField(
                controller: locationcontroller,
                decoration: InputDecoration(
                  hintText: "Location",
                  border: InputBorder.none
                ),
              ),
            ),
          ),
          Container(
            width: 200,
            height: 100,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              icon: Icon(Icons.my_location,color: Colors.white,),
              onPressed: getuserlocation,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              label: Text("Use current Location",style: TextStyle(color: Colors.white,),),
            ),
          )
        ],
      ),
    );
  }
  getuserlocation()async{
    Geolocator().checkGeolocationPermissionStatus();
    final Position position=await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks=await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place=placemarks[0];
    String finaladdress="${place.locality}-${place.country}";
    locationcontroller.text=finaladdress;
  }

  @override
  Widget build(BuildContext context) {
    return file == null ? buildsplashscreen() : buildupload();
  }

  
}
