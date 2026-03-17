import 'package:codebid/pages/main_navigation.dart';
import 'package:codebid/widgets/gradientwidget.dart';
import 'package:codebid/widgets/rolepagerolebox.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Rolepage extends StatelessWidget {
  Rolepage({super.key});


  Future<void> saveRole (String role)async{

    final user = FirebaseAuth.instance.currentUser;

    if(user==null){
      return null;
    }
    final ref = FirebaseDatabase.instance.ref("codebid_database").child("users").child(user.uid);
    await ref.set({
      "name":user.displayName,
      "email":user.email,
      "role":role,
      "createdAt":DateTime.now().millisecondsSinceEpoch,
    });

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
                    title: "Select Your Role",
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
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ],
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  RoleBoxWidget(boxheight: 0.13, gradientstart: Color(0xFF1FA2FF), gradientend: Color(0xFF2DD4BF), displayicon: Icons.bug_report_sharp, titletext: "Requester", desctext: "Post Task", ontapfunction: ()async{
                    await saveRole("requester");

                    Get.to(()=> MainNavigation());
                  }),

                  SizedBox(height: height * 0.025),

                  Hero(
                      tag: "hero-button",
                      child: Material(child: RoleBoxWidget(boxheight: 0.13, gradientstart: Color(0xFF2DD4BF), gradientend: Color(0xFF1FA2FF), displayicon: Icons.smart_toy_rounded, titletext: "Solver", desctext: "Bids & Solve Tasks", ontapfunction: ()async{
                        await saveRole("solver");
                        Get.to(()=> MainNavigation());
                      }))),
                  ]
              ),
            ),
          ),
        ],
      ),
    );
  }
}