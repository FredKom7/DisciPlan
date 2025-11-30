import 'package:flutter/material.dart';

/// Responsive layout helper for cross-platform UI adaptation
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= 1200) {
      return desktop ?? tablet ?? mobile;
    } else if (width >= 600) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}

/// Responsive value helper
class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T? desktop;

  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  T getValue(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= 1200) {
      return desktop ?? tablet ?? mobile;
    } else if (width >= 600) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}

/// Screen size breakpoints
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1200;
  static const double desktop = 1200;
}

/// Responsive padding helper
class ResponsivePadding {
  static EdgeInsets all(BuildContext context) {
    if (ResponsiveLayout.isDesktop(context)) {
      return const EdgeInsets.all(32);
    } else if (ResponsiveLayout.isTablet(context)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(16);
    }
  }

  static EdgeInsets horizontal(BuildContext context) {
    if (ResponsiveLayout.isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 32);
    } else if (ResponsiveLayout.isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 24);
    } else {
      return const EdgeInsets.symmetric(horizontal: 16);
    }
  }
}
