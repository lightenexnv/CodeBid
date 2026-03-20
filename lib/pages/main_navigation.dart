import 'package:codebid/controllers/nav_controller.dart';
import 'package:codebid/pages/alltasksbidpage.dart';
import 'package:codebid/pages/homepage.dart';
import 'package:codebid/pages/profilepage.dart';
import 'package:codebid/pages/taskspage.dart';
import 'package:codebid/pages/createtaskpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainNavigation extends StatelessWidget {
  MainNavigation({super.key});

  final NavController controller = Get.put(NavController());

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final userRef = FirebaseDatabase.instance
        .ref("codebid_database")
        .child("users")
        .child(user!.uid);

    return StreamBuilder(
      stream: userRef.onValue,
      builder: (context, snapshot) {

        if (!snapshot.hasData ||
            snapshot.data!.snapshot.value == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userData = Map<String, dynamic>.from(
            snapshot.data!.snapshot.value as Map);

        final role = userData["role"] ?? "";

        final pages = role == "requester"
            ? [
          Homepage(),
          TasksPage(),
          CreateTaskPage(),
          AllTasksBidPage(),
          ProfilePage()
        ]
            : [
          Homepage(),
          TasksPage(),
          AllTasksBidPage(),
          ProfilePage()
        ];

        return Obx(() => Scaffold(
          body: pages[controller.selectedIndex.value],

          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 65,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [

                    _navItem(Icons.home, "Home", 0),

                    _navItem(Icons.check_box_outlined, "Tasks", 1),

                    if (role == "requester")
                      GestureDetector(
                        onTap: () {
                          controller.changeIndex(2);
                        },
                        child: Container(
                          height: 45,
                          width: 45,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF2DD4BF),
                                Color(0xFF1FA2FF),
                              ],
                            ),
                          ),
                          child: const Icon(Icons.add,
                              color: Colors.white),
                        ),
                      ),

                    _navItem(
                      Icons.send_outlined,
                      "Bids",
                      role == "requester" ? 3 : 2,
                    ),

                    _navItem(
                      Icons.person_outline,
                      "Profile",
                      role == "requester" ? 4 : 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
      },
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () => controller.changeIndex(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: controller.selectedIndex.value == index
                ? const Color(0xFF1FA2FF)
                : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: controller.selectedIndex.value == index
                  ? const Color(0xFF1FA2FF)
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}