import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Theme
import '../../theme/app_fonts.dart';
import '../../theme/app_styles.dart';
import '../../app/data/app_shared_pref.dart';

/// Base text component for the entire app
/// Supports predefined text styles from theme and custom styling
class AppText extends StatelessWidget {
  final String text;
  final AppTextType? textType;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? height;
  final double? letterSpacing;
  final TextStyle? style;
  final bool? softWrap;
  final TextDecoration? decoration;

  const AppText(
    this.text, {
    super.key,
    this.textType,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.height,
    this.letterSpacing,
    this.style,
    this.softWrap,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final isLightTheme = AppSharedPref.getThemeIsLight();
    final textTheme = AppStyles.getTextTheme(isLightTheme: isLightTheme);

    TextStyle baseStyle;

    // Use predefined text type if provided
    if (textType != null) {
      baseStyle = _getTextStyleFromType(textType!, textTheme);
    } else {
      // Default to body text style
      baseStyle = textTheme.bodyMedium ?? const TextStyle();
    }

    // Apply custom style if provided
    if (style != null) {
      baseStyle = baseStyle.merge(style);
    }

    // Apply individual overrides
    baseStyle = baseStyle.copyWith(
      fontSize: fontSize?.sp ?? baseStyle.fontSize,
      fontWeight: fontWeight ?? baseStyle.fontWeight,
      color: color ?? baseStyle.color,
      height: height ?? baseStyle.height,
      letterSpacing: letterSpacing ?? baseStyle.letterSpacing,
      decoration: decoration ?? baseStyle.decoration,
    );

    return Text(
      text,
      style: baseStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }

  TextStyle _getTextStyleFromType(AppTextType type, TextTheme textTheme) {
    switch (type) {
      case AppTextType.s50w7:
        return textTheme.displayLarge ?? const TextStyle();
      case AppTextType.s40w7:
        return textTheme.displayMedium ?? const TextStyle();
      case AppTextType.s30w7:
        return textTheme.displaySmall ?? const TextStyle();
      case AppTextType.s25w7:
        return textTheme.headlineMedium ?? const TextStyle();
      case AppTextType.s20w7:
        return textTheme.headlineSmall ?? const TextStyle();
      case AppTextType.s17w7:
        return textTheme.titleLarge ?? const TextStyle();
      case AppTextType.s16w4:
        return textTheme.bodyLarge ?? const TextStyle();
      case AppTextType.s14w4:
        return textTheme.bodyMedium ?? const TextStyle();
      case AppTextType.s13w4:
        return textTheme.bodySmall ?? const TextStyle();
      case AppTextType.s16w7:
        return textTheme.labelLarge ?? const TextStyle();
      case AppTextType.custom:
        return AppFonts.bodyTextStyle;
    }
  }
}

/// Enum for predefined text types
/// Format: s{size}w{weight} (e.g., s14w5 = size 14, weight 500)
enum AppTextType {
  s50w7, // headline1 - 50sp, bold
  s40w7, // headline2 - 40sp, bold
  s30w7, // headline3 - 30sp, bold
  s25w7, // headline4 - 25sp, bold
  s20w7, // headline5 - 20sp, bold
  s17w7, // headline6 - 17sp, bold
  s16w4, // body1 - 16sp, normal
  s14w4, // body2 - 14sp, normal
  s13w4, // caption - 13sp, normal
  s16w7, // button - 16sp, bold
  custom, // custom style
}

/// Convenience static constructors for common text types
class AppTextHelper {
  /// s50w7 - Largest heading (50sp, bold)
  static AppText s50w7(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    double? height,
    double? letterSpacing,
  }) {
    return AppText(
      text,
      textType: AppTextType.s50w7,
      color: color,
      fontWeight: fontWeight,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// s40w7 - Large heading (40sp, bold)
  static AppText s40w7(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    double? height,
    double? letterSpacing,
  }) {
    return AppText(
      text,
      textType: AppTextType.s40w7,
      color: color,
      fontWeight: fontWeight,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// s30w7 - Medium heading (30sp, bold)
  static AppText s30w7(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    double? height,
    double? letterSpacing,
  }) {
    return AppText(
      text,
      textType: AppTextType.s30w7,
      color: color,
      fontWeight: fontWeight,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// s25w7 - Small heading (25sp, bold)
  static AppText s25w7(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    double? height,
    double? letterSpacing,
  }) {
    return AppText(
      text,
      textType: AppTextType.s25w7,
      color: color,
      fontWeight: fontWeight,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// s20w7 - Extra small heading (20sp, bold)
  static AppText s20w7(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    double? height,
    double? letterSpacing,
  }) {
    return AppText(
      text,
      textType: AppTextType.s20w7,
      color: color,
      fontWeight: fontWeight,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// s17w7 - Tiny heading (17sp, bold)
  static AppText s17w7(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    double? height,
    double? letterSpacing,
  }) {
    return AppText(
      text,
      textType: AppTextType.s17w7,
      color: color,
      fontWeight: fontWeight,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// s16w4 - Default body text (16sp, normal)
  static AppText s16w4(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    double? height,
    double? letterSpacing,
  }) {
    return AppText(
      text,
      textType: AppTextType.s16w4,
      color: color,
      fontWeight: fontWeight,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// s14w4 - Smaller body text (14sp, normal)
  static AppText s14w4(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    double? height,
    double? letterSpacing,
  }) {
    return AppText(
      text,
      textType: AppTextType.s14w4,
      color: color,
      fontWeight: fontWeight,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// s13w4 - Caption text (13sp, normal)
  static AppText s13w4(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    double? height,
    double? letterSpacing,
  }) {
    return AppText(
      text,
      textType: AppTextType.s13w4,
      color: color,
      fontWeight: fontWeight,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// s16w7 - Button text (16sp, bold)
  static AppText s16w7(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    double? height,
    double? letterSpacing,
  }) {
    return AppText(
      text,
      textType: AppTextType.s16w7,
      color: color,
      fontWeight: fontWeight,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// Custom text with full control
  static AppText custom(
    String text, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    double? height,
    double? letterSpacing,
    TextStyle? style,
    TextDecoration? decoration,
  }) {
    return AppText(
      text,
      textType: AppTextType.custom,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      height: height,
      letterSpacing: letterSpacing,
      style: style,
      decoration: decoration,
    );
  }
}

