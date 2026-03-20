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
    int? currentLowest = 0;

    try {
      await ref.child(taskId).runTransaction((currentData) {
        if (currentData == null) return Transaction.abort();

        final data = Map<String, dynamic>.from(currentData as Map);

        final budget =
            int.tryParse(data["budget"]?.toString() ?? "");

        currentLowest =
            int.tryParse(data["lowestBid"]?.toString() ?? "");

        if (enteredBid >= currentLowest!) {
          isValid = false;
          return Transaction.abort();
        }

        data["lowestBid"] = enteredBid;
        data["lowestBidder"] = user.displayName;

        return Transaction.success(data);
      });

      if (!isValid) {
        SnackbarUtils.show(
          "Invalid Bid",
          "Bid must be LOWER than ₹$currentLowest",
        );
        return;
      }

      final bidsRef = ref.child(taskId).child("bids");
      final snapshot = await bidsRef.get();

      String? existingBidKey;

      if (snapshot.exists && snapshot.value != null) {
        final data =
        Map<String, dynamic>.from(snapshot.value as Map);

        data.forEach((bidKey, bidData) {
          final bid = Map<String, dynamic>.from(bidData);
          if (bid["userId"] == user.uid) {
            existingBidKey = bidKey;
          }
        });
      }

      if (existingBidKey != null) {
        await bidsRef.child(existingBidKey!).update({
          "amount": enteredBid,
          "timestamp": DateTime.now().millisecondsSinceEpoch,
          "status": "pending",
        });
      } else {
        await bidsRef.push().set({
          "amount": enteredBid,
          "userId": user.uid,
          "userName": user.displayName ?? "Anonymous",
          "timestamp": DateTime.now().millisecondsSinceEpoch,
          "status": "pending",
        });
      }

      Get.back();
      SnackbarUtils.show("Success", "Bid placed successfully");

    } catch (e) {
      SnackbarUtils.show("Error", e.toString());
    }
  }
}