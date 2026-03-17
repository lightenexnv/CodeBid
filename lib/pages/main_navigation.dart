import 'package:codebid/controllers/nav_controller.dart';
import 'package:codebid/pages/bidspage.dart';
import 'package:codebid/pages/homepage.dart';
import 'package:codebid/pages/profilepage.dart';
import 'package:codebid/pages/taskspage.dart';
import 'package:codebid/pages/createtaskpage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class MainNavigation extends StatelessWidget {
  MainNavigation({super.key});

  final NavController controller = Get.put(NavController());

  final List<Widget> _pages = [
    Homepage(),
    TasksPage(),
    CreateTaskPage(),
    BidsPage(),
    ProfilePage()
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(()=> Scaffold(
      body: _pages[controller.selectedIndex.value],
      bottomNavigationBar: SafeArea(
          child:Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 65,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(Icons.home, "Home", 0),
                _navItem(Icons.check_box_outlined, "Tasks", 1),
                GestureDetector(
                  onTap: (){
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

                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
                _navItem(Icons.send_outlined, "Bids", 3),
                _navItem(Icons.person_outline, "Profile", 4),
              ],
            )),
          ),
    )
    )
    ) ;
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



