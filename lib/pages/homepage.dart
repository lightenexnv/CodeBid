import 'package:codebid/controllers/nav_controller.dart';
import 'package:codebid/controllers/page_controllers/homepage_controller.dart';
import 'package:codebid/controllers/page_controllers/profile_page_controller.dart';
import 'package:codebid/controllers/profileimagecontroller.dart';
import 'package:codebid/pages/taskoverviewpage.dart';
import 'package:codebid/utils/timeUtil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.put(ProfileImageController());
    final controller = Get.put(HomepageController());
    final height = MediaQuery.sizeOf(context).height;
    final ProfilePageController profilePageController = Get.put(ProfilePageController());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),

      body: Column(
        children: [

          Container(
            height: height * 0.23,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF2DD4BF),
                  Color(0xFF1FA2FF),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          "assets/logo/codebid-logo-only-white.png",
                          height: 30,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "CodeBid",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_none),
                          color: Colors.white,
                          onPressed: () {},
                        ),
                        const SizedBox(width: 15),
                        GestureDetector(
                          onTap: () {
                            final role = Get.find<ProfilePageController>().role.value;

                            if (role == "requester") {
                              Get.find<NavController>().changeIndex(4);
                            } else {
                              Get.find<NavController>().changeIndex(3);
                            }
                          },
                          child: Obx(() => CircleAvatar(
                            radius: 16,
                            backgroundImage: profileController.profileImage.value.isNotEmpty
                                ? NetworkImage(profileController.profileImage.value)
                                : const AssetImage("assets/icons/default-profile.png")
                            as ImageProvider,
                          )),
                        ),
                      ],
                    )
                  ],
                ),

                const SizedBox(height: 25),

                Container(
                  height: height * 0.06,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.search, color: Colors.grey),
                      hintText: "Search bugs, tasks...",
                      border: InputBorder.none,
                    ),
                  ),
                )
              ],
            ),
          ),

          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF1FA2FF),
                  ),
                );
              }

              if (controller.tasks.isEmpty) {
                return const Center(child: Text("No Tasks Found"));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: controller.tasks.length,
                itemBuilder: (context, index) {
                  final task = controller.tasks[index];

                  final images = task["images"] ?? [];
                  final bidsMap = task["bids"] != null
                      ? Map<String, dynamic>.from(task["bids"])
                      : {};

                  final bidCount = bidsMap.length;
                  final isClosed = task["isClosed"] == true;
                  final timestamp = task["timestamp"];

                  return GestureDetector(
                    onTap: () {
                      Get.to(TaskOverviewPage(task: task));
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          if (images.isNotEmpty)
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                              child: Image.network(
                                images[0],
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),

                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Text(
                                  task["title"]?.toString() ?? "",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                const SizedBox(height: 10),

                                Row(
                                  children: [
                                    Text(
                                      "₹ ${task["budget"]}",
                                      style: const TextStyle(
                                        color: Color(0xFF1FA2FF),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      "$bidCount Bids",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 6),

                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      TimeUtils.getTimeAgo(timestamp),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),

                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isClosed
                                            ? Colors.red.withOpacity(0.1)
                                            : Colors.green.withOpacity(0.1),
                                        borderRadius:
                                        BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        isClosed ? "Closed" : "Active",
                                        style: TextStyle(
                                          color: isClosed
                                              ? Colors.red
                                              : Colors.green,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          )
        ],
      ),
    );
  }
}