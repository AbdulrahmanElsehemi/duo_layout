import 'package:iphone_duo/iphone_duo.dart';
import 'package:iphone_duo/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The iPhone Duo closed: its outer screen, the status bar and the camera
/// down the right.
const outer = Size(466, 678);
const outerInsets = FakeViewPadding(right: 84, bottom: 34);

/// Open on its side: the inner screen, the status bar down the right.
const innerLandscape = Size(951, 669);

/// A phone held upright.
const phone = Size(390, 844);
const phoneInsets = FakeViewPadding(top: 47, bottom: 34);

/// Pumps [home] in a [MaterialApp] under [DuoScope], in a window of [size]
/// with [insets].
Future<void> pumpDuo(
  WidgetTester tester,
  Widget home, {
  Size size = outer,
  FakeViewPadding insets = outerInsets,
  TextDirection direction = TextDirection.ltr,
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = size
    ..padding = insets
    ..viewPadding = insets;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => Directionality(
        textDirection: direction,
        child: DuoScope(lockPhonesUpright: false, child: child!),
      ),
      home: home,
    ),
  );
}

/// Rows enough to scroll.
Widget rows() => ListView(
      children: [
        for (var i = 0; i < 40; i++)
          SizedBox(height: 60, child: Text('Row $i')),
      ],
    );

/// Pumps [home] in a [MaterialApp] in [simulator]'s window, under the scope
/// `DuoScope` would give it there.
Future<void> pumpIn(
  WidgetTester tester,
  DuoSimulator simulator,
  Widget home, {
  TextDirection direction = TextDirection.ltr,
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = simulator.window;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => Directionality(
        textDirection: direction,
        child: simulator.scope(child: child!),
      ),
      home: home,
    ),
  );
}
