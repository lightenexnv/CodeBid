import 'dart:convert';
import 'dart:io';
import 'package:codebid/utils/snackbarPopup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ProfileImageController extends GetxController {
  final picker = ImagePicker();

  Rx<File?> image = Rx<File?>(null);
  RxString profileImage = "".obs;
  RxBool isLoading = false.obs;

  final user = FirebaseAuth.instance.currentUser;

  @override
  void onInit() {
    super.onInit();
    listenProfile();
  }

  void listenProfile() {
    FirebaseDatabase.instance
        .ref("codebid_database")
        .child("users")
        .child(user!.uid)
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        profileImage.value = data["profileImage"] ?? "";
      }
    });
  }

  Future pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);
      image.value = file;
      await uploadProfileImage(file);
    }
  }

  Future<String?> uploadToCloudinary(File file) async {
    try {
      final url = Uri.parse(
          "https://api.cloudinary.com/v1_1/defl5v5uk/image/upload");

      var request = http.MultipartRequest('POST', url);
      request.fields["upload_preset"] = "CodeBid";

      request.files.add(
        await http.MultipartFile.fromPath('file', file.path),
      );

      var response = await request.send();
      var res = await http.Response.fromStream(response);

      final data = jsonDecode(res.body);
      return data["secure_url"];
    } catch (e) {
      SnackbarUtils.show("Error", "Upload failed");
      return null;
    }
  }

  Future uploadProfileImage(File file) async {
    isLoading.value = true;

    final imageUrl = await uploadToCloudinary(file);

    if (imageUrl == null) {
      isLoading.value = false;
      return;
    }

    await FirebaseDatabase.instance
        .ref("codebid_database")
        .child("users")
        .child(user!.uid)
        .update({
      "profileImage": imageUrl,
    });

    isLoading.value = false;

    SnackbarUtils.show("Success", "Profile updated");
  }
}