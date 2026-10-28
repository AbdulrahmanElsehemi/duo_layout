import 'package:iphone_duo/iphone_duo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

void main() {
  late List<String> pushed;
  late List<String> narrowed;

  void resize(WidgetTester tester, Size window) {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = window;
    addTearDown(tester.view.reset);
  }

  Widget app({bool visible = true}) => MaterialApp(
        home: Scaffold(
          body: Visibility.maintain(
            visible: visible,
            child: ListDetail<String>(
              list: _List(onPush: pushed.add),
              detail: (context, item) => Builder(
                builder: (context) => Text(
                  'detail $item, '
                  '${TwoPane.fits(context) ? 'wide' : 'one column'}',
                ),
              ),
              placeholder: const Text('pick one'),
              onNarrowed: (context, item) => narrowed.add(item),
            ),
          ),
        ),
      );

  setUp(() {
    pushed = [];
    narrowed = [];
  });

  testWidgets('on a phone an item opens its own page', (tester) async {
    resize(tester, outer);
    await tester.pumpWidget(app());
    await tester.tap(find.text('open a'));
    await tester.pumpAndSettle();
    expect(pushed, ['a']);
    expect(find.text('pick one'), findsNothing);
  });

  testWidgets('open on its side, an item opens beside the list, in one column',
      (tester) async {
    resize(tester, innerLandscape);
    await tester.pumpWidget(app());
    expect(find.text('pick one'), findsOneWidget);

    await tester.tap(find.text('open a'));
    await tester.pumpAndSettle();
    expect(pushed, isEmpty);
    expect(find.text('detail a, one column'), findsOneWidget);
    expect(find.text('selected a'), findsOneWidget);
    // In the other pane, past the middle of the window.
    expect(
      tester.getTopLeft(find.text('detail a, one column')).dx,
      greaterThanOrEqualTo(innerLandscape.width / 2),
    );

    await tester.tap(find.text('open b'));
    await tester.pumpAndSettle();
    expect(find.text('detail b, one column'), findsOneWidget);
    expect(find.text('detail a, one column'), findsNothing);
  });

  testWidgets('the list keeps its state when the Duo opens', (tester) async {
    resize(tester, outer);
    await tester.pumpWidget(app());
    await tester.tap(find.text('taps 0'));
    await tester.pump();

    resize(tester, innerLandscape);
    await tester.pump();
    expect(find.text('taps 1'), findsOneWidget);
    expect(find.text('pick one'), findsOneWidget);
  });

  testWidgets('folded shut, the item open beside the list gets its own page',
      (tester) async {
    resize(tester, innerLandscape);
    await tester.pumpWidget(app());
    await tester.tap(find.text('open a'));
    await tester.pumpAndSettle();

    resize(tester, outer);
    await tester.pumpAndSettle();
    expect(narrowed, ['a']);
    expect(find.text('selected none'), findsOneWidget);

    // Opened again, nothing is picked: the page has it now.
    resize(tester, innerLandscape);
    await tester.pumpAndSettle();
    expect(find.text('pick one'), findsOneWidget);
  });

  testWidgets('not from a tab the reader has left', (tester) async {
    resize(tester, innerLandscape);
    await tester.pumpWidget(app());
    await tester.tap(find.text('open a'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(app(visible: false));

    resize(tester, outer);
    await tester.pumpAndSettle();
    expect(narrowed, isEmpty);
  });

  testWidgets('outside a ListDetail, open says no', (tester) async {
    late bool opened;
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          opened = ListDetail.open(context, 'a');
          return const SizedBox();
        },
      ),
    );
    expect(opened, isFalse);
  });
}

/// A list that counts its taps, to show it is not started over.
class _List extends StatefulWidget {
  const _List({required this.onPush});

  final ValueChanged<String> onPush;

  @override
  State<_List> createState() => _ListState();
}

class _ListState extends State<_List> {
  int _taps = 0;

  void _open(String item) {
    if (!ListDetail.open(context, item)) widget.onPush(item);
  }

  @override
  Widget build(BuildContext context) {
    final selected = ListDetail.selectedOf<String>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _taps++),
          child: Text('taps $_taps'),
        ),
        GestureDetector(onTap: () => _open('a'), child: const Text('open a')),
        GestureDetector(onTap: () => _open('b'), child: const Text('open b')),
        Text('selected ${selected ?? 'none'}'),
      ],
    );
  }
}
