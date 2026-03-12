
import 'package:the_dark_knight_final/auth/ui/signIn.dart';
import 'package:the_dark_knight_final/layout/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_storage/get_storage.dart';

ValidatorScreen(String value, int min, int max, String type) {
   if (value.isEmpty) {
    return "can't be Empty";
  }

  if (type == "usernameController") {
    if (!GetUtils.isUsername(value)) {
      return "not valid username";
    }
  }
  if (type == "emailController") {
    if (!GetUtils.isEmail(value)) {
      return "not valid email";
    }
  }

  if (type == "phoneNumberController") {
    if (!GetUtils.isPhoneNumber(value)) {
      return "this is not Correct Number";
    }
  }

 
  if (value.length < min) {
    return "can't be less than $min";
  }

  if (value.length > max) {
    return "can't be larger than $max";
  }
}


class ShowPasswordClass extends GetxController {
  bool isshowPassword = true;
  
  
   late SharedPreferences _sharedPreferences;
  Future<void> initializeSharedPreferences() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  @override
  void onInit() {
    super.onInit();
    initializeSharedPreferences();
  }

  void showPassword() {
    isshowPassword = !isshowPassword;
    update();
  }

  Future<void> save() async {
     //("+++++++++++++++++");
    //print(_sharedPreferences.getBool("remember"));
    await _sharedPreferences.setBool("remember", true);
   /*  print("+++++++++++++++++");
    print(_sharedPreferences.getBool("remember"));
    print(FirebaseAuth.instance.currentUser); */
  }
    
static Future<bool> firest() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final remember = sharedPreferences.getBool("remember") ?? false;
    final user = FirebaseAuth.instance.currentUser;
    
    if (user != null &&  remember) {
      return true;
    } else {
      return false;
    }
  }    
    
    
  }
 

class TextFormFieldScreen extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String label;
 final bool? obsureText;
  final IconData? prefix;
  final IconData? suffixIcon;
  //final Function()? suffixPressed;
  final String? Function(String?)? validator;
  final void Function()? onPressed;
  final void Function()? onTap;
  // عشان onPressed تتنفذ لا تضع كلمة void or required
  // ولا حتي ال (){} دول تحت هنخليها كدا >>> suffixIcon: IconButton(onPressed:onPressed

  TextFormFieldScreen({
    Key? key,
    required this.controller,
    required this.keyboardType,
    required this.label,
    this.prefix,
    this.obsureText,
    this.suffixIcon,
    required this.validator,
    this.onPressed,
    this.onTap,
  }) : super(key: key);

  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          
          borderRadius: BorderRadius.all(Radius.circular(30))),
      
      margin: EdgeInsets.only(top: 20, right: 8, left: 8),
      child: TextFormField(style: TextStyle(color: Colors.white),
        autocorrect: true,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obsureText == null || obsureText == false ? false : true,
        decoration: InputDecoration(
         
          border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white10),
              borderRadius: BorderRadius.all(Radius.circular(30))),
          contentPadding: EdgeInsets.symmetric(vertical: 0),
          label: Text(label,
              style:
                  TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
          prefixIcon: Icon(prefix),
          suffixIcon: IconButton(onPressed: onPressed, icon: Icon(suffixIcon)),
        ),
        onTap: onTap,
        validator: validator,
      ),
    );
  }
}

class MaterialButtonScreen extends StatelessWidget {
  final String titleOfButton;
  final double? widthOfButton;
  final FontWeight? fontWeight;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double? fontSize;
  final Color? fontColor;
  final FontStyle? fontStyle;
  final Color? colorOfButton;

  const MaterialButtonScreen({
    required this.titleOfButton,
    this.widthOfButton,
    this.fontWeight,
    this.onPressed,
    this.icon,
    this.fontSize,
    this.fontColor,
    this.fontStyle,
    this.colorOfButton,
    required Icon Icons,
    //required MaterialColor fontolor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 40,
        width: widthOfButton ?? double.infinity,
        margin: EdgeInsets.only(top: 10, right: 8, left: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          color: colorOfButton,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black),
            SizedBox(width: 8.0),
            Text(
              titleOfButton,
              style: TextStyle(
                color: fontColor,
                fontSize: fontSize,
                fontWeight: fontWeight,
                fontStyle: fontStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Auth extends StatefulWidget {
  @override
  _AuthState createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  late SharedPreferences _sharedPreferences;
  bool remember = false;

  @override
  void initState() {
    super.initState();
    initializeSharedPreferences();
  }

  Future<void> initializeSharedPreferences() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      remember = _sharedPreferences.getBool("remember") ?? false;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
         /*  print("----------------------");
          print(remember); */

          if (snapshot.hasData && remember) {
            return  Home_page();
          } else {
            return SignIn();
          }
        },
      ),
    );
  }
}
 _snack(String title,String message){
  return Get.snackbar(title, message,backgroundColor: Colors.cyan);
}
