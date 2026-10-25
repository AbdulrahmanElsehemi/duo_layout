import 'package:flutter/widgets.dart';

import 'bar_edge.dart';
import 'window_class.dart';

/// Two panes side by side, split down the middle of the window, for a wide
/// window ([fits]): a list beside the item picked, a photo beside what it
/// shows, a cart beside its total.
///
/// The middle is where an iPhone Duo open on its side folds, so neither pane
/// is broken by the crease and each is about a phone wide; on an iPad it is
/// simply half and half. iOS does not say where the fold is, so the split
/// relies on the panes taking the whole window — give it the Scaffold's body,
/// not something inset.
///
/// Each pane keeps clear of its own edge of the glass (the status bar down
/// one side, a camera), not the other pane's. Only the pane beside the status
/// bar gives its header's buttons to the column down it ([SideToolbar]); the
/// other keeps them above it, by the content they act on, as Apple's guide
/// for the iPhone Duo does.
class TwoPane extends StatelessWidget {
  const TwoPane({super.key, required this.start, required this.end});

  /// The pane at the start of the reading direction: the left in English,
  /// the right in Arabic.
  final Widget start;
  final Widget end;

  /// Whether the window is wide enough for two panes.
  static bool fits(BuildContext context) =>
      context.windowClass == WindowClass.expanded;

  @override
  Widget build(BuildContext context) {
    final ltr = Directionality.of(context) == TextDirection.ltr;
    final edge = context.barEdge;
    // The pane on the left of the glass is the start one in English, the
    // end one in Arabic; the column is on whichever side iOS put it.
    Widget away(Widget pane, {required bool onLeft}) =>
        edge == null || (edge == BarEdge.left) == onLeft
            ? pane
            : BarEdgeScope.off(context, child: pane);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeLeft: !ltr,
            removeRight: ltr,
            child: away(start, onLeft: ltr),
          ),
        ),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeLeft: ltr,
            removeRight: !ltr,
            child: away(end, onLeft: !ltr),
          ),
        ),
      ],
    );
  }
}
