import 'package:flutter/material.dart';

import 'bar_edge.dart';
import 'window_class.dart';

/// A header's buttons, stood where iOS stands a toolbar on the iPhone Duo:
/// down the column the status bar runs down ([BarEdge]), under the clock,
/// Back or Close at the top and the actions after it — on the outer screen,
/// and on the inner one held on its side. Elsewhere it is just [child].
///
/// The header leaves its buttons out when [show] says so and builds only its
/// title; [items] are drawn over the screen, in the column the page keeps
/// clear of, so they take none of its height. They go with the screen: gone
/// while it is covered or on a tab that is not showing, and fading with it
/// as a route comes and goes.
///
/// [DuoAppBar] does all of this for an `AppBar`.
class SideToolbar extends StatefulWidget {
  const SideToolbar({
    super.key,
    required this.items,
    required this.child,
    this.spacing = 8,
    this.top,
  });

  /// Top to bottom: Back or Close first, as Apple's guide orders them. Icon
  /// buttons only — a button with words stays in a bar across the screen.
  /// [SideToolbarButton] draws one as iOS does.
  final List<Widget> items;

  /// The header, without the [items].
  final Widget child;

  /// Between the items.
  final double spacing;

  /// Where the column's first item starts, from the top of the window;
  /// [defaultTop] when null.
  final double? top;

  /// Whether a header at [context] gives its buttons to the column.
  static bool show(BuildContext context) => context.barEdge != null;

  /// Under the clock, and on the outer screen under the camera above it too.
  /// iOS gives an app no figure for this; these are measured on the iPhone
  /// Duo simulator (iOS 27.1).
  static double defaultTop(Size window) =>
      window.width < DuoBreakpoints.medium ? 160 : 104;

  @override
  State<SideToolbar> createState() => _SideToolbarState();
}

class _SideToolbarState extends State<SideToolbar> {
  final _portal = OverlayPortalController();

  @override
  void initState() {
    super.initState();
    _portal.show();
  }

  @override
  Widget build(BuildContext context) {
    final edge = context.barEdge;
    if (edge == null || widget.items.isEmpty) return widget.child;

    final insets = context.windowInsets;
    final window = context.windowSize;
    final left = edge == BarEdge.left;

    Widget column = Column(
      mainAxisSize: MainAxisSize.min,
      spacing: widget.spacing,
      children: widget.items,
    );
    // In and out with the screen's own route, rather than standing still
    // while the page slides away under it.
    final route = ModalRoute.of(context);
    if (route != null && !reducedMotion(context)) {
      column = FadeTransition(
        opacity: route.animation ?? kAlwaysCompleteAnimation,
        child: FadeTransition(
          opacity: ReverseAnimation(
            route.secondaryAnimation ?? kAlwaysDismissedAnimation,
          ),
          child: column,
        ),
      );
    }

    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: (_) => !onScreen(context)
          ? const SizedBox.shrink()
          // Per side of the glass, not by the reading direction.
          : Positioned(
              left: left ? 0 : null,
              right: left ? null : 0,
              width: left ? insets.left : insets.right,
              top: widget.top ?? SideToolbar.defaultTop(window),
              child: Center(child: column),
            ),
      child: widget.child,
    );
  }
}

/// A round icon button for the column: a raised disc, as iOS draws the
/// buttons it stands down the side, so it reads over whatever scrolls under
/// it.
class SideToolbarButton extends StatelessWidget {
  const SideToolbarButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = 44,
    this.iconSize = 20,
    this.backgroundColor,
    this.foregroundColor,
  });

  final Widget icon;

  /// Shown on a long press and read out by a screen reader.
  final String tooltip;
  final VoidCallback? onPressed;

  /// 44 is Apple's least.
  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        excludeSemantics: true,
        child: Material(
          color: backgroundColor ?? scheme.surface,
          shape: CircleBorder(side: BorderSide(color: scheme.outlineVariant)),
          elevation: 2,
          shadowColor: scheme.shadow.withValues(alpha: 0.4),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: SizedBox.square(
              dimension: size,
              child: IconTheme.merge(
                data: IconThemeData(
                  size: iconSize,
                  color: foregroundColor ?? scheme.onSurface,
                ),
                child: Center(child: icon),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
