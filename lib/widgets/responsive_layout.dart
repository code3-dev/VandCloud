import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget tabletBody;
  final Widget desktopBody;
  final Widget tvBody;

  const ResponsiveLayout({
    Key? key,
    required this.mobileBody,
    required this.tabletBody,
    required this.desktopBody,
    this.tvBody = const SizedBox(), // Default empty widget for TV
  }) : super(key: key);

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 800;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 800 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200 &&
      MediaQuery.of(context).size.width < 1920;

  static bool isTV(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1920;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1920) {
          return tvBody;
        } else if (constraints.maxWidth >= 1200) {
          return desktopBody;
        } else if (constraints.maxWidth >= 800) {
          return tabletBody;
        } else {
          return mobileBody;
        }
      },
    );
  }
}
