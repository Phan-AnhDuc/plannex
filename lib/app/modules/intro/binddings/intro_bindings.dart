import 'package:get/get.dart';

// Controller
import '../../../components/controller/common_controller.dart';
import '../controllers/intro_controller.dart';

class IntroBindings extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CommonController>()) {
      Get.put(CommonController(), permanent: true);
    }
    Get.lazyPut<IntroController>(
      () => IntroController(),
    );
  }
}

