
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart' show FontAwesome;
import 'package:the_dark_knight_final/auth/controller/auth_controller.dart';
import 'package:the_dark_knight_final/auth/ui/signIn.dart';
import 'package:the_dark_knight_final/auth/ui/widgets%20screen%20(all%20widgets).dart';
import 'package:the_dark_knight_final/controller/sql_controller.dart';
import 'package:the_dark_knight_final/layout/home.dart';
import 'package:the_dark_knight_final/shared/components.dart';

class Signup extends StatefulWidget {
  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController1 = TextEditingController();

  GlobalKey<FormState> form = new GlobalKey<FormState>();

  bool remember=false;

  @override
  Widget build(BuildContext context) {
    ShowPasswordController ctr = Get.put( ShowPasswordController());
    //السطر اللي فوقيا هو المسئول عن  عمل انستانس من الكنترولر وهو الحل بتاع مشكلة   null operator
    // TODO: implement build
    return Scaffold(
        body: 
     // Image.asset("assets/images/signup.jpg"),
      Container(
         // height: 800,
          color: Color.fromARGB(255, 8, 1, 1),
          padding: EdgeInsets.fromLTRB(50, 0, 30, 0),
          child: Form(
            key: form,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                  children: [
              SizedBox(
                height: 20,
              ),
               Text(
                "sign up",
                style: GoogleFonts.timmana(fontWeight: FontWeight.bold,
                fontSize: 50, color:mainColor,)
              ),
              SizedBox(
                height: 0,
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
              GetBuilder<ShowPasswordController>(builder: (controller) {
                return TextFormFieldScreen(
                    obsureText: controller.isshowPassword,
                    controller: passwordController1,
                    keyboardType: TextInputType.name,
                    label: "Password",
                    prefix: Icons.lock,
                    validator: (value) {
                      return ValidatorScreen(
                          value!, 6, 90, "passwordController1");
                    },
                    suffixIcon: controller.isshowPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    onPressed: () {
                      controller.showPassword();
                    });
              }),
              const SizedBox(height: 10,),
              MaterialButtonScreen(
                
                onPressed: () async {

                 // print("8888888888888");

                  var cred = await ctr.signInWithGoogle();

                  //print('________/___/____/$cred');

                  if(cred!=null){
                      Get.find<Sqlcrt>().fetchFromCloud();
                      Get.to(()=> Home_page());
                      Get.snackbar("Rofof","Logged In Successfully");
                  }
                },
                titleOfButton: "sign in with google",
                Icons: const Icon(FontAwesome.google,
                    color: Colors.amber, size: 24.0),
                colorOfButton: Colors.grey,
                fontColor: Color.fromARGB(255, 9, 9, 9),
                fontSize: 15,
                fontWeight: FontWeight.bold,
             
                
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [const SizedBox(width: 20),
                   Text(
                    "Remember Me",style: TextStyle(color: mainColor),
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
                  ]),

              MaterialButtonScreen(
                onPressed: () async {
                  if (form.currentState!.validate()) {
                   await ctr.signup(emailController,passwordController1);
                   
                  }
                  
                },    
                titleOfButton: "Sign Up            ",
                Icons: const Icon(FontAwesome.google,
                    color: Colors.amber, size: 24.0),
                colorOfButton: mainColor,
                fontColor: Colors.white,
                fontSize: 15,
                //fontWeight: FontWeight.bold, fontcolor: Colors.amber,
              ),
              SizedBox(
                height: 20,
              ),
              
              TextButton(
                  onPressed: () {
                    Get.to(() => SignIn());
                  },
                  child: Text(
                    "          Do you Have an Account? Sign In",
                    style: TextStyle(color: mainColor, fontSize: 15),
                  ))
            ]),
          ))
    );
  }

    



}
