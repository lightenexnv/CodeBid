import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

class TasksAllBidsController extends GetxController {
  final String taskId;
  final String createdBy;

  TasksAllBidsController({
    required this.taskId,
    required this.createdBy,
  });

  final user = FirebaseAuth.instance.currentUser;

  late final bidsRef = FirebaseDatabase.instance
      .ref("codebid_database")
      .child("tasks")
      .child(taskId)
      .child("bids");

  RxList<Map<String, dynamic>> bids = <Map<String, dynamic>>[].obs;
  RxBool isLoading = true.obs;
  RxBool isTaskOwner = false.obs;

  @override
  void onInit() {
    super.onInit();
    isTaskOwner.value = user?.uid == createdBy;
    listenBids();
  }

  void listenBids() {
    bidsRef.onValue.listen((event) {
      if (event.snapshot.value == null) {
        bids.clear();
        isLoading.value = false;
        return;
      }

      final data =
      Map<String, dynamic>.from(event.snapshot.value as Map);

      List<Map<String, dynamic>> temp = [];

      data.forEach((key, value) {
        final bid = Map<String, dynamic>.from(value);
        temp.add({
          ...bid,
          "bidId": key,
        });
      });

      bids.value = temp;
      isLoading.value = false;
    });
  }

  Future acceptBid(String bidId) async {
    final snapshot = await bidsRef.get();

    final taskRef = FirebaseDatabase.instance
        .ref("codebid_database")
        .child("tasks")
        .child(taskId);

    await bidsRef.child(bidId).update({
      "status": "accepted"
    });

    await taskRef.update({
      "isClosed": true,
    });

    for (var child in snapshot.children) {
      if (child.key != bidId) {
        bidsRef.child(child.key!).update({
          "status": "declined"
        });
      }
    }
  }

  Future declineBid(String bidId) async {
    await bidsRef.child(bidId).update({
      "status": "declined"
    });
  }
}