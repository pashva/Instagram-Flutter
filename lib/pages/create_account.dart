import 'package:flutter/material.dart';
import 'package:instagram/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final formkey= GlobalKey<FormState>();
  String username="";
  submit(){
    
    
    formkey.currentState.save();
    
  }

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(istitle: false, text: "Create Account"),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 25.0),
                  child: Center(
                    child: Text(
                      "Create a username",
                      style: TextStyle(fontSize: 25.0),
                    ),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.all(16),
                    child: Form(
                      child: TextFormField(
                        key: formkey,
                        onChanged: (val)=>username=val,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Must be atleast 4 characters",
                            labelText: "Username",
                            labelStyle: TextStyle(fontSize: 15)),
                      ),
                    )),
                GestureDetector(
                  onTap: (){
                      
                      Navigator.pop(context,username);
                      
                  },
                  child: Container(
                    height: 60,
                    width: 260,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8)
                    ),
                      child: Center(
                        child: Text(
                    "Submit",
                    style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                  ),
                      )),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
