import 'package:iphone_duo/iphone_duo.dart';
import 'package:iphone_duo/testing.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ({BarEdge? edge, DuoPosture? posture, WindowClass window}) read(
    WidgetTester tester,
  ) {
    final context = tester.element(find.byType(SizedBox));
    return (
      edge: context.barEdge,
      posture: DuoDevice.of(context).posture,
      window: context.windowClass,
    );
  }

  final expected = {
    DuoSimulator.closed: (
      edge: BarEdge.right,
      posture: DuoPosture.closed,
      window: WindowClass.compact,
    ),
    DuoSimulator.upright: (
      edge: null,
      posture: DuoPosture.flat,
      window: WindowClass.medium,
    ),
    DuoSimulator.onItsSide: (
      edge: BarEdge.right,
      posture: DuoPosture.flat,
      window: WindowClass.expanded,
    ),
    DuoSimulator.tabletop: (
      edge: null,
      posture: DuoPosture.tabletop,
      window: WindowClass.medium,
    ),
    DuoSimulator.book: (
      edge: BarEdge.right,
      posture: DuoPosture.book,
      window: WindowClass.expanded,
    ),
    DuoSimulator.phone: (
      edge: null,
      posture: null,
      window: WindowClass.compact,
    ),
    DuoSimulator.iPad: (
      edge: null,
      posture: null,
      window: WindowClass.expanded,
    ),
  };

  test('every preset is in all', () {
    expect(DuoSimulator.all.toSet(), expected.keys.toSet());
  });

  for (final MapEntry(key: simulator, value: want) in expected.entries) {
    testWidgets('$simulator: the column, the posture, the window', (
      tester,
    ) async {
      await tester.pumpWidget(simulator.scope(child: const SizedBox()));
      expect(read(tester), want);
    });
  }

  testWidgets('the fold is where the simulator puts it', (tester) async {
    expect(DuoSimulator.tabletop.device.fold, DuoSimulator.foldAcross);
    expect(DuoSimulator.book.device.fold, DuoSimulator.foldDown);
    expect(DuoSimulator.upright.device.fold!.isActive, isFalse);
    expect(DuoSimulator.closed.device.fold, isNull);
  });
}
