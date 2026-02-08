/// Response từ API GET /users/me
class UserMeResponse {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isAnonymous;
  final String? createdAt;
  final String? lastLoginAt;
  final UserSettings? settings;
  final bool premium;
  final int expiryTimeMillis;
  final String? subscriptionStatus;
  final dynamic plan;

  UserMeResponse({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.isAnonymous = false,
    this.createdAt,
    this.lastLoginAt,
    this.settings,
    this.premium = false,
    this.expiryTimeMillis = 0,
    this.subscriptionStatus,
    this.plan,
  });

  factory UserMeResponse.fromJson(Map<String, dynamic> json) {
    return UserMeResponse(
      uid: json['uid'] as String? ?? '',
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      createdAt: json['createdAt'] as String?,
      lastLoginAt: json['lastLoginAt'] as String?,
      settings: json['settings'] != null
          ? UserSettings.fromJson(json['settings'] as Map<String, dynamic>)
          : null,
      premium: json['premium'] as bool? ?? false,
      expiryTimeMillis: json['expiry_time_millis'] as int? ?? 0,
      subscriptionStatus: json['subscription_status'] as String?,
      plan: json['plan'],
    );
  }
}

/// settings trong response users/me
class UserSettings {
  final String timezone;
  final int defaultDurationMinutes;
  final int defaultReminderOffsetMinutes;
  final String workingHoursStart;
  final String workingHoursEnd;

  UserSettings({
    this.timezone = 'Asia/Ho_Chi_Minh',
    this.defaultDurationMinutes = 30,
    this.defaultReminderOffsetMinutes = 15,
    this.workingHoursStart = '09:00',
    this.workingHoursEnd = '17:00',
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      timezone: json['timezone'] as String? ?? 'Asia/Ho_Chi_Minh',
      defaultDurationMinutes: json['defaultDurationMinutes'] as int? ?? 30,
      defaultReminderOffsetMinutes:
          json['defaultReminderOffsetMinutes'] as int? ?? 15,
      workingHoursStart: json['workingHoursStart'] as String? ?? '09:00',
      workingHoursEnd: json['workingHoursEnd'] as String? ?? '17:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timezone': timezone,
      'defaultDurationMinutes': defaultDurationMinutes,
      'defaultReminderOffsetMinutes': defaultReminderOffsetMinutes,
      'workingHoursStart': workingHoursStart,
      'workingHoursEnd': workingHoursEnd,
    };
  }
}
