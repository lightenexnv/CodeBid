import 'dart:convert';
import 'dart:io';
import 'package:codebid/controllers/nav_controller.dart';
import 'package:codebid/service/gemini_service.dart';
import 'package:flutter/material.dart';

import 'package:codebid/utils/snackbarPopup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CreateTaskPageController extends GetxController {
  final bool isEdit;
  final Map? task;

  CreateTaskPageController({required this.isEdit, this.task});

  final taskTitleController = TextEditingController();
  final descTitleController = TextEditingController();
  final budgetTitleController = TextEditingController();
  final githubLinkController = TextEditingController();

  final picker = ImagePicker();

  RxList<File> imageFiles = <File>[].obs;
  RxList<String> existingImages = <String>[].obs;

  RxBool isLoading = false.obs;

  // 🔥 AI Fields
  RxString aiBudget = "".obs;
  RxString aiTime = "".obs;
  RxString aiSkills = "".obs;
  RxString aiTitle = "".obs;
  RxString aiDescription = "".obs;
  RxBool isAiLoading = false.obs;
  RxBool showSheet = false.obs;

  @override
  void onInit() {
    super.onInit();

    if (isEdit && task != null) {
      taskTitleController.text = task!["title"] ?? "";
      descTitleController.text = task!["description"] ?? "";
      budgetTitleController.text = task!["budget"]?.toString() ?? "";
      githubLinkController.text = task!["github"] ?? "";

      existingImages.value =
      List<String>.from(task!["images"] ?? []);
    }
  }

  // 🔥 GEMINI AI ANALYSIS
  Future<void> analyzeWithAI() async {
    final title = taskTitleController.text.trim();
    final description = descTitleController.text.trim();

    if (description.isEmpty) {
      SnackbarUtils.show("Error", "Enter a description first");
      return;
    }

    try {
      isAiLoading.value = true;

      final prompt = """
You are an AI assistant for a freelancing platform. Return ONLY valid JSON with no extra text.

Given the task details below, return a JSON with:
- "title": A short, clear, professional task title (max 10 words)
- "description": A clear, detailed, professional task description (2–4 sentences)
- "skills": Comma-separated list of specific technical skills required (e.g. "Flutter, Firebase, REST API")
- "budget": A single integer representing the fair price in INR (no range, no symbol, just the number)
- "time": Estimated completion time (e.g. "3 days")

Return format:
{
  "title": "...",
  "description": "...",
  "skills": "...",
  "budget": 3500,
  "time": "3 days"
}

Current title: $title
Current description: $description
""";

      final response = await GeminiService.generate(prompt);

      // Parse budget as int or string
      final rawBudget = response["budget"];
      final budgetStr = rawBudget is int
          ? rawBudget.toString()
          : rawBudget?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? "";

      aiTitle.value = response["title"]?.toString() ?? title;
      aiDescription.value = response["description"]?.toString() ?? description;
      aiSkills.value = response["skills"]?.toString() ?? "Not available";
      aiBudget.value = budgetStr;
      aiTime.value = response["time"]?.toString() ?? "Not available";

      // Signal page to open the sheet
      showSheet.value = true;

    } catch (e) {
      debugPrint("AI ERROR: $e");
      SnackbarUtils.show("AI Error", e.toString().replaceAll("Exception: ", ""));
    } finally {
      isAiLoading.value = false;
    }
  }

  /// Apply AI suggestions to the form fields
  void applyAiSuggestions() {
    taskTitleController.text = aiTitle.value;
    descTitleController.text = aiDescription.value;
    budgetTitleController.text = aiBudget.value;
  }

  /// Dismiss AI suggestions without applying
  void discardAiSuggestions() {
    aiTitle.value = "";
    aiDescription.value = "";
    aiSkills.value = "";
    aiBudget.value = "";
    aiTime.value = "";
  }

  Future pickImages() async {
    final picked = await picker.pickMultiImage();

    if (picked.isNotEmpty) {
      if (picked.length > 5) {
        Get.snackbar("Limit", "Max 5 images allowed");
        return;
      }

      imageFiles.value =
          picked.map((e) => File(e.path)).toList();
    }
  }

  Future<List<String>> uploadImages(List<File> files) async {
    List<String> urls = [];

    for (var file in files) {
      final url = Uri.parse(
          "https://api.cloudinary.com/v1_1/defl5v5uk/image/upload");

      var request = http.MultipartRequest('POST', url);

      request.fields["upload_preset"] = "CodeBid";

      request.files.add(
        await http.MultipartFile.fromPath('file', file.path),
      );

      var response = await request.send();
      var res = await http.Response.fromStream(response);

      final data = jsonDecode(res.body);

      urls.add(data["secure_url"]);
    }

    return urls;
  }

  Future submitTask() async {
    final user = FirebaseAuth.instance.currentUser;

    final taskId = isEdit
        ? task!["taskId"]
        : DateTime.now().millisecondsSinceEpoch.toString();

    final title = taskTitleController.text.trim();
    final desc = descTitleController.text.trim();
    final budgetText = budgetTitleController.text.trim();
    final github = githubLinkController.text.trim();

    if (title.isEmpty || desc.isEmpty || budgetText.isEmpty) {
      SnackbarUtils.show("Error", "Please fill all fields");
      return;
    }

    if (title.length < 10) {
      SnackbarUtils.show("Error", "Title must be at least 10 characters");
      return;
    }

    if (desc.length < 100) {
      SnackbarUtils.show("Error", "Description must be at least 100 characters");
      return;
    }

    final budget = int.tryParse(budgetText.replaceAll(RegExp(r'[^0-9]'), ''));
    if (budget == null || budget <= 0) {
      SnackbarUtils.show("Error", "Budget must be a valid number");
      return;
    }

    if (github.isNotEmpty &&
        (!github.contains("github.com") ||
            Uri.tryParse(github)?.isAbsolute != true)) {
      SnackbarUtils.show("Error", "Enter a valid GitHub link");
      return;
    }

    if (imageFiles.isEmpty && existingImages.isEmpty) {
      SnackbarUtils.show("Error", "Please upload at least one image");
      return;
    }

    isLoading.value = true;

    List<String> imageUrls = existingImages;

    try {
      if (imageFiles.isNotEmpty) {
        final uploaded = await uploadImages(imageFiles);
        imageUrls = [...existingImages, ...uploaded];
      }

      final ref = FirebaseDatabase.instance
          .ref("codebid_database")
          .child("tasks")
          .child(taskId);

      final userref = FirebaseDatabase.instance
          .ref("codebid_database")
          .child("users")
          .child(user!.uid)
          .child("taskCreated")
          .child(taskId);

      await ref.update({
        "taskId": taskId,
        "title": title,
        "description": desc,
        "budget": budget,
        "github": github,
        "images": imageUrls,
        "createdBy": user.uid,
        "lowestBid": budget,
        "timestamp": ServerValue.timestamp,
        "createdAt": DateTime.now().toString(),

        // 🔥 STORE AI DATA
        "aiSuggestion": {
          "budget": aiBudget.value,
          "time": aiTime.value,
          "skills": aiSkills.value,
        },

        "status": "pending",
        "isClosed": task?["isClosed"] ?? false,
      });

      await userref.update({
        "title": title,
        "description": desc,
        "budget": budget,
        "github": github,
        "images": imageUrls,
      });

      taskTitleController.clear();
      descTitleController.clear();
      budgetTitleController.clear();
      githubLinkController.clear();

      imageFiles.clear();
      existingImages.clear();

      Get.find<NavController>().changeIndex(0);
      Get.back();

      SnackbarUtils.show(
        "Success",
        isEdit
            ? "Task updated successfully"
            : "Task created successfully",
      );
    } catch (e) {
      SnackbarUtils.show(
        "Error",
        isEdit
            ? "Failed to update task"
            : "Failed to create task",
      );
    }

    isLoading.value = false;
  }
}