import 'package:flutter/material.dart';
//import 'package:my_first_flutter/services/auth.dart';
import './signin.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  bool isSearching = false;

  TextEditingController searchUsernameEditingController = TextEditingController();

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
                                setState(() {
                                  isSearching = true;
                                });
                              },
                              child: Icon(Icons.search))
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          )
      )
    );
  }
}

