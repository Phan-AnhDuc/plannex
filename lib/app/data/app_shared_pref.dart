import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../translations/localization_service.dart';

class AppSharedPref {
  // prevent making instance
  AppSharedPref._();

  // get storage
  static late SharedPreferences _sharedPreferences;

  // STORING KEYS
  static const String _fcmTokenKey = 'fcm_token';
  static const String _currentLocalKey = 'current_local';
  static const String _lightThemeKey = 'is_theme_light';
  static const String _themeModeKey = 'theme_mode'; // 'light' | 'dark' | 'system'
  static const String _userProfile = 'user_profile';
  static const String _userUsingStatus = 'user_using_status';
  static const String _autoLogin = 'auto_login';
  static const String _missionType = 'mission_type';
  static const String _jobType = 'job_type';
  static const String _eventType = 'event_type';
  static const String _disableDueToWarningMission = 'disable_due_to_warning_mission';
  static const String _username = 'username';

  // Auth & intro keys (migrated from PrefUtils)
  static const String _tokenKey = 'token';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _introKey = 'intro';

  /// init get storage services
  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  static setStorage(SharedPreferences sharedPreferences) {
    _sharedPreferences = sharedPreferences;
  }

  /// set theme current type as light theme
  static Future<void> setThemeIsLight(bool lightTheme) =>
      _sharedPreferences.setBool(_lightThemeKey, lightTheme);

  /// get if the current theme type is light
  static bool getThemeIsLight() =>
      _sharedPreferences.getBool(_lightThemeKey) ??
      true;

  /// theme mode: 'light' | 'dark' | 'system'
  static Future<void> setThemeMode(String mode) =>
      _sharedPreferences.setString(_themeModeKey, mode);

  static String getThemeMode() =>
      _sharedPreferences.getString(_themeModeKey) ?? 'light';

  /// save current locale
  static Future<void> setCurrentLanguage(String languageCode) =>
      _sharedPreferences.setString(_currentLocalKey, languageCode);

  /// get current locale
  static Locale getCurrentLocal() {
    String? langCode = _sharedPreferences.getString(_currentLocalKey);
    // default language is english
    if (langCode == null) {
      return LocalizationService.defaultLanguage;
    }
    return LocalizationService.supportedLanguages[langCode]!;
  }

  /// save generated fcm token
  static Future<void> setFcmToken(String token) =>
      _sharedPreferences.setString(_fcmTokenKey, token);

  /// get generated fcm token
  static String? getFcmToken() => _sharedPreferences.getString(_fcmTokenKey);

  /// save user profile
  static Future<void> setUserProfile(Map profile) =>
      _sharedPreferences.setString(_userProfile, jsonEncode(profile));

  /// get user profile
  static Map? getUserProfile() =>
      jsonDecode(_sharedPreferences.getString(_userProfile)!);

  /// save user using status
  static Future<void> setUserUsingStatus(Map userUsingStatus) =>
      _sharedPreferences.setString(
          _userUsingStatus, jsonEncode(userUsingStatus));

  /// get user profile
  static Map? getUserUsingStatus() =>
      jsonDecode(_sharedPreferences.getString(_userUsingStatus)!);

  /// save auto-login state
  static Future<void> setAutoLoginState(bool isAutoLogin) =>
      _sharedPreferences.setString(_autoLogin, isAutoLogin ? '1' : '0');

  /// get auto-login state
  static String? getAutoLoginState() =>
      _sharedPreferences.getString(_autoLogin);

  static Future<void> setMissionType(String missionType) =>
      _sharedPreferences.setString(_missionType, missionType);

  static String? getMissionType() => _sharedPreferences.getString(_missionType);

  static Future<void> setJobType(String jobType) =>
      _sharedPreferences.setString(_jobType, jobType);

  static String? getJobType() => _sharedPreferences.getString(_jobType);

  static Future<void> setEventType(String eventType) =>
      _sharedPreferences.setString(_eventType, eventType);

  static String? getEventType() => _sharedPreferences.getString(_eventType);

  /// save disable-due-to-warning-mission state
  static Future<void> setDisableDueToWarningMissionState(bool isDisable) =>
      _sharedPreferences.setString(
          _disableDueToWarningMission, isDisable ? '1' : '0');

  /// get disable-due-to-warning-mission state
  static String? getDisableDueToWarningMissionState() =>
      _sharedPreferences.getString(_disableDueToWarningMission);

  /// save username
  static Future<void> setUsername(String username) =>
      _sharedPreferences.setString(_username, username);

  static String? getUsername() => _sharedPreferences.getString(_username);

  /// clear all data from shared pref
  static Future<void> clear() async {
    await _sharedPreferences.clear();
  }

  // ===== Auth & intro helpers =====

  static Future<void> setToken(String token) async {
    await _sharedPreferences.setString(_tokenKey, token);
  }

  static String? getToken() {
    return _sharedPreferences.getString(_tokenKey);
  }

  static Future<void> setRefreshToken(String token) async {
    await _sharedPreferences.setString(_refreshTokenKey, token);
  }

  static String? getRefreshToken() {
    return _sharedPreferences.getString(_refreshTokenKey);
  }

  static Future<void> setIntroSeen(bool isSeen) async {
    await _sharedPreferences.setBool(_introKey, isSeen);
  }

  static bool getIntroSeen() {
    return _sharedPreferences.getBool(_introKey) ?? false;
  }
}
