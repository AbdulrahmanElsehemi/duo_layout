import 'package:iphone_duo/iphone_duo.dart';
import 'package:iphone_duo/testing.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<double> keyboardSeen(
    WidgetTester tester, {
    required double keyboard,
    DuoSimulator simulator = DuoSimulator.upright,
  }) async {
    late double seen;
    await tester.pumpWidget(
      simulator.scope(
        child: Builder(
          // The keyboard comes up under the scope, as iOS reports it.
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              viewInsets: EdgeInsets.only(bottom: keyboard),
            ),
            child: KeyboardAboveFold(
              child: Builder(
                builder: (context) {
                  seen = MediaQuery.viewInsetsOf(context).bottom;
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      ),
    );
    return seen;
  }

  testWidgets('with the keyboard up, it reaches the fold', (tester) async {
    expect(await keyboardSeen(tester, keyboard: 320), 951 - 455.5);
  });

  testWidgets('a keyboard over the fold already is left as it is', (
    tester,
  ) async {
    expect(await keyboardSeen(tester, keyboard: 520), 520);
  });

  testWidgets('no keyboard, no change', (tester) async {
    expect(await keyboardSeen(tester, keyboard: 0), 0);
  });

  testWidgets('a fold down the screen leaves the keyboard alone', (
    tester,
  ) async {
    expect(
      await keyboardSeen(
        tester,
        keyboard: 300,
        simulator: DuoSimulator.onItsSide,
      ),
      300,
    );
  });

  testWidgets('without a fold, no change', (tester) async {
    expect(
      await keyboardSeen(tester, keyboard: 320, simulator: DuoSimulator.phone),
      320,
    );
  });
}
