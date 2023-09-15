import 'package:get/get.dart';
import 'package:location/location.dart';

class StateController extends GetxController {
  var isEnableLocation = false.obs;
  var locationData = LocationData.fromMap(<String, dynamic>{}).obs;

  var isLoading = false.obs;
}
