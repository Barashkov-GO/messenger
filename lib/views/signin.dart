import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
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

      body: Center(
        child: Container(

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          const SizedBox(height: 60),
          SvgPicture.asset(
            "assets/Illustration.svg",
          ),
          const SizedBox(height: 50),
           Text(
              "Добро пожаловать \n в Мессенджер!",
             textAlign: TextAlign.center,
              style: GoogleFonts.sourceSansPro(
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 30,
                      color: Color(0xFF375FFF)
                  ),
              ),
          ),
          const SizedBox(height: 30),
          Text(
            "Самый лучший мессенджер для \nежедневного общения \nс близкими и коллегами",
            textAlign: TextAlign.center,
            style: GoogleFonts.sourceSansPro(
              textStyle: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                  color: Color(0xFF000000)
              ),
            ),
          ),
          const SizedBox(height: 50),
          GestureDetector(
          onTap: (){
            AuthMethods().signInWithGoogle(context);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              color: const Color(0xFF375FFF),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 17),
            child: Text(
              "Войти через Гугл",
              textAlign: TextAlign.center,
              style: GoogleFonts.sourceSansPro(
                textStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                    color: Colors.white
                ),
              ),
            ),
          ),
        ),
        ]
    )
    )
      ),
    );
  }
}
