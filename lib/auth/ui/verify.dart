import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:the_dark_knight_final/layout/home.dart';
import 'package:get/get.dart';
import 'dart:async';

class VerifyEmailPage extends StatefulWidget {
  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    // التأكد إذا كان المستخدم قد فعل الإيميل مسبقاً
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      // إرسال إيميل التفعيل (احتياطياً)
      sendVerificationEmail();

      // فحص الحالة تلقائياً كل 3 ثوانٍ
      timer = Timer.periodic(Duration(seconds: 3), (_) => checkEmailVerified());
    }
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
    } catch (e) {
      Get.snackbar("خطأ", e.toString());
    }
  }

  Future checkEmailVerified() async {
    // تحديث بيانات المستخدم من السيرفر
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) {
      timer?.cancel();
      Get.offAll(() => Home_page()); // اذهب للرئيسية فور التفعيل
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("تحقق من بريدك")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mark_email_unread_outlined, size: 100, color: Colors.blue),
            SizedBox(height: 24),
            Text(
              'لقد أرسلنا رابط تفعيل إلى بريدك الإلكتروني. يرجى الضغط عليه لتفعيل حسابك.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: sendVerificationEmail,
              icon: Icon(Icons.email),
              label: Text("إعادة إرسال الرابط"),
            ),
            TextButton(
              onPressed: () => FirebaseAuth.instance.signOut(),
              child: Text("إلغاء"),
            ),
          ],
        ),
      ),
    );
  }
}