import 'dart:io';
import 'package:codebid/controllers/profileimagecontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  final ProfileImageController controller = Get.put(ProfileImageController());

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: Stack(
        children: [
          Container(
            height: height * 0.3,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF2DD4BF),
                  Color(0xFF1FA2FF),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  Obx(() => CircleAvatar(
                    radius: 50,
                    backgroundImage: controller.image.value != null
                        ? FileImage(controller.image.value!)
                        : (controller.profileImage.value.isNotEmpty
                        ? NetworkImage(controller.profileImage.value)
                        : const NetworkImage(
                      "https://i.pravatar.cc/200",
                    )) as ImageProvider,
                  )),

                  const SizedBox(height: 10),

                  Obx(() => ElevatedButton(
                    onPressed:
                    controller.isLoading.value ? null : controller.pickImage,
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator()
                        : const Text("Change Photo"),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}