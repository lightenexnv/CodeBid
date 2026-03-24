import 'dart:io';
import 'package:codebid/controllers/add_bio_controller.dart';
import 'package:codebid/controllers/profileimagecontroller.dart';
import 'package:codebid/utils/snackbarPopup.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  final ProfileImageController imageController =
  Get.put(ProfileImageController());

  final UserProfileController bioControllerX =
  Get.put(UserProfileController());

  final TextEditingController bioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: Stack(
        children: [
          Container(
            height: height * 0.4,
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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.white),
                        ),
                        const Text(
                          "Settings",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Obx(() => CircleAvatar(
                    radius: 50,
                    backgroundImage:
                    imageController.image.value != null
                        ? FileImage(
                        imageController.image.value!)
                        : (imageController
                        .profileImage.value.isNotEmpty
                        ? NetworkImage(imageController
                        .profileImage.value)
                        : const AssetImage(
                      "assets/icons/default-profile.png",
                    )),
                  )),
                  const SizedBox(height: 10),
                  Obx(() => ElevatedButton(
                    onPressed: imageController.isLoading.value
                        ? null
                        : imageController.pickImage,
                    child: imageController.isLoading.value
                        ? const CircularProgressIndicator(
                        color: Colors.white)
                        : const Text("Change Photo"),
                  )),
                  const SizedBox(height: 30),
                  Container(
                    width: width * 0.95,
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF4F6FB),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        Obx(() {
                          bioController.text = bioControllerX.bio.value;

                          return TextField(
                            controller: bioController,
                            minLines: 5,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                              hintText: "Add your bio...",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () async {
                            await bioControllerX
                                .updateBio(bioController.text.trim());
                            Get.back();
                            SnackbarUtils.show(
                                "Saved", "Profile updated successfully");
                          },
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF2DD4BF),
                                  Color(0xFF1FA2FF),
                                ],
                              ),
                              borderRadius:
                              BorderRadius.circular(15),
                            ),
                            child: const Center(
                              child: Text(
                                "Save Changes",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}