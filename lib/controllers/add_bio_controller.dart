import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

class UserProfileController extends GetxController {

  final user = FirebaseAuth.instance.currentUser;

  final userRef = FirebaseDatabase.instance
      .ref("codebid_database")
      .child("users");

  RxString bio = "".obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadBio();
  }

  void loadBio() async {
    if (user == null) return;

    final snapshot = await userRef.child(user!.uid).get();

    if (snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      bio.value = data["bio"] ?? "";
    }
  }

  Future<void> updateBio(String newBio) async {
    if (user == null) return;

    isLoading.value = true;

    await userRef.child(user!.uid).update({
      "bio": newBio,
    });

    bio.value = newBio;

    isLoading.value = false;
  }
}