import 'package:get/get.dart';

class SnackbarUtils {

  static void show(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

}