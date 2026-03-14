import 'package:codebid/controllers/auth_controller.dart';
import 'package:codebid/controllers/auth_page_controller.dart';
import 'package:codebid/pages/auth_pages/loginpage.dart';
import 'package:codebid/pages/main_navigation.dart';
import 'package:codebid/pages/rolepage.dart';
import 'package:codebid/utils/snackbarPopup.dart';
import 'package:flutter/material.dart';
import 'package:codebid/widgets/gradientwidget.dart';
import 'package:codebid/widgets/authtextfields.dart';
import 'package:get/get.dart';

class Signuppage extends StatelessWidget {
  Signuppage({super.key});

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final controller = AuthController();

  final AuthScreenControllers authcontroller = Get.put(AuthScreenControllers());

  void signup()async{
    try{
      final user = await controller.register(emailController.text.trim(), passwordController.text.trim());
      if(user!=null){
        Get.off(()=>MainNavigation());
      }
    } catch(e){
      SnackbarUtils.show("SignUp Failed", "Check Credentials");
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.sizeOf(context).height;
    final double width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Hero(
                tag: "gradientHero",
                child: Material(
                  color: Colors.transparent,
                  child: GradientHeader(
                    title: "Sign Up",
                    boxheight: 0.28,
                  ),
                ),
              ),
            ],
          ),

          Align(
            alignment: Alignment.center,
            child: Container(
              width: width * 0.9,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  )
                ],
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  AuthTextField(
                    hint: "Full Name",
                    icon: Icons.person_outline,
                    controller: nameController,
                  ),

                  SizedBox(height: height * 0.02),

                  AuthTextField(
                    hint: "Email",
                    icon: Icons.email_outlined,
                    controller: emailController,
                  ),

                  SizedBox(height: height * 0.02),

                  Obx(() => AuthTextField(
                    hint: "Password",
                    icon: Icons.lock_outline,
                    controller: passwordController,
                    obscure: authcontroller.isObscure.value,
                    suffixIcon: IconButton(
                      icon: Icon(
                        authcontroller.isObscure.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: authcontroller.toggleObscure,
                    ),
                  )),

                  SizedBox(height: height * 0.02),

                  Obx(() => AuthTextField(
                    hint: "Confirm Password",
                    icon: Icons.lock_outline,
                    controller: confirmController,
                    obscure: authcontroller.isObscure.value,
                    suffixIcon: IconButton(
                      icon: Icon(
                        authcontroller.isObscure.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: authcontroller.toggleObscure,
                    ),
                  )),

                  SizedBox(height: height * 0.03),

                  InkWell(
                    onTap: (){
                      signup();
                    },
                    child: Hero(
                      tag: "hero-button",
                      child: Material(
                        child: Container(
                          height: height * 0.065,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF2DD4BF),
                                Color(0xFF1FA2FF),
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              "Create Account",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      InkWell(
                        onTap: () {
                          Get.off(() => Loginpage());
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1FA2FF),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}