import 'package:duo_layout/duo_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

void main() {
  test('the column is the side inset deeper than the top, alone', () {
    // The iPhone Duo closed, and open on its side.
    expect(
      BarEdge.of(const EdgeInsets.only(right: 84, bottom: 34)),
      BarEdge.right,
    );
    expect(BarEdge.of(const EdgeInsets.only(left: 84)), BarEdge.left);
    // A phone upright, an iPad, the Duo open upright.
    expect(BarEdge.of(const EdgeInsets.only(top: 47, bottom: 34)), isNull);
    expect(BarEdge.of(const EdgeInsets.only(top: 24, bottom: 20)), isNull);
    // A phone on its side: its notch and its corners, on both sides.
    expect(BarEdge.of(const EdgeInsets.only(left: 47, right: 47)), isNull);
  });

  testWidgets(
      'DuoScope hands the edge down past a SafeArea, with room at '
      'the top', (tester) async {
    late BarEdge? edge;
    late EdgeInsets padding;
    await pumpDuo(
      tester,
      SafeArea(
        child: Builder(
          builder: (context) {
            edge = context.barEdge;
            return const SizedBox();
          },
        ),
      ),
    );
    final scaffold = tester.element(find.byType(SafeArea));
    padding = MediaQuery.paddingOf(scaffold);
    expect(edge, BarEdge.right);
    expect(padding.top, 24);

    await pumpDuo(
      tester,
      Builder(
        builder: (context) {
          edge = context.barEdge;
          return const SizedBox();
        },
      ),
      size: phone,
      insets: phoneInsets,
    );
    expect(edge, isNull);
  });

  testWidgets('BarEdgeScope.off keeps a pane\'s bars where they are', (
    tester,
  ) async {
    late BarEdge? edge;
    late EdgeInsets insets;
    await pumpDuo(
      tester,
      Builder(
        builder: (context) => BarEdgeScope.off(
          context,
          child: Builder(
            builder: (context) {
              edge = context.barEdge;
              insets = context.windowInsets;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(edge, isNull);
    expect(insets.right, 84);
  });

  test('a phone scales the design to the width beside the column', () {
    const frame = Size(390, 844);
    expect(
      DuoDesignSize.forWindow(const Size(390, 844), phoneFrame: frame),
      frame,
    );
    // 466 wide less the 84 column: 382 to draw on, 0.98 of the design.
    final outer = DuoDesignSize.forWindow(
      const Size(466, 678),
      phoneFrame: frame,
      insets: const EdgeInsets.only(right: 84),
    );
    expect(466 / outer.width, closeTo(382 / 390, 0.001));
    // Open, the design's points are drawn as they are.
    expect(
      DuoDesignSize.forWindow(innerLandscape, phoneFrame: frame),
      const Size(951, 700),
    );
  });

  test('the open Duo turns, though iOS still reports its outer screen', () {
    const upright = [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ];
    expect(DuoDesignSize.orientationsFor(const Size(466, 678)), upright);
    expect(
      DuoDesignSize.orientationsFor(
        const Size(466, 678),
        window: innerLandscape,
      ),
      DeviceOrientation.values,
    );
    expect(
      DuoDesignSize.orientationsFor(const Size(834, 1194)),
      DeviceOrientation.values,
    );
  });

  test('columns keep even where asked, for the fold', () {
    expect(WindowClass.of(390), WindowClass.compact);
    expect(WindowClass.of(669), WindowClass.medium);
    expect(WindowClass.of(951), WindowClass.expanded);
    expect(DuoBreakpoints.columns(390, tile: 170), 2);
    expect(DuoBreakpoints.columns(669, tile: 170), 3);
    expect(DuoBreakpoints.columns(669, tile: 170, even: true), 2);
    expect(DuoBreakpoints.columns(951, tile: 170, even: true), 4);
  });
}
