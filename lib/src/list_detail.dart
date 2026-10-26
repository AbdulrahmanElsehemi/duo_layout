import 'package:flutter/widgets.dart';

import 'two_pane.dart';

/// A list beside the item picked from it, on a window wide enough for two
/// panes ([TwoPane.fits]) — the iPhone Duo open on its side, an iPad — as
/// Mail does: picking an item ([ListDetail.open]) shows it in the other
/// pane, the list staying where it was, and until one is picked that pane
/// shows [placeholder].
///
/// On a narrower window it is the [list] alone, and an item opens its own
/// page as before. The list is the same widget either way, so it keeps its
/// scroll and its state when the Duo is opened or folded; and an item showing
/// beside it when the window narrows goes on to its own page ([onNarrowed]),
/// so folding the Duo shut leaves the reader on what they were looking at.
///
/// For the list to keep its state, the [ListDetail] itself has to: a shell
/// that builds different widgets for a wide and a narrow window (a side tab
/// bar, a bottom one) starts its tabs over unless it keeps them under one
/// `GlobalKey`.
class ListDetail<T extends Object> extends StatefulWidget {
  const ListDetail({
    super.key,
    required this.list,
    required this.detail,
    required this.placeholder,
    required this.onNarrowed,
    this.divider = BorderSide.none,
    this.duration = const Duration(milliseconds: 280),
    this.curve = Curves.easeInOut,
  });

  final Widget list;

  /// The item's page, laid out as on a phone: the pane is its window, about
  /// one phone wide, so the page doesn't split again.
  final Widget Function(BuildContext context, T item) detail;

  /// The other pane while nothing is picked.
  final Widget placeholder;

  /// Opens [item] on a page of its own, once the window is too narrow to
  /// show it beside the list.
  final void Function(BuildContext context, T item) onNarrowed;

  /// A line down the start of the detail pane, between the two: on an iPad,
  /// where no fold divides them.
  final BorderSide divider;

  /// How long one item takes to give way to the next; none when the system
  /// asks for reduced motion.
  final Duration duration;
  final Curve curve;

  /// Shows [item] beside the list [context] is in, and says whether it did:
  /// false on a narrow window, or outside a [ListDetail], where the caller
  /// opens the item its own way.
  static bool open<T extends Object>(BuildContext context, T item) {
    final scope = context.getInheritedWidgetOfExactType<_Scope<T>>();
    if (scope == null || !scope.wide) return false;
    scope.state._open(item);
    return true;
  }

  /// The item showing beside the list [context] is in, if any.
  static T? selectedOf<T extends Object>(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_Scope<T>>()?.selected;

  @override
  State<ListDetail<T>> createState() => _ListDetailState<T>();
}

class _ListDetailState<T extends Object> extends State<ListDetail<T>> {
  /// Moves the list into a pane and out of it again without starting it
  /// over: its state, its scroll.
  final GlobalKey _list = GlobalKey();

  T? _selected;
  bool? _wide;

  void _open(T item) {
    if (item != _selected) setState(() => _selected = item);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final wide = TwoPane.fits(context);
    final item = _selected;
    if (_wide == true && !wide && item != null) {
      _selected = null;
      // Not over a page the reader has gone on to since, nor from a tab
      // they have left.
      final shown =
          (ModalRoute.of(context)?.isCurrent ?? true) && Visibility.of(context);
      if (shown) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.onNarrowed(context, item);
        });
      }
    }
    _wide = wide;
  }

  @override
  Widget build(BuildContext context) {
    final wide = _wide ?? false;
    final list = KeyedSubtree(key: _list, child: widget.list);
    return _Scope<T>(
      state: this,
      wide: wide,
      selected: wide ? _selected : null,
      child: wide ? TwoPane(start: list, end: _detail()) : list,
    );
  }

  Widget _detail() {
    final selected = _selected;
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        border: BorderDirectional(start: widget.divider),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => MediaQuery(
          // The pane is the page's window: a phone's width, so the page lays
          // itself out in one column rather than splitting again.
          data: MediaQuery.of(context).copyWith(size: constraints.biggest),
          child: AnimatedSwitcher(
            duration: reduced ? Duration.zero : widget.duration,
            switchInCurve: widget.curve,
            switchOutCurve: widget.curve,
            child: KeyedSubtree(
              key: ValueKey<T?>(selected),
              child: selected == null
                  ? widget.placeholder
                  : widget.detail(context, selected),
            ),
          ),
        ),
      ),
    );
  }
}

class _Scope<T extends Object> extends InheritedWidget {
  const _Scope({
    required this.state,
    required this.wide,
    required this.selected,
    required super.child,
  });

  final _ListDetailState<T> state;
  final bool wide;
  final T? selected;

  @override
  bool updateShouldNotify(_Scope<T> oldWidget) =>
      wide != oldWidget.wide || selected != oldWidget.selected;
}
