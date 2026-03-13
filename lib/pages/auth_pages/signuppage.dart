import 'package:codebid/pages/auth_pages/loginpage.dart';
import 'package:codebid/pages/rolepage.dart';
import 'package:flutter/material.dart';
import 'package:codebid/widgets/gradientwidget.dart';
import 'package:codebid/widgets/authtextfields.dart';

class Signuppage extends StatelessWidget {
  const Signuppage({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();

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


                  AuthTextField(
                    hint: "Password",
                    icon: Icons.lock_outline,
                    controller: passwordController,
                  ),

                  SizedBox(height: height * 0.02),


                  AuthTextField(
                    hint: "Confirm Password",
                    icon: Icons.lock_outline,
                    controller: confirmController,
                  ),

                  SizedBox(height: height * 0.03),


                  InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> Rolepage()));
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
                          child: Center(
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
                      Text("Already have an account? "),
                      InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> Loginpage()));
                        },
                        child: Text(
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