import 'package:duo_layout/duo_layout.dart';
import 'package:duo_layout/testing.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const top = Key('top');
  const bottom = Key('bottom');
  const page = Key('page');

  final seen = <Key, MediaQueryData>{};
  Widget pane(Key key) => Builder(
        key: key,
        builder: (context) {
          seen[key] = MediaQuery.of(context);
          return const SizedBox.expand();
        },
      );

  Widget layout() => TabletopLayout(
        top: pane(top),
        bottom: pane(bottom),
        child: pane(page),
      );

  Future<void> pump(WidgetTester tester, DuoSimulator simulator, Widget child) {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = simulator.window;
    addTearDown(tester.view.reset);
    return tester.pumpWidget(simulator.scope(child: child));
  }

  setUp(seen.clear);

  testWidgets('stood as a tabletop, one half either side of the fold', (
    tester,
  ) async {
    await pump(tester, DuoSimulator.tabletop, layout());

    expect(find.byKey(page), findsNothing);
    expect(
        tester.getRect(find.byKey(top)), const Rect.fromLTWH(0, 0, 669, 455.5));
    expect(
      tester.getRect(find.byKey(bottom)),
      const Rect.fromLTWH(0, 495.5, 669, 455.5),
    );
    // Each half is its own window: its own size, and the insets of the edge
    // the fold cuts off gone.
    expect(seen[top]!.size, const Size(669, 455.5));
    expect(seen[top]!.padding, const EdgeInsets.only(top: 82));
    expect(seen[bottom]!.padding, const EdgeInsets.only(bottom: 34));
  });

  testWidgets('open flat, held like a book, closed, or on a phone: the page', (
    tester,
  ) async {
    for (final simulator in [
      DuoSimulator.upright,
      DuoSimulator.book,
      DuoSimulator.closed,
      DuoSimulator.phone,
    ]) {
      await pump(tester, simulator, layout());
      expect(find.byKey(page), findsOneWidget, reason: '$simulator');
      expect(find.byKey(top), findsNothing, reason: '$simulator');
    }
  });

  testWidgets('not given the whole window, the page', (tester) async {
    await pump(
      tester,
      DuoSimulator.tabletop,
      Padding(padding: const EdgeInsets.only(top: 60), child: layout()),
    );
    expect(find.byKey(page), findsOneWidget);
  });

  testWidgets('the halves are not built again as the hinge moves', (
    tester,
  ) async {
    var built = 0;
    final layout = TabletopLayout(
      top: Builder(
        builder: (context) {
          built++;
          return const SizedBox.expand();
        },
      ),
      bottom: const SizedBox.expand(),
      child: const SizedBox.expand(),
    );
    DuoSimulator at(double angle) => DuoSimulator(
          name: 'tabletop at $angle°',
          window: DuoSimulator.tabletop.window,
          insets: DuoSimulator.tabletop.insets,
          device: DuoDevice(
            fromIOS: true,
            hinge: Hinge(angle: angle, status: HingeStatus.partiallyOpen),
            folds: const [DuoSimulator.foldAcross],
          ),
        );
    await pump(tester, at(110), layout);
    await pump(tester, at(108), layout);
    await pump(tester, at(106), layout);
    expect(built, 1);
  });
}
