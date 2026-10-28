import 'package:iphone_duo/iphone_duo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

void main() {
  testWidgets('the panes split at the fold, each clear of its own edge', (
    tester,
  ) async {
    late EdgeInsets start;
    late EdgeInsets end;
    await pumpDuo(
      tester,
      Scaffold(
        body: TwoPane(
          start: Builder(
            builder: (context) {
              start = MediaQuery.paddingOf(context);
              return const SizedBox.expand(key: Key('start'));
            },
          ),
          end: Builder(
            builder: (context) {
              end = MediaQuery.paddingOf(context);
              return const SizedBox.expand(key: Key('end'));
            },
          ),
        ),
      ),
      size: innerLandscape,
    );
    final left = tester.getRect(find.byKey(const Key('start')));
    expect(left.right, innerLandscape.width / 2);
    expect(start.right, 0);
    expect(end.right, 84);
  });

  testWidgets('two panes only on a wide window', (tester) async {
    late bool fits;
    Widget probe() => Builder(
          builder: (context) {
            fits = TwoPane.fits(context);
            return const SizedBox();
          },
        );
    await pumpDuo(tester, probe(), size: innerLandscape);
    expect(fits, isTrue);
    await pumpDuo(
      tester,
      probe(),
      size: const Size(669, 951),
      insets: const FakeViewPadding(top: 32, bottom: 20),
    );
    expect(fits, isFalse);
  });
}
