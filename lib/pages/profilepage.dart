import 'package:codebid/controllers/nav_controller.dart';
import 'package:codebid/controllers/page_controllers/profile_page_controller.dart';
import 'package:codebid/controllers/profileimagecontroller.dart';
import 'package:codebid/pages/settingspage.dart';
import 'package:codebid/widgets/profile_page_widgets/menu_item.dart';
import 'package:codebid/widgets/profile_page_widgets/stat_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfilePageController());
    final profileController = Get.put(ProfileImageController());

    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;

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
                Obx(() => CircleAvatar(
                  radius: 50,
                  backgroundImage: profileController.profileImage.value.isNotEmpty
                      ? NetworkImage(profileController.profileImage.value)
                      : const AssetImage("assets/icons/default-profile.png")
                  as ImageProvider,
                )),
                const SizedBox(height: 10),
                Obx(() {
                  if (controller.isLoading.value) {
                    return const CircularProgressIndicator();
                  }
                  return Text(
                    controller.name.value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  );
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
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                      )
                    ],
                  ),
                  child: Obx(() {
                    if (controller.role.value == "requester") {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          StatItem(
                            title: "Pending",
                            value: controller.totalTasks.value,
                          ),
                        ],
                      );
                    } else {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          StatItem(
                            title: "Pending",
                            value: controller.totalTasks.value,
                          ),
                          StatItem(
                            title: "Bids",
                            value: controller.totalBids.value,
                          ),
                          StatItem(
                            title: "Won",
                            value: controller.totalWon.value,
                          ),
                        ],
                      );
                    }
                  }),
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
                            final controller = Get.find<ProfilePageController>();

                            if (controller.role.value == "requester") {
                              Get.find<NavController>().changeIndex(3);
                            } else {
                              Get.find<NavController>().changeIndex(2);
                            }
                          },
                        ),
                        MenuItem(
                          icon: Icons.settings_outlined,
                          title: "Settings",
                          tileColor: Colors.white,
                          textColor: Colors.black,
                          onTap: () {
                            Get.to(SettingsPage());

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
                          onTap: controller.logout,
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