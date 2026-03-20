import 'dart:convert';
import 'dart:io';

import 'package:codebid/utils/snackbarPopup.dart';
import 'package:codebid/widgets/authtextfields.dart';
import 'package:codebid/widgets/gradientwidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';

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
  final taskTitleController = TextEditingController();
  final descTitleController = TextEditingController();
  final budgetTitleController = TextEditingController();
  final githubLinkController = TextEditingController();

  List<File> imageFiles = [];
  List<String> existingImages = [];

  final picker = ImagePicker();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.isEdit && widget.task != null) {
      taskTitleController.text = widget.task!["title"] ?? "";
      descTitleController.text = widget.task!["description"] ?? "";
      budgetTitleController.text =
          widget.task!["budget"]?.toString() ?? "";
      githubLinkController.text = widget.task!["github"] ?? "";

      existingImages =
      List<String>.from(widget.task!["images"] ?? []);
    }
  }

  Future pickImages() async {
    final picked = await picker.pickMultiImage();

    if (picked.isNotEmpty) {
      if (picked.length > 5) {
        Get.snackbar("Limit", "Max 5 images allowed");
        return;
      }

      setState(() {
        imageFiles = picked.map((e) => File(e.path)).toList();
      });
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

    final taskId = widget.isEdit
        ? widget.task!["taskId"]
        : DateTime.now().millisecondsSinceEpoch.toString();

    if (taskTitleController.text.isEmpty ||
        descTitleController.text.isEmpty ||
        budgetTitleController.text.isEmpty) {
      Get.snackbar("Error", "Please fill all fields");
      return;
    }

    final budget =
        int.tryParse(budgetTitleController.text.trim()) ?? 0;

    setState(() {
      isLoading = true;
    });

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
        "isClosed": widget.task?["isClosed"] ?? false,
      });

      await userref.update({
        "title": taskTitleController.text,
        "description": descTitleController.text,
        "budget": budget,
        "github": githubLinkController.text,
        "images": imageUrls,
      });

      Get.back();
      SnackbarUtils.show(
        "Success",
        widget.isEdit
            ? "Task updated successfully"
            : "Task created successfully",
      );



    } catch (e) {

      SnackbarUtils.show(
        "Error",
        widget.isEdit
            ? "Failed to update task"
            : "Failed to create task",
      );

    }

    setState(() {
      isLoading = false;
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
                  title:
                  widget.isEdit ? "Edit Task" : "Create Task",
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
                    controller: taskTitleController,
                  ),
                  SizedBox(height: height * 0.02),
                  AuthTextField(
                    hint: "Task Description",
                    icon: Icons.document_scanner,
                    controller: descTitleController,
                    maxLines: 4,
                  ),
                  SizedBox(height: height * 0.02),
                  AuthTextField(
                    hint: "Budget",
                    icon: Icons.currency_rupee,
                    controller: budgetTitleController,
                  ),
                  SizedBox(height: height * 0.02),
                  AuthTextField(
                    hint: "GitHub Link",
                    icon: Icons.link,
                    controller: githubLinkController,
                  ),
                  SizedBox(height: height * 0.02),

                  if (existingImages.isNotEmpty)
                    SizedBox(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: existingImages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding:
                            const EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius:
                              BorderRadius.circular(12),
                              child: Image.network(
                                existingImages[index],
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 10),

                  GestureDetector(
                    onTap: pickImages,
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

                  GestureDetector(
                    onTap: isLoading ? null : submitTask,
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
                        child: isLoading
                            ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                            : Text(
                          widget.isEdit
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
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}