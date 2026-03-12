import 'package:flutter/material.dart';

import 'package:get/get.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:the_dark_knight_final/auth/ui/verify.dart';
import 'package:the_dark_knight_final/layout/home.dart';
import 'package:the_dark_knight_final/shared/components.dart';
import 'package:get_storage/get_storage.dart';


class ShowPasswordController extends GetxController {
  bool isshowPassword = true;
   // استخدمت RxBool عشان تقدر تعمل تحديث للواجهة بسهولة
  //final SharedPreferences _sharedPreferences = Get.find();
  final _box = GetStorage();
  late RxBool remember;
  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? "";
  @override
  void onInit() {
    super.onInit();
    // لو مفيش قيمة محفوظة، اعتبرها false
    remember = (_box.read<bool>("remember") ?? false).obs; 
  }
  void toggleRemember() {
    remember.value = !remember.value;
    
     // تحديث الواجهة بعد تغيير القيمة
  }
  void showPassword() {
    isshowPassword = !isshowPassword;
    update();
  }

  Future<void>  save() async {
    // في GetStorage بنستخدم write بدل setBool
    await _box.write("remember", remember.value); 
    
   // print(_box.read("remember")); // القراءة بسيطة بـ read مباشرة
    //print(FirebaseAuth.instance.currentUser);
  }

  Future<bool> checkFirstTimeSync() async {
    final bool isRemembered = _box.read<bool>("remember") ?? false;
    final user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      if (isRemembered) {
        // اليوزر مسجل دخول وعايزنا نفتكره = دخله فوراً
        return true; 
      } else {
        // اليوزر مسجل دخول بس "معلمش" على تذكرني = اطرده بره ونظف الجلسة
        await FirebaseAuth.instance.signOut();
        return false;
      }
    }
    
    // مفيش يوزر أصلاً
    return false; 
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    try{ final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);}
    catch(e){
      print("Google Sign-In Error: $e");
      return Future.error("__________________Google Sign-In Failed: $e");
    }
   
  }

  signup(TextEditingController t1, TextEditingController t2) async {
    try {
      // 1. إنشاء الحساب
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: t1.text.trim(), 
        password: t2.text,
      );

      // 2. إرسال إيميل التوثيق
      try {
        if (userCredential.user != null) {
          print("💡 جاري إرسال إيميل التوثيق إلى: ${userCredential.user!.email}");
          await userCredential.user!.sendEmailVerification();
          print("✅ سيرفر فايربيز استلم أمر إرسال الإيميل بنجاح.");
        }
      } catch (emailError) {
        print("❌ خطأ خاص بإرسال الإيميل فقط: $emailError");
      }

      // ✅ النجاح
      AwesomeDialog(
        context: Get.context!,
        dialogType: DialogType.success,
        title: 'تم التسجيل',
        desc: 'تم إنشاء الحساب بنجاح. برجاء مراجعة بريدك الإلكتروني لتوثيق الحساب.',
        btnOkColor: mainColor,
        btnOkText: 'حسناً',
        btnOkOnPress: () {
          // النقل للصفحة التانية بيحصل هنا (بعد ما اليوزر يدوس أوك)
          Get.off(() => VerifyEmailPage()); 
        },
      ).show();

    } on FirebaseAuthException catch (e) {
      // ❌ معالجة الأخطاء
      if (e.code == 'weak-password') {
        AwesomeDialog(
          context: Get.context!,
          dialogType: DialogType.error, // اتعدلت لـ error
          title: 'خطأ',
          desc: 'كلمة المرور ضعيفة جداً',
          btnOkColor: mainColor,
          btnOkOnPress: () {},
        ).show();
      } else if (e.code == 'email-already-in-use') {
        AwesomeDialog(
          context: Get.context!,
          dialogType: DialogType.error, // اتعدلت لـ error
          title: 'خطأ',
          desc: 'البريد الإلكتروني مستخدم بالفعل',
          btnOkColor: mainColor,
          btnOkOnPress: () {},
        ).show();
      } else {
        AwesomeDialog(
          context: Get.context!,
          dialogType: DialogType.error, // اتعدلت لـ error
          title: 'خطأ',
          desc: 'حدث خطأ ما. يرجى المحاولة مرة أخرى.\n${e.message}',
          btnOkColor: mainColor,
          btnOkOnPress: () {},
        ).show();
      }
    } catch (e) {
      print("General Error: $e");
    }
}
  signin(TextEditingController t1, TextEditingController t2) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: t1.text.trim(),
        password: t2.text.trim(),
      );
      Get.off(() => Home_page());
    } on FirebaseAuthException catch (e) {
     /*  print(
        "Firebase Error Code: ${e.code}",
      );  */// السطر ده مهم جداً عشان تشوف الكود اللي راجع في الـ Debug Console

      String errorMessage = "حدث خطأ ما، يرجى المحاولة لاحقاً";

      // الأكواد الجديدة والمحدثة
      if (e.code == 'user-not-found' || e.code == 'invalid-email') {
        errorMessage = 'البريد الإلكتروني غير موجود أو مكتوب بشكل خاطئ';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'كلمة المرور غير صحيحة';
      } 
      else if(e.code == 'invalid-credential')
      {
        errorMessage = 'بيانات اعتماد غير صالحة. يرجى التحقق من البريد الإلكتروني وكلمة المرور.';
      }
      else if (e.code == 'user-disabled') {
        errorMessage = 'تم تعطيل هذا الحساب';
      }

      AwesomeDialog(
        context: Get.context!,
        dialogType:
            DialogType.error, // غيرتها لـ error عشان اللون يبقى أحمر ومنطقي
        animType: AnimType.scale,
        title: 'خطأ في الدخول',
        desc: errorMessage,
        btnOkColor:
            Colors.red, // تأكد إن mainColor معرف أو استبدله بـ Colors.red
        btnOkOnPress: () {},
      ).show();
    } catch (e) {
    //  print(e); // لأي أخطاء تانية غير متعلقة بفايربيز
    }
  }
}
