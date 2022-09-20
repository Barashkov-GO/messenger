import 'dart:html';
import 'dart:js';

import 'package:flutter/material.dart';
import 'package:my_first_flutter/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chatscreen.dart';
//import 'package:my_first_flutter/services/auth.dart';
import './signin.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  bool isSearching = false;

  late Stream usersStream;

  TextEditingController searchUsernameEditingController = TextEditingController();

  onSearchBtnClick() async {
    isSearching = true;
    setState(() {});
    usersStream = await DatabaseMethods().getUserByUserName(
        searchUsernameEditingController.text);
    setState(() {});
  }

  Widget searchListUserTile({required String profileUrl, name, username, email}){
    return GestureDetector(
      onTap: (){
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(username, name)));
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.network(
              profileUrl,
              height: 30,
              width: 30,
            ),
          ),
          const SizedBox(width: 12),
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [ Text(name), Text(email)])
        ],
      ),
    );
  }

  Widget searchUsersList(){
    return StreamBuilder(
      stream: usersStream,
      builder: (context, snapshot){
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return searchListUserTile(
                      profileUrl: ds["imgUrl"],
                      name: ds["name"],
                      email: ds["email"],
                      username: ds["username"]
                  );
                },
              )
            : const Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  Widget chatRoomsList(){
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("messenger"),
          actions: [
            InkWell(
              /*onTap: () {},
                AuthMethods().signOut().then((s) {
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (context) =>
                      SignIn
                        ()));
                });
              },*/
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.exit_to_app)),
            )
          ],
      ),
      body: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Row(
                children: [
                  isSearching
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              isSearching = false;
                              searchUsernameEditingController.text = "";
                            });
                          },
                          child: Padding(
                              padding: EdgeInsets.only(right: 12),
                              child: Icon(Icons.arrow_back)),
                        )
                      : Container(),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 16),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.grey ,
                              width: 1.0,
                              style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(24)
                      ),
                      child: Row(
                        children: [
                          Expanded(
                              child: TextField(
                                controller: searchUsernameEditingController,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "username"
                                ),
                              )
                          ),
                          GestureDetector(
                              onTap: () {
                                if (searchUsernameEditingController.text != ""){
                                  onSearchBtnClick();
                                }
                              },
                              child: Icon(Icons.search))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              isSearching ? searchUsersList() : chatRoomsList()
            ],
          )
      )
    );
  }
}

