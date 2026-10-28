import 'package:duo_layout/duo_layout.dart';
import 'package:duo_layout/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

void main() {
  const photo = Key('photo');
  const title = Key('title');

  /// A page as [HeroBleed] asks: the side insets kept inside the scroll
  /// view, the hero first, a line of text under it.
  Widget page({double height = 240}) => Scaffold(
        body: SafeArea(
          left: false,
          right: false,
          child: Builder(
            builder: (context) => ListView(
              padding: EdgeBleed.sides(context),
              children: [
                HeroBleed(
                  overlay: const Align(
                    alignment: AlignmentDirectional.bottomStart,
                    child: SizedBox(key: title, width: 120, height: 20),
                  ),
                  child: SizedBox(key: photo, height: height),
                ),
                const Text('Below'),
              ],
            ),
          ),
        ),
      );

  testWidgets('closed, the photo reaches under the column to the glass', (
    tester,
  ) async {
    await pumpIn(tester, DuoSimulator.closed, page());
    final rect = tester.getRect(find.byKey(photo));
    expect(rect.left, 0);
    expect(rect.right, 466);
    expect(rect.height, 240);
    // The page goes on under it as tall as it is.
    expect(tester.getTopLeft(find.text('Below')).dy, rect.bottom);
  });

  testWidgets('what is drawn on it keeps clear of the column', (tester) async {
    await pumpIn(tester, DuoSimulator.closed, page());
    final overlay = tester.getRect(
      find.ancestor(of: find.byKey(title), matching: find.byType(Align)),
    );
    expect(overlay.left, 0);
    expect(overlay.right, 466 - 84);
    expect(overlay.height, 240);
  });

  testWidgets('in Arabic the column stays on the right, and so does the bleed',
      (tester) async {
    await pumpIn(
      tester,
      DuoSimulator.closed,
      page(),
      direction: TextDirection.rtl,
    );
    expect(tester.getRect(find.byKey(photo)).right, 466);
    // The title starts at the start of the page's own width: its right.
    expect(tester.getTopRight(find.byKey(title)).dx, 466 - 84);
  });

  testWidgets('on a phone, the photo and its overlay as they are', (
    tester,
  ) async {
    await pumpIn(tester, DuoSimulator.phone, page());
    expect(tester.getRect(find.byKey(photo)).width, 390);
    expect(tester.getBottomLeft(find.byKey(title)), Offset(0, 47 + 240));
  });

  testWidgets('in the pane away from the column, no bleed', (tester) async {
    await pumpIn(
      tester,
      DuoSimulator.onItsSide,
      Scaffold(
        body: TwoPane(
          start: page(),
          end: Builder(
            builder: (context) => ListView(
              padding: EdgeBleed.sides(context),
              children: [
                HeroBleed(child: const SizedBox(key: Key('end'), height: 200)),
              ],
            ),
          ),
        ),
      ),
    );
    // The column is down the right, beside the end pane: only its photo
    // reaches the glass.
    expect(tester.getRect(find.byKey(photo)).right, 475.5);
    expect(tester.getRect(find.byKey(const Key('end'))).right, 951);
  });
}
