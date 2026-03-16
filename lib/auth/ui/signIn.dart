import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_dark_knight_final/auth/controller/auth_controller.dart';
import 'package:the_dark_knight_final/auth/ui/signUp.dart';
import 'package:the_dark_knight_final/auth/ui/widgets%20screen%20(all%20widgets).dart';
import 'package:the_dark_knight_final/shared/components.dart';

// ignore: use_key_in_widget_constructors
class SignIn extends StatefulWidget {
  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController1 = TextEditingController();

  bool remember = false;
  GlobalKey<FormState> form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    ShowPasswordController ctr = Get.put(ShowPasswordController());
    return Scaffold(
      body: Container(
        height:850 ,
        color: Color.fromARGB(255, 8, 1, 1),
        padding: EdgeInsets.fromLTRB(50, 0, 30, 0),
        child: Form(
          key: form,
          child: SingleChildScrollView(
            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 180,
                ),
                 
                Text(
                  "Log in",
                  style: GoogleFonts.timmana(   
                    fontWeight: FontWeight.bold,
                    fontSize: 50,
                    color: mainColor,
                  ),
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
                GetBuilder<ShowPasswordController>(
                  builder: (controller) {
                    return Container(
                      child: TextFormFieldScreen(
                        obsureText: controller.isshowPassword,
                        controller: passwordController1,
                        keyboardType: TextInputType.name,
                        label: "Password",
                        prefix: Icons.lock,
                        validator: (value) {
                          return ValidatorScreen(value!, 6, 90, "password");
                        },
                        suffixIcon: controller.isshowPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        onPressed: () {
                          controller.showPassword();
                        },
                      ),
                    );
                  },
                ),

                Row(
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Remember Me",
                      style: TextStyle(color: mainColor, fontSize: 20),
                    ),
                      Obx(()=>
                        Checkbox(
                          hoverColor: Colors.blue,
                          value: ctr.remember.value,
                          onChanged: (value) {
                            ctr.toggleRemember();
                            ctr.save();
                          },
                        ),
                      ),
                    SizedBox(width: 35),

                    TextButton(
                      onPressed: () async {
                        String email = emailController.text.trim();

                        // 1. التحقق من الحقل الفارغ
                        if (email.isEmpty) {
                          AwesomeDialog(
                            context: Get.context!,
                            dialogType: DialogType.warning,
                            title: 'تنبيه',
                            desc: 'يرجى إدخال البريد الإلكتروني أولاً.',
                            btnOkColor: Colors.orange,
                            btnOkOnPress: () {},
                          ).show();
                          return; // توقف هنا ولا تكمل
                        }

                        try {
                          // 2. محاولة الإرسال (داخل try-catch)
                          await FirebaseAuth.instance.sendPasswordResetEmail(
                            email: email,
                          );

                          // 3. نجاح العملية
                          AwesomeDialog(
                            context: Get.context!,
                            dialogType: DialogType.success,
                            title: 'تم الإرسال',
                            desc:
                                'تحقق من بريدك الإلكتروني لإعادة تعيين كلمة المرور.',
                            btnOkColor: Colors.green,
                            btnOkOnPress: () {},
                          ).show();
                        } on FirebaseAuthException catch (e) {
                          // 4. معالجة أخطاء فايربيز (مثل إيميل غير موجود)
                          String message = "حدث خطأ ما";
                          if (e.code == 'user-not-found') {
                            message = "هذا البريد الإلكتروني غير مسجل لدينا.";
                          } else if (e.code == 'invalid-email') {
                            message = "صيغة البريد الإلكتروني غير صحيحة.";
                          }

                          AwesomeDialog(
                            context: Get.context!,
                            dialogType: DialogType.error,
                            title: 'فشل الإرسال',
                            desc: message,
                            btnOkColor: Colors.red,
                            btnOkOnPress: () {},
                          ).show();
                        }
                      },
                      child: const Text("Forget password"),
                    ),
                  ],
                ),

                MaterialButtonScreen(
                  onPressed: () async {
                    if (form.currentState!.validate()) {
                      await ctr.signin(emailController, passwordController1);
                    }
                  },
                  titleOfButton: "Login            ",
                  Icons: const Icon(
                    FontAwesome.google,
                    color: Colors.amber,
                    size: 24.0,
                  ),
                  colorOfButton: mainColor,
                  fontColor: Colors.white,
                  fontSize: 15,
                  //fontcolor: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Get.to(() => Signup());
                  },
                  child: Text(
                    "          Don't Have an Account? Sign Up",
                    style: TextStyle(color: mainColor, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
