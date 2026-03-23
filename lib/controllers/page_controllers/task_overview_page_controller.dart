import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

class TaskOverviewPageController extends GetxController {
  final Map task;

  TaskOverviewPageController({required this.task});

  final ref =
  FirebaseDatabase.instance.ref("codebid_database").child("tasks");

  final userRef = FirebaseDatabase.instance
      .ref("codebid_database")
      .child("users")
      .child(FirebaseAuth.instance.currentUser!.uid);

  RxInt lowestBid = 0.obs;
  RxInt budget = 0.obs;
  RxBool isTaskClosed = false.obs;
  RxString role = "".obs;
  RxBool isOwner = false.obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    isOwner.value =
        FirebaseAuth.instance.currentUser?.uid == task["createdBy"];
    listenTask();
    listenUser();
  }

  void listenTask() {
    ref.child(task["taskId"]).onValue.listen((event) {
      if (event.snapshot.value == null) {
        isLoading.value = false;
        return;
      }

      final data =
      Map<String, dynamic>.from(event.snapshot.value as Map);

      budget.value =
          int.tryParse(data["budget"]?.toString() ?? "") ?? 0;

      lowestBid.value =
          int.tryParse(data["lowestBid"]?.toString() ?? "") ??
              budget.value;

      isTaskClosed.value = data["isClosed"] == true;

      isLoading.value = false;
    });
  }

  void listenUser() {
    userRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data =
        Map<String, dynamic>.from(event.snapshot.value as Map);
        role.value = data["role"] ?? "";
      }
    });
  }
}