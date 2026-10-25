import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'bar_edge.dart';
import 'design_size.dart';

/// The one widget an app puts above its navigator — in `MaterialApp.builder`
/// — for everything else in this package to work:
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) => DuoScope(child: child!),
/// )
/// ```
///
/// * It reads the window's [BarEdge] before any screen's `SafeArea` hides the
///   insets, and hands it down ([BarEdgeScope]).
/// * Where the status bar runs down a side, iOS reports no inset at the top
///   at all, and headers met the rounded corner of the glass: every screen
///   keeps at least [minTopInset] there.
/// * With [lockPhonesUpright], a phone stays upright and a tablet or an open
///   iPhone Duo turns every way ([DuoDesignSize.orientationsFor]) — asked
///   again when the window changes, so the Duo locks upright when it closes.
///   The iPhone's `UISupportedInterfaceOrientations` in `Info.plist` must
///   list the landscape ones too, or iOS never lets the open Duo turn.
class DuoScope extends StatefulWidget {
  const DuoScope({
    super.key,
    required this.child,
    this.minTopInset = 24,
    this.lockPhonesUpright = true,
  });

  final Widget child;

  /// The least room a screen keeps at the top where the status bar is down a
  /// side; as tall as iPadOS's own status bar.
  final double minTopInset;

  /// Whether this sets the app's orientations by the size of the screen.
  final bool lockPhonesUpright;

  @override
  State<DuoScope> createState() => _DuoScopeState();
}

class _DuoScopeState extends State<DuoScope> {
  List<DeviceOrientation>? _orientations;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!widget.lockPhonesUpright) return;
    // The screen, not the window: an iPad in a narrow window still turns.
    final display = View.of(context).display;
    final orientations = DuoDesignSize.orientationsFor(
      display.size / display.devicePixelRatio,
      window: MediaQuery.sizeOf(context),
    );
    if (listEquals(_orientations, orientations)) return;
    _orientations = orientations;
    SystemChrome.setPreferredOrientations(orientations);
  }

  EdgeInsets _withTopRoom(EdgeInsets insets) => insets.top >= widget.minTopInset
      ? insets
      : insets.copyWith(top: widget.minTopInset);

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);
    final side = BarEdge.of(data.viewPadding) != null;
    return BarEdgeScope.of(
      data,
      child: !side
          ? widget.child
          : MediaQuery(
              data: data.copyWith(
                padding: _withTopRoom(data.padding),
                viewPadding: _withTopRoom(data.viewPadding),
              ),
              child: widget.child,
            ),
    );
  }
}
