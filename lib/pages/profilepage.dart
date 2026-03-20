import 'dart:math';

import 'package:codebid/controllers/auth_controller.dart';
import 'package:codebid/controllers/nav_controller.dart';
import 'package:codebid/pages/auth_pages/loginpage.dart';
import 'package:codebid/pages/welcomepage.dart';
import 'package:codebid/utils/snackbarPopup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:codebid/widgets/profile_page_widgets/menu_item.dart';
import 'package:codebid/widgets/profile_page_widgets/stat_item.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});




  final controller = AuthController();
  void logout() async {
    try {
      await controller.logout();
      Get.offAll(() => Welcomepage());
    } catch (e) {
      SnackbarUtils.show("Logout Failed", "Something went wrong");
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final DatabaseReference ref = FirebaseDatabase.instance
        .ref("codebid_database")
        .child("users")
        .child(user!.uid);
    final double height = MediaQuery.sizeOf(context).height;
    final double width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: Stack(
        children: [
          Container(
            height: height * 0.32,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF2DD4BF),
                  Color(0xFF1FA2FF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    "https://i.pravatar.cc/200",
                  ),
                ),
                const SizedBox(height: 10),
                StreamBuilder<DatabaseEvent>(stream: ref.onValue,
                    builder: (context, AsyncSnapshot<DatabaseEvent> snapshot){
                  if(!snapshot.hasData||snapshot.data!.snapshot.value==null){
                    return CircularProgressIndicator();
                  }

                  final data = Map<String, dynamic>.from(
                      snapshot.data!.snapshot.value as Map
                  );

                  return Text(
                      data["name"]?.toString() ?? "User",
                      style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      ));
                    }),
                const Text(
                  "@neil_v",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: width * 0.9,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      StatItem(title: "Tasks", value: "12"),
                      StatItem(title: "Bids", value: "28"),
                      StatItem(title: "Won", value: "7"),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Expanded(
                  child: Container(
                    width: width,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        MenuItem(
                          icon: Icons.task_alt,
                          title: "My Tasks",
                          tileColor: Colors.white,
                          textColor: Colors.black,
                          onTap: () {
                            Get.find<NavController>().changeIndex(1);
                          },
                        ),

                        MenuItem(
                          icon: Icons.gavel_outlined,
                          title: "My Bids",
                          tileColor: Colors.white,
                          textColor: Colors.black,
                          onTap: () {
                            Get.find<NavController>().changeIndex(3);
                          },
                        ),

                        MenuItem(
                          icon: Icons.settings_outlined,
                          title: "Settings",
                          tileColor: Colors.white,
                          textColor: Colors.black,
                          onTap: () {
                            Get.to(() => ());
                          },
                        ),

                        MenuItem(
                          icon: Icons.logout,
                          title: "Logout",
                          textColor: Colors.black,
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF2DD4BF),
                              Color(0xFF1FA2FF),
                            ],
                          ),
                          onTap: () {
                            logout();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



