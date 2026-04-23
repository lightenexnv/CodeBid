import 'package:codebid/widgets/authtextfields.dart';
import 'package:codebid/widgets/gradientwidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:codebid/controllers/page_controllers/create_task_page_controller.dart';

class CreateTaskPage extends StatefulWidget {
  final bool isEdit;
  final Map? task;

  const CreateTaskPage({
    super.key,
    this.isEdit = false,
    this.task,
  });

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  late CreateTaskPageController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      CreateTaskPageController(isEdit: widget.isEdit, task: widget.task),
    );
    // Listen for AI results and show the sheet synchronously (no async gap)
    ever(controller.showSheet, (val) {
      if (val == true) {
        controller.showSheet.value = false;
        _showAiSuggestionsSheet(controller);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  title: widget.isEdit ? "Edit Task" : "Create Task",
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
                  SizedBox(height: height * 0.015),

                  // ✨ AI BUTTON
                  Obx(() {
                    final isLoading = controller.isAiLoading.value;
                    return GestureDetector(
                      onTap: isLoading
                          ? null
                          : () => controller.analyzeWithAI(),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 13),
                        decoration: BoxDecoration(
                          gradient: isLoading
                              ? null
                              : const LinearGradient(
                                  colors: [
                                    Color(0xFF6EE7F7),
                                    Color(0xFF818CF8),
                                  ],
                                ),
                          color:
                              isLoading ? const Color(0xFFE0F2FE) : null,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: isLoading
                              ? []
                              : [
                                  BoxShadow(
                                    color: const Color(0xFF818CF8)
                                        .withValues(alpha: 0.35),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                        ),
                        child: Center(
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Color(0xFF818CF8),
                                  ),
                                )
                              : const Text(
                                  "✨  Analyze with AI",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                        ),
                      ),
                    );
                  }),

                  SizedBox(height: height * 0.015),

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
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: controller.isLoading.value
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                              : Text(
                            widget.isEdit ? "Update Task" : "Post Task",
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

  void _showAiSuggestionsSheet(CreateTaskPageController controller) {
    Get.bottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6EE7F7), Color(0xFF818CF8)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.auto_awesome,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "AI Suggestions",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E2E),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),
              Text(
                "Review the AI-generated suggestions below and choose to apply or keep your original content.",
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.grey.shade500,
                ),
              ),

              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Title suggestion
              _SuggestionCard(
                icon: Icons.title_rounded,
                label: "Suggested Title",
                value: controller.aiTitle.value,
                iconColor: const Color(0xFF818CF8),
              ),
              const SizedBox(height: 12),

              // Description suggestion
              _SuggestionCard(
                icon: Icons.description_rounded,
                label: "Suggested Description",
                value: controller.aiDescription.value,
                iconColor: const Color(0xFF22D3EE),
              ),
              const SizedBox(height: 12),

              // Skills suggestion
              _SuggestionCard(
                icon: Icons.code_rounded,
                label: "Skills Required",
                value: controller.aiSkills.value,
                iconColor: const Color(0xFF34D399),
              ),
              const SizedBox(height: 12),

              // Budget & Time row
              Row(
                children: [
                  Expanded(
                    child: _SuggestionCard(
                      icon: Icons.currency_rupee_rounded,
                      label: "Budget",
                      value: "₹${controller.aiBudget.value}",
                      iconColor: const Color(0xFFF59E0B),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SuggestionCard(
                      icon: Icons.schedule_rounded,
                      label: "Est. Time",
                      value: controller.aiTime.value,
                      iconColor: const Color(0xFFEC4899),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Apply button
              GestureDetector(
                onTap: () {
                  controller.applyAiSuggestions();
                  Get.back();
                },
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6EE7F7), Color(0xFF818CF8)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF818CF8).withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "✅  Apply AI Suggestions",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Keep original button
              GestureDetector(
                onTap: () {
                  controller.discardAiSuggestions();
                  Get.back();
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Center(
                    child: Text(
                      "Keep Original",
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A reusable styled card for displaying a single AI suggestion field.
class _SuggestionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _SuggestionCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: iconColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF1F2937),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}