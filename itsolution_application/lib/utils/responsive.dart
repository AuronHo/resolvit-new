import 'package:flutter/material.dart';

class Responsive {
  static const double _tabletBreakpoint = 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= _tabletBreakpoint;

  /// Grid delegate for service card lists.
  /// 1 column on phone, 2 on tablet. mainAxisExtent matches the card height.
  static SliverGridDelegate cardGridDelegate(BuildContext context) =>
      SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet(context) ? 2 : 1,
        mainAxisExtent: 150,
      );

  /// Wraps [child] in a centered max-width container on tablet.
  /// On phone returns [child] unchanged.
  static Widget constrain(BuildContext context, Widget child,
      {double maxWidth = 720}) {
    if (!isTablet(context)) return child;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }

  static double horizontalPadding(BuildContext context) =>
      isTablet(context) ? 40 : 24;
}
