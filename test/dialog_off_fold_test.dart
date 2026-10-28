import 'package:iphone_duo/iphone_duo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

void main() {
  // The iPhone Duo open upright, and on its side, as the simulator reports
  // the fold.
  const upright = Size(669, 951);
  const across = ReservedRegion(
    frame: Rect.fromLTWH(0, 455.5, 669, 40),
    margins: EdgeInsets.symmetric(vertical: 20),
  );
  const down = ReservedRegion(
    frame: Rect.fromLTWH(455.5, 0, 40, 669),
    margins: EdgeInsets.symmetric(horizontal: 20),
  );

  Future<Rect> dialogOn(
    WidgetTester tester, {
    required Size window,
    ReservedRegion? fold,
    TextDirection direction = TextDirection.ltr,
  }) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = window;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        // The dialog is a route over the app: the scope has to be above it.
        builder: (context, child) => Directionality(
          textDirection: direction,
          child: BarEdgeScope(
            edge: null,
            insets: EdgeInsets.zero,
            window: window,
            device: fold == null
                ? DuoDevice.unknown
                : DuoDevice(fromIOS: true, folds: [fold]),
            child: child!,
          ),
        ),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (context) => const DialogOffFold(
                child: Dialog(child: SizedBox(width: 280, height: 160)),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return tester.getRect(find.byType(Dialog));
  }

  testWidgets('open upright, the dialog opens under the fold', (tester) async {
    final rect = await dialogOn(tester, window: upright, fold: across);
    expect(rect.top, greaterThanOrEqualTo(across.frame.bottom));
  });

  testWidgets('open on its side, the dialog keeps to the end half', (
    tester,
  ) async {
    final rect = await dialogOn(tester, window: innerLandscape, fold: down);
    expect(rect.left, greaterThanOrEqualTo(down.frame.right));
  });

  testWidgets('in Arabic, the end half is the left one', (tester) async {
    final rect = await dialogOn(
      tester,
      window: innerLandscape,
      fold: down,
      direction: TextDirection.rtl,
    );
    expect(rect.right, lessThanOrEqualTo(down.frame.left));
  });

  testWidgets('with no fold, it stays in the middle', (tester) async {
    final rect = await dialogOn(tester, window: phone);
    expect(rect.center.dy, closeTo(phone.height / 2, 1));
    expect(rect.center.dx, closeTo(phone.width / 2, 1));
  });
}
