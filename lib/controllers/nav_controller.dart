import 'package:get/get.dart';

class NavController extends GetxController{
  var selectedIndex = 0;

  void changeIndex(int index){
    selectedIndex = index;
  }
}