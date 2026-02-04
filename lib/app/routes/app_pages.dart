// ignore_for_file: constant_identifier_names
import 'package:get/get.dart';

import '../modules/intro/binddings/intro_bindings.dart';
import '../modules/intro/view/intro_screen.dart';
part 'app_routes.dart';

class AppPages {
  AppPages._();
  static const INTRO = _Paths.INTRO;

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.INTRO,
      page: () => const IntroScreen(),
      binding: IntroBindings(),
    ),
  ];
}
