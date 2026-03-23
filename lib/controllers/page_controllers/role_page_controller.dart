import 'package:codebid/pages/main_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

class RolePageController extends GetxController {
  final user = FirebaseAuth.instance.currentUser;

  RxBool isLoading = false.obs;

  Future<void> saveRole(String role) async {
    if (user == null) return;

    try {
      isLoading.value = true;

      final ref = FirebaseDatabase.instance
          .ref("codebid_database")
          .child("users")
          .child(user!.uid);

      await ref.update({
        "role": role,
      });

      Get.offAll(() => MainNavigation()); 
    } catch (e) {
      Get.snackbar("Error", "Failed to save role");
    }

    isLoading.value = false;
  }
}