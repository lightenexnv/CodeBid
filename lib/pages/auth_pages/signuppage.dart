import 'package:codebid/controllers/auth_controller.dart';
import 'package:codebid/controllers/page_controllers/auth_page_controller.dart';
import 'package:codebid/pages/auth_pages/loginpage.dart';
import 'package:codebid/pages/main_navigation.dart';
import 'package:codebid/pages/rolepage.dart';
import 'package:codebid/utils/snackbarPopup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:codebid/widgets/gradientwidget.dart';
import 'package:codebid/widgets/authtextfields.dart';
import 'package:get/get.dart';

class Signuppage extends StatelessWidget {
  Signuppage({super.key});

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final controller = AuthController();
  final AuthScreenControllers authcontroller = Get.put(AuthScreenControllers());

  Future<void> checkUserRole() async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final ref = FirebaseDatabase.instance
        .ref("codebid_database")
        .child("users")
        .child(user.uid);

    final snapshot = await ref.get();

    if (snapshot.exists) {

      final data = snapshot.value as Map;

      if (data["role"] != null) {
        Get.offAll(() => MainNavigation());
        return;
      }
    }

    Get.offAll(() => Rolepage());
  }

  void signup() async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        confirmController.text.trim().isEmpty) {
      Get.snackbar("Error", "Fill all fields");
      return;
    }

    if (passwordController.text != confirmController.text) {
      Get.snackbar("Error", "Passwords do not match");
      return;
    }

    try {
      final user = await controller.register(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (user != null) {
        await user.updateDisplayName(nameController.text.trim());

        final userRef = FirebaseDatabase.instance
            .ref("codebid_database")
            .child("users")
            .child(user.uid);

        await userRef.set({
          "uid": user.uid,
          "name": nameController.text.trim(),
          "email": emailController.text.trim(),
          "role": null,
          "createdAt": ServerValue.timestamp,
        });

        checkUserRole();
      }
    } catch (e) {
      SnackbarUtils.show("SignUp Failed", e.toString());
    }
  }

  void signInWithGoogle() async {
    try {
      final user = await controller.signInWithGoogle();

      if (user != null) {
        final userRef = FirebaseDatabase.instance
            .ref("codebid_database")
            .child("users")
            .child(user.uid);

        final snapshot = await userRef.get();

        if (!snapshot.exists) {
          await userRef.set({
            "uid": user.uid,
            "name": user.displayName ?? "User",
            "email": user.email ?? "",
            "role": null,
            "createdAt": DateTime.now().toString(),
          });
        }

        checkUserRole();
      }
    } catch (e) {
      SnackbarUtils.show("Google Login Failed", e.toString());
    }
  }

  void signInWithGithub() async {
    try {
      final user = await controller.signInWithGithub();

      if (user != null) {
        final userRef = FirebaseDatabase.instance
            .ref("codebid_database")
            .child("users")
            .child(user.uid);

        final snapshot = await userRef.get();

        if (!snapshot.exists) {
          await userRef.set({
            "uid": user.uid,
            "name": user.displayName ?? "User",
            "email": user.email ?? "",
            "role": null,
            "createdAt": ServerValue.timestamp,
          });
        }

        checkUserRole();
      }
    } catch (e) {
      SnackbarUtils.show("GitHub Login Failed", e.toString());
    }
  }

  Future userDetailsPush()async{
    final user = FirebaseAuth.instance.currentUser;

    final userDetailref = FirebaseDatabase.instance.
    ref("codebid_database").
    child("users").child("${user!.uid}");

    await userDetailref.set({
      "userfullname": user.displayName
    });
}

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.sizeOf(context).height;
    final double width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Hero(
                tag: "gradientHero",
                child: Material(
                  color: Colors.transparent,
                  child: GradientHeader(
                    title: "Sign Up",
                    boxheight: 0.28,
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Container(
                width: width * 0.9,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AuthTextField(
                      hint: "Full Name",
                      icon: Icons.person_outline,
                      controller: nameController,
                    ),
                    SizedBox(height: height * 0.02),
                    AuthTextField(
                      hint: "Email",
                      icon: Icons.email_outlined,
                      controller: emailController,
                    ),
                    SizedBox(height: height * 0.02),
                    Obx(() => AuthTextField(
                      hint: "Password",
                      icon: Icons.lock_outline,
                      controller: passwordController,
                      obscure: authcontroller.isObscure.value,
                      suffixIcon: IconButton(
                        icon: Icon(
                          authcontroller.isObscure.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: authcontroller.toggleObscure,
                      ),
                    ),),
                    SizedBox(height: height * 0.02),

                    Obx(() => AuthTextField(
                      hint: "Confirm Password",
                      icon: Icons.lock_outline,
                      controller: confirmController,
                      obscure: authcontroller.isObscure.value,
                      suffixIcon: IconButton(
                        icon: Icon(
                          authcontroller.isObscure.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: authcontroller.toggleObscure,
                      ),
                    )),
                    SizedBox(height: height * 0.03),
                    InkWell(
                      onTap: signup,
                      child: Hero(
                        tag: "hero-button",
                        child: Material(
                          child: Container(
                            height: height * 0.065,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF2DD4BF),
                                  Color(0xFF1FA2FF),
                                ],
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                "Create Account",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.025),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            color: Colors.grey.shade300,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "OR",
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: signInWithGoogle,
                          child: Container(
                            height: 48,
                            width: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                              color: Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/icons/google.png",
                                  height: 22,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "Google",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        GestureDetector(
                          onTap: signInWithGithub,
                          child: Container(
                            height: 48,
                            width: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.black,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/icons/github.png",
                                  height: 22,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "GitHub",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? "),
                        InkWell(
                          onTap: () {
                            Get.off(() => Loginpage());
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1FA2FF),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}