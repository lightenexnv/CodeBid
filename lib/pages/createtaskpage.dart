import 'package:codebid/widgets/authtextfields.dart';
import 'package:codebid/widgets/gradientwidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:codebid/controllers/page_controllers/create_task_page_controller.dart';
class CreateTaskPage extends StatelessWidget {
  final bool isEdit;
  final Map? task;

  const CreateTaskPage({
    super.key,
    this.isEdit = false,
    this.task,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      CreateTaskPageController(isEdit: isEdit, task: task),
    );

    final height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Hero(
              tag: "gradientHero",
              child: Material(
                color: Colors.transparent,
                child: GradientHeader(
                  title: isEdit ? "Edit Task" : "Create Task",
                  boxheight: 0.2,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  AuthTextField(
                    hint: "Task Title",
                    icon: Icons.search,
                    controller: controller.taskTitleController,
                  ),
                  SizedBox(height: height * 0.02),

                  AuthTextField(
                    hint: "Task Description",
                    icon: Icons.document_scanner,
                    controller: controller.descTitleController,
                    maxLines: 4,
                  ),
                  SizedBox(height: height * 0.02),

                  AuthTextField(
                    hint: "Budget",
                    icon: Icons.currency_rupee,
                    controller: controller.budgetTitleController,
                  ),
                  SizedBox(height: height * 0.02),

                  AuthTextField(
                    hint: "GitHub Link",
                    icon: Icons.link,
                    controller: controller.githubLinkController,
                  ),
                  SizedBox(height: height * 0.02),

                  Obx(() {
                    if (controller.imageFiles.isEmpty) return SizedBox();

                    return SizedBox(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.imageFiles.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                controller.imageFiles[index],
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),

                  const SizedBox(height: 10),

                  GestureDetector(
                    onTap: controller.pickImages,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F5F7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text("Upload Images"),
                      ),
                    ),
                  ),

                  SizedBox(height: height * 0.03),

                  Obx(() {
                    return GestureDetector(
                      onTap: controller.isLoading.value
                          ? null
                          : controller.submitTask,
                      child: Container(
                        height: 55,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF2DD4BF),
                              Color(0xFF1FA2FF),
                            ],
                          ),
                          borderRadius:
                          BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: controller.isLoading.value
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                              : Text(
                            isEdit
                                ? "Update Task"
                                : "Post Task",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}