import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

class AllTasksBidPageController extends GetxController {
  final user = FirebaseAuth.instance.currentUser;

  final tasksRef =
  FirebaseDatabase.instance.ref("codebid_database").child("tasks");

  final userRef = FirebaseDatabase.instance
      .ref("codebid_database")
      .child("users")
      .child(FirebaseAuth.instance.currentUser!.uid);

  RxString role = "".obs;
  RxList<Map<String, dynamic>> tasksList = <Map<String, dynamic>>[].obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    listenUser();
    listenTasks();
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

  void listenTasks() {
    tasksRef.onValue.listen((event) {
      if (event.snapshot.value == null) {
        tasksList.clear();
        isLoading.value = false;
        return;
      }

      final raw = event.snapshot.value as Map;

      final data = raw.map(
            (key, value) => MapEntry(
          key.toString(),
          Map<String, dynamic>.from(value as Map),
        ),
      );

      List<Map<String, dynamic>> tempList = [];

      data.forEach((taskId, task) {
        if (role.value == "requester") {
          if (task["createdBy"] == user!.uid) {
            tempList.add({
              ...task,
              "taskId": taskId,
            });
          }
        } else {
          final bids = task["bids"];

          if (bids != null) {
            final bidsMap = Map<String, dynamic>.from(bids);

            for (var bid in bidsMap.values) {
              final bidData = Map<String, dynamic>.from(bid);

              if (bidData["userId"] == user!.uid) {
                tempList.add({
                  ...task,
                  "taskId": taskId,
                });
                break;
              }
            }
          }
        }
      });

      tasksList.value = tempList;
      isLoading.value = false;
    });
  }
}