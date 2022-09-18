import 'package:flutter/material.dart';
import 'package:my_first_flutter/services/auth.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("messenger"),
        ),
      body: Center(
        child: GestureDetector(
          onTap: (){
            AuthMethods().signInWithGoogle(context);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: const Color(0xffDB4437),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Text(
                "Sign In with Google",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
