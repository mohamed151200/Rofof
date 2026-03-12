
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:the_dark_knight_final/auth/ui/signIn.dart';
import 'package:the_dark_knight_final/auth/ui/widgets%20screen%20(all%20widgets).dart';

class Forget extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  GlobalKey<FormState> form = new GlobalKey<FormState>();

  Forget({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        body: ListView(children: [
      Image.asset(
        "assets/images/forgotpassword.png",
      ),
      Container(
          height: 700,
          color: Color(0xffffffff),
          padding: EdgeInsets.fromLTRB(50, 0, 30, 0),
          child: Form(
            key: form,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
               Text(
                "Forget Password",
                style: GoogleFonts.timmana(fontWeight: FontWeight.bold,
                fontSize: 30, color: Color.fromARGB(255, 1, 56, 132)),
              ),
              TextFormFieldScreen(
                controller: emailController,
                keyboardType: TextInputType.name,
                label: "Email",
                prefix: Icons.email,
                validator: (value) {
                  return ValidatorScreen(value!, 2, 90, "emailController");
                },
              ),
              MaterialButtonScreen(
                onPressed: () async {
                  if (form.currentState!.validate()) {
                    var cred = await _forget();
                    if (cred != null) {
                      Get.snackbar(
                          "Lets Learn", "Check your Gmail To Reset Password");
                    }
                  }
                },
                titleOfButton: "Reset password           ",
                Icons: const Icon(FontAwesome.google,
                    color: Colors.amber, size: 24.0),
                colorOfButton: Color.fromARGB(255, 83, 137, 212),
                fontColor: Colors.white,
                fontSize: 15,
              //  fontcolor: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(
                height: 20,
              ),
            ]),
          ))
    ]));
  }

  _forget() async {
    try {
      final credential = await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text)
          .then((value) => {Get.off(() => SignIn())});
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        //print('No user found for that email.');
        Get.snackbar(
            "No user found for that email.", "No user found for that email.");
      } else if (e.code == 'wrong-password') {
        //print('Wrong password provided for that user.');
        Get.snackbar("Wrong pass word", "Wrong pass word");
      }
    }
  }
}
