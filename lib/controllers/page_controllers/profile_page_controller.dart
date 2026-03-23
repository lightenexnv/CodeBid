import 'package:codebid/controllers/auth_controller.dart';
import 'package:codebid/pages/welcomepage.dart';
import 'package:codebid/utils/snackbarPopup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

class ProfilePageController extends GetxController {
  final AuthController authController = Get.put(AuthController());

  final user = FirebaseAuth.instance.currentUser;

  final ref = FirebaseDatabase.instance
      .ref("codebid_database")
      .child("users")
      .child(FirebaseAuth.instance.currentUser!.uid);

  final DatabaseReference tasksRef =
  FirebaseDatabase.instance.ref("codebid_database").child("tasks");

  RxString name = "User".obs;
  RxString totalTasks = "0".obs;
  RxString totalBids = "0".obs;
  RxString totalWon = "0".obs;
  RxString role = "".obs;

  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    listenUser();
  }

  void listenUser() {
    ref.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data =
        Map<String, dynamic>.from(event.snapshot.value as Map);

        name.value = data["name"]?.toString() ?? "User";
        role.value = data["role"]?.toString() ?? "requester";

        isLoading.value = false;

        fetchStats();
      }
    });
  }

  void fetchStats() {
    tasksRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data =
        Map<String, dynamic>.from(event.snapshot.value as Map);

        int tasksCount = 0;
        int wonCount = 0;
        int bidsCount = 0;

        data.forEach((taskId, value) {
          final task = Map<String, dynamic>.from(value);

          if (task["createdBy"] == user!.uid) {
            tasksCount++;
          }

          if (role.value == "solver") {
            if (task["bids"] != null) {
              final bids = Map<String, dynamic>.from(task["bids"]);

              bids.forEach((bidId, bidValue) {
                final bid = Map<String, dynamic>.from(bidValue);

                if (bid["userId"] == user!.uid) {
                  bidsCount++;
                }
              });
            }

            if (task["isClosed"] == true &&
                task["lowestBidder"] == name.value) {
              wonCount++;
            }
          }
        });

        totalTasks.value = tasksCount.toString();

        if (role.value == "solver") {
          totalBids.value = bidsCount.toString();
          totalWon.value = wonCount.toString();
        } else {
          totalBids.value = "0";
          totalWon.value = "0";
        }
      }
    });
  }

  Future logout() async {
    try {
      await authController.logout();
      Get.offAll(() => Welcomepage());
    } catch (e) {
      SnackbarUtils.show("Logout Failed", "Something went wrong");
    }
  }
}