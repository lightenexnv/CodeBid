import 'package:codebid/controllers/page_controllers/tasks_page_controller.dart';
import 'package:codebid/pages/taskoverviewpage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TasksPageController());
    final height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: Column(
        children: [
          Container(
            height: height * 0.256,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "My Tasks",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 25),
                TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    hintText: "Search your tasks...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
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

                  return GestureDetector(
                    onTap: () {
                      Get.to(TaskOverviewPage(task: task));
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (images.isNotEmpty)
                            Hero(
                              tag: task["id"] ?? images[0],
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  images[0],
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          SizedBox(height: height * 0.01),
                          Text(
                            task["title"] ?? "",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            task["description"] ?? "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          SizedBox(height: height * 0.01),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "₹ ${task["budget"]}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1FA2FF),
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios,
                                  size: 14)
                            ],
                          )
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