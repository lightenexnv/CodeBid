import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

class MainNavigationController extends GetxController {
  final user = FirebaseAuth.instance.currentUser;

  final userRef = FirebaseDatabase.instance
      .ref("codebid_database")
      .child("users")
      .child(FirebaseAuth.instance.currentUser!.uid);

  RxString role = "".obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    listenUser();
  }

  void listenUser() {
    userRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data =
        Map<String, dynamic>.from(event.snapshot.value as Map);

        role.value = data["role"] ?? "";
        isLoading.value = false;
      }
    });
  }
}