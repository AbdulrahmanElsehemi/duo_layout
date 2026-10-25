import 'package:duo_layout/duo_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

void main() {
  const tabs = [
    SideTab(icon: Icon(Icons.home_outlined), label: 'Home'),
    SideTab(icon: Icon(Icons.storefront_outlined), label: 'Shop'),
    SideTab(icon: Icon(Icons.person_outline), label: 'Profile'),
  ];

  Future<List<int>> pumpBar(
    WidgetTester tester, {
    FakeViewPadding insets = outerInsets,
    TextDirection direction = TextDirection.ltr,
  }) async {
    final tapped = <int>[];
    await pumpDuo(
      tester,
      Scaffold(
        body: SideTabBar(
          tabs: tabs,
          currentIndex: 0,
          onTap: tapped.add,
          child: rows(),
        ),
      ),
      insets: insets,
      direction: direction,
    );
    return tapped;
  }

  Finder tab(String name) => find.bySemanticsLabel(name);

  testWidgets('the tabs stand in the status bar column, icons only', (
    tester,
  ) async {
    final tapped = await pumpBar(tester);

    final home = tester.getCenter(tab('Home'));
    final profile = tester.getCenter(tab('Profile'));
    expect(profile.dx, home.dx);
    expect(profile.dy, greaterThan(home.dy));
    expect(home.dx, closeTo(outer.width - 84 / 2, 1));
    expect(profile.dy, lessThan(outer.height - 34));
    expect(find.text('Home'), findsNothing);

    await tester.tap(tab('Shop'));
    expect(tapped, [1]);
  });

  testWidgets('it keeps to the status bar in Arabic, and follows it left', (
    tester,
  ) async {
    await pumpBar(tester, direction: TextDirection.rtl);
    expect(tester.getCenter(tab('Home')).dx, closeTo(outer.width - 42, 1));

    await pumpBar(tester, insets: const FakeViewPadding(left: 84, bottom: 34));
    expect(tester.getCenter(tab('Home')).dx, closeTo(42, 1));
  });

  testWidgets('scrolling down shrinks it to the tab you are on', (
    tester,
  ) async {
    final tapped = await pumpBar(tester);

    await tester.drag(find.text('Row 3'), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(tab('Shop'), findsNothing);
    expect(tab('Home'), findsOneWidget);

    // Shrunk, a tap opens it rather than switching.
    await tester.tap(tab('Home'));
    await tester.pumpAndSettle();
    expect(tab('Shop'), findsOneWidget);
    expect(tapped, isEmpty);

    await tester.drag(find.text('Row 6'), const Offset(0, -200));
    await tester.pumpAndSettle();
    await tester.drag(find.text('Row 6'), const Offset(0, 100));
    await tester.pumpAndSettle();
    expect(tab('Shop'), findsOneWidget);
  });

  testWidgets('with the status bar along the top it is the pages alone', (
    tester,
  ) async {
    await pumpDuo(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: SideTabBar(
            tabs: tabs,
            currentIndex: 0,
            onTap: (_) {},
            child: rows(),
          ),
          bottomNavigationBar: SideTabBar.show(context)
              ? null
              : const SizedBox(height: 80, child: Text('bottom bar')),
        ),
      ),
      size: phone,
      insets: phoneInsets,
    );
    expect(tab('Home'), findsNothing);
    expect(find.text('bottom bar'), findsOneWidget);
  });
}
