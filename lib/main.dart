import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';

import 'app/data/app_shared_pref.dart';
import 'app/data/models/task_models.dart';
import 'app/modules/home_page.dart';
import 'app/modules/login_screen.dart';
import 'app/modules/noti_task_screen.dart';
import 'app/repository/repository.dart';
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

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  // Setup FCM: khi có noti thì mở NotiTaskScreen (app đang mở hoặc mở từ noti)
  await _setupFirebaseMessaging(navigatorKey);

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
              navigatorKey: navigatorKey,
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
                final mode = AppSharedPref.getThemeMode();
                bool themeIsLight = mode == 'light' ||
                    (mode == 'system' &&
                        MediaQuery.of(context).platformBrightness == Brightness.light);
                if (mode == 'dark') themeIsLight = false;
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

Future<void> _setupFirebaseMessaging(GlobalKey<NavigatorState> navigatorKey) async {
  final messaging = FirebaseMessaging.instance;

  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  void _printNotificationData(RemoteMessage message, {String source = 'FCM'}) {
    print('========== $source ==========');
    print('message.data: ${message.data}');
    print('message.notification?.title: ${message.notification?.title}');
    print('message.notification?.body: ${message.notification?.body}');
    print('message.notification?.android: ${message.notification?.android}');
    print('message.messageId: ${message.messageId}');
    print('message.sentTime: ${message.sentTime}');
    print('message.from: ${message.from}');
    print('============================');
  }

  /// Build timeRange string từ startAt + durationMinutes (và date nếu startAt chỉ là giờ).
  String _formatTimeRange(String? startAt, int durationMinutes, String? date) {
    if (startAt == null || startAt.isEmpty) return '8:00 PM - 9:00 PM';
    try {
      DateTime start;
      if (startAt.length <= 8 && startAt.contains(':')) {
        if (date == null || date.isEmpty) return '8:00 PM - 9:00 PM';
        final timeParts = startAt.split(':');
        if (timeParts.length < 2) return '8:00 PM - 9:00 PM';
        final dateParts = date.split('-');
        if (dateParts.length != 3) return '8:00 PM - 9:00 PM';
        start = DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
          timeParts.length > 2 ? int.parse(timeParts[2]) : 0,
        );
      } else {
        String normalized = startAt.trim();
        if (normalized.contains(' ') && !normalized.contains('T')) {
          normalized = normalized.replaceFirst(' ', 'T');
        }
        start = DateTime.parse(normalized);
      }
      final end = start.add(Duration(minutes: durationMinutes));
      final timeFormat = DateFormat('h:mm a');
      return '${timeFormat.format(start)} - ${timeFormat.format(end)}';
    } catch (_) {
      return '8:00 PM - 9:00 PM';
    }
  }

  /// Đợi Navigator sẵn sàng rồi mới push (tránh trường hợp app vừa khởi động, currentState còn null).
  Future<void> _pushNotiTaskWhenNavigatorReady({
    required GlobalKey<NavigatorState> navigatorKey,
    required String taskId,
    required Task task,
    required String timeRange,
    required int startsIn,
  }) async {
    const maxAttempts = 30;
    const delay = Duration(milliseconds: 100);
    for (var i = 0; i < maxAttempts; i++) {
      final state = navigatorKey.currentState;
      if (state != null && state.mounted) {
        state.push(
          MaterialPageRoute(
            builder: (_) => NotiTaskScreen(
              taskId: taskId,
              task: task,
              taskTitle: task.title,
              timeRange: timeRange,
              startsInMinutes: startsIn,
            ),
          ),
        );
        debugPrint('NotiTaskScreen pushed after ${i + 1} attempt(s)');
        return;
      }
      await Future.delayed(delay);
    }
    debugPrint('NotiTaskScreen: navigator not ready after $maxAttempts attempts, skip push');
  }

  Future<void> openNotiTaskScreen(RemoteMessage message) async {
    _printNotificationData(message, source: 'NotiTaskScreen open');

    final data = message.data;
    final taskId = data['task_id']?.toString() ?? data['taskId']?.toString();
    final startsIn = int.tryParse(data['startsInMinutes']?.toString() ?? data['starts_in_minutes']?.toString() ?? '') ?? 15;

    debugPrint('openNotiTaskScreen: taskId=$taskId, startsIn=$startsIn');

    if (taskId == null || taskId.isEmpty) {
      debugPrint('openNotiTaskScreen: no task_id, skip');
      return;
    }

    debugPrint('openNotiTaskScreen: calling getTaskDetail...');
    Task? task;
    try {
      final res = await Api.instance.restClient.getTaskDetail(taskId);
      debugPrint('openNotiTaskScreen: getTaskDetail returned: ${res.runtimeType}');
      if (res is Map<String, dynamic>) {
        task = Task.fromJson(res);
        debugPrint('getTaskDetail -> title: ${task.title}, startAt: ${task.startAt}');
      }
    } catch (e, st) {
      debugPrint('getTaskDetail error: $e');
      debugPrint('getTaskDetail stackTrace: $st');
      return;
    }

    if (task == null) {
      debugPrint('openNotiTaskScreen: could not parse task, skip');
      return;
    }

    final t = task;
    final timeRange = _formatTimeRange(t.startAt, t.durationMinutes, t.date);
    debugPrint('Parsed -> taskId: $taskId, title: ${t.title}, timeRange: $timeRange, startsInMinutes: $startsIn');

    await _pushNotiTaskWhenNavigatorReady(
      navigatorKey: navigatorKey,
      taskId: taskId,
      task: t,
      timeRange: timeRange,
      startsIn: startsIn,
    );
  }

  // App đang mở: nhận FCM → gọi trực tiếp (app đã chạy, navigator sẵn sàng)
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    _printNotificationData(message, source: 'onMessage (app foreground)');
    // Delay nhỏ để đảm bảo stream callback hoàn tất trước
    await Future.delayed(const Duration(milliseconds: 100));
    await openNotiTaskScreen(message);
  });

  // App ở background: user bấm noti → gọi trực tiếp
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    _printNotificationData(message, source: 'onMessageOpenedApp (tap from background)');
    await Future.delayed(const Duration(milliseconds: 100));
    await openNotiTaskScreen(message);
  });

  // App bị tắt: mở app bằng cách bấm noti → đợi lâu hơn cho navigator mount
  final initialMessage = await messaging.getInitialMessage();
  if (initialMessage != null) {
    _printNotificationData(initialMessage, source: 'getInitialMessage (app opened from killed state)');
    // Đợi app build xong rồi mới gọi
    Future.delayed(const Duration(milliseconds: 800), () async {
      await openNotiTaskScreen(initialMessage);
    });
  }
}
