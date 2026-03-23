import 'dart:convert';
import 'dart:io';

import 'package:codebid/utils/snackbarPopup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class SettingsController extends GetxController {
  final nameController = TextEditingController();

  RxString role = "requester".obs;
  Rx<File?> imageFile = Rx<File?>(null);
  RxString existingImageUrl = "".obs;

  RxBool isLoading = false.obs;
  final picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseDatabase.instance
        .ref("codebid_database")
        .child("users")
        .child(user.uid);

    final snapshot = await ref.get();

    if (snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);

      nameController.text = data["name"] ?? "";
      role.value = data["role"] ?? "requester";
      existingImageUrl.value = data["profileImageUrl"] ?? "";
    }
  }

  void setRole(String newRole) {
    role.value = newRole;
  }

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      imageFile.value = File(picked.path);
    }
  }

  Future<String?> uploadImage(File file) async {
    try {
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

      return data["secure_url"];
    } catch (e) {
      return null;
    }
  }

  Future<void> saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Get.snackbar("Error", "User not logged in");
      return;
    }

    if (nameController.text.trim().isEmpty) {
      Get.snackbar("Error", "Name cannot be empty");
      return;
    }

    isLoading.value = true;

    try {
      String finalImageUrl = existingImageUrl.value;

      if (imageFile.value != null) {
        final uploaded = await uploadImage(imageFile.value!);
        if (uploaded != null) {
          finalImageUrl = uploaded;
        } else {
          SnackbarUtils.show("Warning", "Image upload failed");
        }
      }

      await user.updateDisplayName(nameController.text.trim());

      final ref = FirebaseDatabase.instance
          .ref("codebid_database")
          .child("users")
          .child(user.uid);

      final updateData = {
        "name": nameController.text.trim(),
        "role": role.value,
        "profileImageUrl": finalImageUrl,
      };

      await ref.update(updateData);

      SnackbarUtils.show("Success", "Profile updated");

      Get.back();
    } catch (e) {
      SnackbarUtils.show("Error", "Failed to update profile");
    }

    isLoading.value = false;
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}