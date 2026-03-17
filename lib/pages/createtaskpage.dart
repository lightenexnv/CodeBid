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
  const CreateTaskPage({super.key});

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final taskTitleController = TextEditingController();
  final descTitleController = TextEditingController();
  final budgetTitleController = TextEditingController();
  final githubLinkController = TextEditingController();

  List<File> imageFiles = [];
  final picker = ImagePicker();

  bool isLoading = false;

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

  Future createTask() async {
    final user = FirebaseAuth.instance.currentUser;
    final taskId = DateTime.now().millisecondsSinceEpoch.toString();

    if (taskTitleController.text.isEmpty ||
        descTitleController.text.isEmpty ||
        budgetTitleController.text.isEmpty) {
      Get.snackbar("Error", "Please fill all fields");
      return;
    }

    setState(() {
      isLoading = true;
    });

    List<String> imageUrls = [];

    try {
      if (imageFiles.isNotEmpty) {
        imageUrls = await uploadImages(imageFiles);
      }

      final ref = FirebaseDatabase.instance
          .ref("codebid_database")
          .child("tasks")
          .child(taskId);

      await ref.set({
        "taskId": taskId,
        "title": taskTitleController.text,
        "description": descTitleController.text,
        "budget": budgetTitleController.text,
        "github": githubLinkController.text,
        "images": imageUrls,
        "createdBy": user!.uid,
        "highestBid": 0,
        "timestamp": ServerValue.timestamp
      });

      Get.snackbar("Success", "Task Posted Successfully");
      Get.back();
    } catch (e) {
      SnackbarUtils.show("Error Creating Task", e.toString());
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.sizeOf(context).height;

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
                  title: "Create task",
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
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("in rupees"),
                        ],
                      ),
                    ),
                    controller: budgetTitleController,
                  ),
                  SizedBox(height: height * 0.02),
                  AuthTextField(
                    hint: "GitHub Link",
                    icon: Icons.link,
                    controller: githubLinkController,
                  ),
                  SizedBox(height: height * 0.02),
                  GestureDetector(
                    onTap: pickImages,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F5F7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: imageFiles.isEmpty
                          ? SizedBox(
                        height: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.camera_alt_outlined),
                            SizedBox(width: 8),
                            Text("Upload Screenshots"),
                          ],
                        ),
                      )
                          : SizedBox(
                        height: 90,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: imageFiles.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  imageFiles[index],
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.03),
                  GestureDetector(
                    onTap: isLoading ? null : createTask,
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
                            : const Text(
                          "Post Task",
                          style: TextStyle(
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