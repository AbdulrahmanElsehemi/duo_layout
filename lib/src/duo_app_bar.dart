import 'package:flutter/material.dart';

import 'side_toolbar.dart';

/// An icon button of a [DuoAppBar]: an [IconButton] in the bar, a
/// [SideToolbarButton] in the column.
class DuoAction {
  const DuoAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final Widget icon;
  final String tooltip;
  final VoidCallback? onPressed;
}

/// An [AppBar] that stands its back button and [actions] down the status
/// bar's column where there is one ([SideToolbar]) and keeps only its title
/// across the top; elsewhere a plain [AppBar] with the same title, back
/// button and actions.
///
/// ```dart
/// Scaffold(
///   appBar: DuoAppBar(
///     title: const Text('Cloud Hybrid'),
///     actions: [
///       DuoAction(icon: const Icon(Icons.share), tooltip: 'Share', onPressed: share),
///     ],
///   ),
/// )
/// ```
class DuoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DuoAppBar({
    super.key,
    required this.title,
    this.actions = const [],
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.centerTitle,
  });

  final Widget title;

  /// Icon buttons only: a button with words stays in a bar across the
  /// screen on the iPhone Duo too — put it in the page or a bottom bar.
  final List<DuoAction> actions;

  /// A back button (or close, on a full-screen dialog) when the route can
  /// be left, as [AppBar] does.
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;

  /// Ignored in the column: the title starts from the start edge there.
  final bool? centerTitle;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    if (!SideToolbar.show(context)) {
      return AppBar(
        title: title,
        automaticallyImplyLeading: automaticallyImplyLeading,
        backgroundColor: backgroundColor,
        centerTitle: centerTitle,
        actions: [
          for (final action in actions)
            IconButton(
              icon: action.icon,
              tooltip: action.tooltip,
              onPressed: action.onPressed,
            ),
        ],
      );
    }

    final route = ModalRoute.of(context);
    final localizations = MaterialLocalizations.of(context);
    final canLeave =
        automaticallyImplyLeading && (route?.impliesAppBarDismissal ?? false);
    final close = route is PageRoute && route.fullscreenDialog;
    return SideToolbar(
      items: [
        if (canLeave)
          SideToolbarButton(
            icon: close ? const CloseButtonIcon() : const BackButtonIcon(),
            tooltip: close
                ? localizations.closeButtonTooltip
                : localizations.backButtonTooltip,
            onPressed: () => Navigator.maybePop(context),
          ),
        for (final action in actions)
          SideToolbarButton(
            icon: action.icon,
            tooltip: action.tooltip,
            onPressed: action.onPressed,
          ),
      ],
      child: AppBar(
        title: title,
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        centerTitle: false,
      ),
    );
  }
}
