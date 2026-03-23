import 'package:codebid/controllers/page_controllers/role_page_controller.dart';
import 'package:codebid/widgets/gradientwidget.dart';
import 'package:codebid/widgets/rolepagerolebox.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Rolepage extends StatelessWidget {
  Rolepage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RolePageController());

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

                  
                  RoleBoxWidget(
                    boxheight: 0.13,
                    gradientstart: const Color(0xFF1FA2FF),
                    gradientend: const Color(0xFF2DD4BF),
                    displayicon: Icons.bug_report_sharp,
                    titletext: "Requester",
                    desctext: "Post Task",
                    ontapfunction: () {
                      if (!controller.isLoading.value) {
                        controller.saveRole("requester");
                      }
                    },
                  ),

                  SizedBox(height: height * 0.025),

                  
                  RoleBoxWidget(
                    boxheight: 0.13,
                    gradientstart: const Color(0xFF2DD4BF),
                    gradientend: const Color(0xFF1FA2FF),
                    displayicon: Icons.smart_toy_rounded,
                    titletext: "Solver",
                    desctext: "Bids & Solve Tasks",
                    ontapfunction: () {
                      if (!controller.isLoading.value) {
                        controller.saveRole("solver");
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}