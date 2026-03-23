import 'package:codebid/pages/auth_pages/loginpage.dart';
import 'package:codebid/pages/auth_pages/signuppage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Welcomepage extends StatelessWidget {
  const Welcomepage({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      body: Hero(
        tag: "gradientHero",
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Color(0xFF2DD4BF),
                    Color(0xFF1FA2FF),
                    Colors.black
                  ],
              begin: Alignment.topLeft,
              end: Alignment.bottomCenter)
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
          
                  Image.asset(
                    "assets/logo/codebid-logo-only-white.png",
                    height: height*0.15
                  ),
                  SizedBox(height: height*0.01,),
                  Text("CodeBid - \nTurn Bugs Into \nOpportunities",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: height*0.035,
                      fontWeight: FontWeight.w600,
                    ),),
                  SizedBox(height: height*0.01,),
                  InkWell(
                    onTap: (){

                      Get.to(() => Signuppage());
                    },
                    child: Container(
                      height: height*0.07,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(colors: [
                          Color(0xFF2DD4BF),
                          Color(0xFF1FA2FF)
                        ])
                      ),
                      child: Center(
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: height*0.02,
                            fontWeight: FontWeight.w600
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height*0.01,),
                  InkWell(
                    onTap: (){
                      Get.to(() => Loginpage());
                    },
                    child: Container(
                      height: height*0.07,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white38)
                      ),
                      child: Center(
                        child: Text(
                          "I Have an account",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: height*0.02,
                              fontWeight: FontWeight.w600
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
