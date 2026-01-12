import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../view/intro_2_screen.dart';

class IntroController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  // Life cycle
  @override
  void onInit() {
    WidgetsBinding.instance.addPostFrameCallback(((_) async {
      // do something
    }));
    super.onInit();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value < 2) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to next screen (e.g., login or home)
      // Get.offNamed(Routes.LOGIN);
    }
  }

  void skipIntro() {
    // Navigate to next screen
    // Get.offNamed(Routes.LOGIN);
  }

  void onGetStarted(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Intro2Screen()));
    // Navigate to main screen
    // Get.offNamed(Routes.MAIN);
  }
}

