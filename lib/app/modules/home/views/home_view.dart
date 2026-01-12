import 'package:app_base/translations/strings_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// Controller
import '../../../routes/app_pages.dart';
import '../../home_page.dart';
import '../../home_today.dart';
import '../controllers/home_controller.dart';

var styleText = TextStyle(
  fontSize: 12.sp,
  fontWeight: FontWeight.w600,
  color: Colors.black,
);

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('Home - reender');
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.hello.tr),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  controller.changeLanguage('vi');
                },
                child: const Text('Vi')),
            SizedBox(height: 20.h),
            ElevatedButton(
                onPressed: () {
                  controller.changeLanguage('en');
                },
                child: const Text('EN')),
            SizedBox(height: 20.h),
            ElevatedButton(
                onPressed: () {
                  // controller.changeTheme();
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                },
                child: const Text('Change Theme')),
            ElevatedButton(
                onPressed: () {
                  Get.toNamed(AppPages.INTRO);
                },
                child: const Text('Test')),
          ],
        ),
      ),
    );
  }
}
