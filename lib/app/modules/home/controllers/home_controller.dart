import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../theme/app_theme.dart';
import '../../../../translations/localization_service.dart';

class HomeController extends GetxController {
  // Life cycle
  @override
  void onInit() {
    WidgetsBinding.instance.addPostFrameCallback(((_) async {
      // do something
    }));
    super.onInit();
  }

  void changeLanguage(String code) {
    LocalizationService.updateLanguage(code);
  }

  void changeTheme() {
    AppTheme.changeTheme();
  }
}
