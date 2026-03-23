import 'package:codebid/service/bidding_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlaceBidPageController extends GetxController {
  final Map task;

  PlaceBidPageController({required this.task});

  final bidController = TextEditingController();

  final ref =
  FirebaseDatabase.instance.ref("codebid_database").child("tasks");

  RxInt lowestBid = 0.obs;
  RxInt budget = 0.obs;
  RxBool isTaskClosed = false.obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    listenTask();
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

  Future placeBid() async {
    if (bidController.text.isEmpty) {
      Get.snackbar("Error", "Enter bid amount");
      return;
    }

    if (int.tryParse(bidController.text) == null) {
      Get.snackbar("Error", "Invalid bid amount");
      return;
    }

    if (int.parse(bidController.text) >= lowestBid.value) {
      Get.snackbar(
          "Error", "Bid must be lower than current lowest bid");
      return;
    }

    await BidService.placeBid(
      task: task,
      bidText: bidController.text,
    );
  }
}