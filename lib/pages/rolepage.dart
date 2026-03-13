import 'package:codebid/pages/homepage.dart';
import 'package:codebid/widgets/gradientwidget.dart';
import 'package:codebid/widgets/rolepagerolebox.dart';
import 'package:flutter/material.dart';

class Rolepage extends StatelessWidget {
  const Rolepage({super.key});

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

                  RoleBoxWidget(boxheight: 0.13, gradientstart: Color(0xFF1FA2FF), gradientend: Color(0xFF2DD4BF), displayicon: Icons.bug_report_sharp, titletext: "Requester", desctext: "Post Task", ontapfunction: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> Homepage()));
                  }),

                  SizedBox(height: height * 0.025),

                  Hero(
                      tag: "hero-button",
                      child: Material(child: RoleBoxWidget(boxheight: 0.13, gradientstart: Color(0xFF2DD4BF), gradientend: Color(0xFF1FA2FF), displayicon: Icons.smart_toy_rounded, titletext: "Solver", desctext: "Bids & Solve Tasks", ontapfunction: (){}))),
                  ]
              ),
            ),
          ),
        ],
      ),
    );
  }
}