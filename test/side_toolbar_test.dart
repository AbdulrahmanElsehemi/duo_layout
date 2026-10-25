import 'package:duo_layout/duo_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

void main() {
  Widget detail({String title = 'Detail'}) => Scaffold(
        appBar: DuoAppBar(
          title: Text(title),
          actions: [
            DuoAction(
              icon: const Icon(Icons.share),
              tooltip: 'Share',
              onPressed: () {},
            ),
          ],
        ),
        body: rows(),
      );

  Future<void> pushDetail(WidgetTester tester) async {
    final context = tester.element(find.text('Start'));
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => detail()));
    await tester.pumpAndSettle();
  }

  testWidgets('back, then the actions, stand down the column under the clock', (
    tester,
  ) async {
    await pumpDuo(tester, const Scaffold(body: Text('Start')));
    await pushDetail(tester);

    final back = tester.getCenter(find.bySemanticsLabel('Back'));
    final share = tester.getCenter(find.bySemanticsLabel('Share'));
    expect(back.dx, closeTo(outer.width - 42, 1));
    expect(share.dx, back.dx);
    expect(share.dy, greaterThan(back.dy));
    expect(back.dy, greaterThan(SideToolbar.defaultTop(outer)));
    // The bar keeps its title, from the start.
    expect(tester.getTopLeft(find.text('Detail')).dx, lessThan(40));

    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Start'), findsOneWidget);
    expect(find.bySemanticsLabel('Share'), findsNothing);
  });

  testWidgets('on a phone it is a plain AppBar', (tester) async {
    await pumpDuo(
      tester,
      const Scaffold(body: Text('Start')),
      size: phone,
      insets: phoneInsets,
    );
    await pushDetail(tester);

    final bar = tester.getRect(find.byType(AppBar));
    expect(bar.contains(tester.getCenter(find.byTooltip('Back'))), isTrue);
    expect(bar.contains(tester.getCenter(find.byTooltip('Share'))), isTrue);
  });

  testWidgets(
      'in two panes, only the pane beside the column gives it its '
      'buttons', (tester) async {
    Widget pane(String name) => SideToolbar(
          items: [
            SideToolbarButton(
              icon: const Icon(Icons.more_horiz),
              tooltip: '$name more',
              onPressed: () {},
            ),
          ],
          child: Text('$name header'),
        );
    await pumpDuo(
      tester,
      Scaffold(
        body: TwoPane(start: pane('List'), end: pane('Detail')),
      ),
      size: innerLandscape,
    );
    // The detail pane is beside the column on the right.
    expect(
      tester.getCenter(find.bySemanticsLabel('Detail more')).dx,
      closeTo(innerLandscape.width - 42, 1),
    );
    expect(find.bySemanticsLabel('List more'), findsNothing);
  });
}
