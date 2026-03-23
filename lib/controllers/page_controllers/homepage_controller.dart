import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

class HomepageController extends GetxController {
  final ref =
  FirebaseDatabase.instance.ref("codebid_database").child("tasks");

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

      final raw = Map<String, dynamic>.from(
        event.snapshot.value as Map,
      );

      List<Map<String, dynamic>> temp = [];

      raw.forEach((key, value) {
        final task = Map<String, dynamic>.from(value);

        final createdAt = task["createdAt"];

        int timestamp = 0;

        if (createdAt is int) {
          timestamp = createdAt;
        } else if (createdAt is String && createdAt.isNotEmpty) {
          try {
            final parsed = DateTime.parse(createdAt);
            timestamp = parsed.millisecondsSinceEpoch;
          } catch (e) {
            timestamp = 0;
          }
        }

        if (timestamp != 0) {
          temp.add({
            ...task,
            "timestamp": timestamp,
          });
        }
      });

      tasks.value = temp;
      isLoading.value = false;
    });
  }
}