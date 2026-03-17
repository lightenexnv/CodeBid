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

  File? imageFile;
  final picker = ImagePicker();

  Future imagePicker() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  Future<String> uploadImage(File imageFile) async {
    final url = Uri.parse("https://api.cloudinary.com/v1_1/defl5v5uk/image/upload");
    var request = http.MultipartRequest('POST', url);
    request.fields["upload_preset"] = "CodeBid";
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    var response = await request.send();
    var res = await http.Response.fromStream(response);
    final data = jsonDecode(res.body);
    return data["secure_url"];
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

    String imageUrl = "";

    try {
      if (imageFile != null) {
        imageUrl = await uploadImage(imageFile!);
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
        "image": imageUrl,
        "createdBy": user!.uid,
        "highestBid": 0,
        "timestamp": ServerValue.timestamp
      });

      Get.snackbar("Success", "Task Posted Successfully");
      Get.back();
    } catch (e) {
      SnackbarUtils.show("Error Creating Task", e.toString());
    }
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
                    icon: Icons.attach_money,
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
                    onTap: imagePicker,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F5F7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: imageFile == null
                          ? SizedBox(
                        height: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.camera_alt_outlined),
                            SizedBox(width: 8),
                            Text("Upload Screenshot"),
                          ],
                        ),
                      )
                          : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          imageFile!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.03),
                  GestureDetector(
                    onTap: createTask,
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
                      child: const Center(
                        child: Text(
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