import 'package:iphone_duo/iphone_duo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

void main() {
  // The iPhone Duo open on its side: the fold as the simulator reports it,
  // the status bar's column down the right.
  const fold = ReservedRegion(
    frame: Rect.fromLTWH(455.5, 0, 40, 669),
    margins: EdgeInsets.symmetric(horizontal: 20),
  );
  // The page's side insets and its padding of 16.
  const margin = EdgeInsets.only(left: 16, right: 84 + 16);

  Future<void> pump(
    WidgetTester tester,
    Widget Function(FoldSplit? split) child, {
    List<ReservedRegion> folds = const [fold],
    TextDirection direction = TextDirection.ltr,
  }) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = innerLandscape;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      Directionality(
        textDirection: direction,
        child: BarEdgeScope(
          edge: BarEdge.right,
          insets: EdgeInsets.zero,
          window: innerLandscape,
          device: DuoDevice(fromIOS: true, folds: folds),
          child: Builder(
            builder: (context) => child(FoldSplit.of(context, margin: margin)),
          ),
        ),
      ),
    );
  }

  testWidgets('two halves as wide as each other, the fold between them', (
    tester,
  ) async {
    late FoldSplit? split;
    await pump(tester, (s) {
      split = s;
      return const SizedBox();
    });
    // The end half is the narrower, beside the column: 951 - 495.5 - 100.
    expect(split, const FoldSplit(start: 355.5, gap: 124));
  });

  testWidgets('in Arabic, the start half is the narrower one', (
    tester,
  ) async {
    late FoldSplit? split;
    await pump(
      tester,
      (s) {
        split = s;
        return const SizedBox();
      },
      direction: TextDirection.rtl,
    );
    expect(split, const FoldSplit(start: 355.5, gap: 40));
  });

  testWidgets('a FoldRow puts the end one just past the fold', (tester) async {
    await pump(
      tester,
      (split) => Padding(
        padding: margin,
        child: FoldRow(
          split: split!,
          start: const SizedBox(key: Key('start'), height: 20),
          end: const SizedBox(key: Key('end'), height: 20),
        ),
      ),
    );
    final start = tester.getRect(find.byKey(const Key('start')));
    final end = tester.getRect(find.byKey(const Key('end')));
    expect(start.right, lessThanOrEqualTo(fold.frame.left));
    expect(end.left, fold.frame.right);
    expect(end.width, start.width);
  });

  testWidgets('no split without a fold down the window', (tester) async {
    late FoldSplit? split;
    await pump(
      tester,
      (s) {
        split = s;
        return const SizedBox();
      },
      folds: const [
        ReservedRegion(frame: Rect.fromLTWH(0, 455.5, 669, 40)),
      ],
    );
    expect(split, isNull);
  });
}
