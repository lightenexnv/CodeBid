import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

class TasksPageController extends GetxController {
  final user = FirebaseAuth.instance.currentUser;

  late final ref = FirebaseDatabase.instance
      .ref("codebid_database")
      .child("users")
      .child(user!.uid)
      .child("taskCreated");

  RxList<Map<String, dynamic>> tasks = <Map<String, dynamic>>[].obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    listenTasks();
  }

  void listenTasks() {
    ref.onValue.listen((event) {
      if (event.snapshot.value == null) {
        tasks.clear();
        isLoading.value = false;
        return;
      }

      final data =
      Map<String, dynamic>.from(event.snapshot.value as Map);

      List<Map<String, dynamic>> temp = [];

      data.forEach((key, value) {
        final task = Map<String, dynamic>.from(value);
        temp.add(task);
      });

      tasks.value = temp;
      isLoading.value = false;
    });
  }
}