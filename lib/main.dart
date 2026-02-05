import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'app/data/app_shared_pref.dart';
import 'app/modules/home_page.dart';
import 'app/modules/login_screen.dart';
import 'theme/app_theme.dart';
import 'translations/localization_service.dart';
import 'app/services/notification_service.dart';



void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.ring
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.blue
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.blue
    ..textColor = Colors.blue
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..dismissOnTap = false
    ..userInteractions = false;
}

Future<void> main() async {
  // wait for bindings
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // init shared preference
  await AppSharedPref.init();

  // Init local notifications
  await NotificationService.instance.init();
  await NotificationService.instance.requestPermissions();

  // Setup FCM để nhận và hiển thị thông báo khi app đang mở
  await _setupFirebaseMessaging();

  final hasToken =
      AppSharedPref.getToken() != null && AppSharedPref.getToken()!.isNotEmpty;

  runApp(
    ScreenUtilInit(
      // todo add your (Xd / Figma) artboard size
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      rebuildFactor: (old, data) => true,
      builder: (context, widget) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child:  GetMaterialApp(
              title: 'Plannex',
              useInheritedMediaQuery: true,
              debugShowCheckedModeBanner: false,
              supportedLocales: const [Locale('vi', 'VI')],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              localeResolutionCallback: (locale, supportedLocales) {
                for (var supportedLocale in supportedLocales) {
                  if (locale!.countryCode == supportedLocale.countryCode) {
                    return supportedLocale;
                  }
                }
                return locale;
              },
              builder: (context, widget) {
                bool themeIsLight = AppSharedPref.getThemeIsLight();
                widget = Theme(
                  data: AppTheme.getThemeData(isLight: themeIsLight),
                  child: MediaQuery(
                    // prevent font from scaling (some people use big/small device fonts)
                    // but we want our app font to still the same and don't get affected
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: const TextScaler.linear(1.0)),
                    child: widget!,
                  ),
                );
                widget = EasyLoading.init()(context, widget);
                return widget;
              },
              home: hasToken ? const HomePage() : const LoginScreen(),
              locale: const Locale('vi', 'VI'),
              translations: LocalizationService.getInstance(),
            ),
          );
        
      },
    ),
  );

  // Config loading indicator
  configLoading();
}

Future<void> _setupFirebaseMessaging() async {
  final messaging = FirebaseMessaging.instance;

  // Xin quyền hiển thị push (đặc biệt trên iOS / web)
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Nhận message khi app đang mở và show local notification
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    NotificationService.instance.showSimpleNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: notification.title ?? 'Plannex',
      body: notification.body ?? '',
    );
  });
}
