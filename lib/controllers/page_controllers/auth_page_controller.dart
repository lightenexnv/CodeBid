import 'package:get/get.dart';

class AuthScreenControllers extends GetxController{

  RxBool isObscure = true.obs;

  void toggleObscure(){
    isObscure.value = !isObscure.value;
  }


}