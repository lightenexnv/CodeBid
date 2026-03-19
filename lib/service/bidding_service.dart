import 'package:codebid/utils/snackbarPopup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

class BidService {
  static final ref = FirebaseDatabase.instance
      .ref("codebid_database")
      .child("tasks");

  static Future<void> placeBid({
    required Map task,
    required String bidText,
  }) async {
    final enteredBid = int.tryParse(bidText.trim());

    if (enteredBid == null) {
      SnackbarUtils.show("Error", "Enter a valid bid amount");
      return;
    }

    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      SnackbarUtils.show("Error", "User not logged in");
      return;
    }

    final taskId = task["taskId"];

    if (taskId == null) {
      SnackbarUtils.show("Error", "Task ID missing");
      return;
    }

    bool isValid = true;
    int currentLowest = 0;

    try {
      await ref.child(taskId).runTransaction((currentData) {
        if (currentData == null) return Transaction.abort();

        final data = Map<String, dynamic>.from(currentData as Map);

        final budget =
            int.tryParse(data["budget"]?.toString() ?? "") ?? 0;

        currentLowest =
            int.tryParse(data["lowestBid"]?.toString() ?? "") ?? budget;

        if (enteredBid >= currentLowest) {
          isValid = false;
          return Transaction.abort();
        }

        data["lowestBid"] = enteredBid;
        data["lowestBidder"] = user.uid;

        return Transaction.success(data);
      });

      if (!isValid) {
        SnackbarUtils.show(
          "Invalid Bid",
          "Bid must be LOWER than ₹$currentLowest",
        );
        return;
      }

      await ref.child(taskId).child("bids").push().set({
        "amount": enteredBid,
        "userId": user.uid,
        "userName": user.displayName ?? "Anonymous",
        "timestamp": DateTime.now().millisecondsSinceEpoch,
      });
      Get.back();
      SnackbarUtils.show("Success", "Bid placed successfully");

    } catch (e) {
      SnackbarUtils.show("Error", e.toString());
    }
  }
}