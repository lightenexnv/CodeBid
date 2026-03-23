import 'dart:convert';
import 'dart:io';
import 'package:codebid/controllers/nav_controller.dart';
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

    if (taskTitleController.text.isEmpty ||
        descTitleController.text.isEmpty ||
        budgetTitleController.text.isEmpty) {
      Get.snackbar("Error", "Please fill all fields");
      return;
    }

    final budget =
        int.tryParse(budgetTitleController.text.trim()) ?? 0;

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
        "title": taskTitleController.text,
        "description": descTitleController.text,
        "budget": budget,
        "github": githubLinkController.text,
        "images": imageUrls,
        "createdBy": user.uid,
        "lowestBid": budget,
        "timestamp": ServerValue.timestamp,
        "createdAt": DateTime.now().toString(),
        "status": "pending",
        "isClosed": task?["isClosed"] ?? false,
      });

      await userref.update({
        "title": taskTitleController.text,
        "description": descTitleController.text,
        "budget": budget,
        "github": githubLinkController.text,
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