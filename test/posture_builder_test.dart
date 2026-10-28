import 'package:iphone_duo/iphone_duo.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  DuoDevice held(double angle, HingeStatus status) => DuoDevice(
        fromIOS: true,
        hinge: Hinge(angle: angle, status: status),
        folds: const [
          ReservedRegion(
            frame: Rect.fromLTWH(0, 455.5, 669, 40),
            margins: EdgeInsets.symmetric(vertical: 20),
          ),
        ],
      );

  testWidgets('it builds again when the posture changes, not on each step', (
    tester,
  ) async {
    final built = <DuoPosture?>[];
    // One widget throughout, as a page's own is while only the hinge moves.
    final builder = PostureBuilder(
      builder: (context, posture) {
        built.add(posture);
        return const SizedBox();
      },
    );
    Future<void> pump(DuoDevice device) => tester.pumpWidget(
          BarEdgeScope(
            edge: null,
            insets: EdgeInsets.zero,
            window: const Size(669, 951),
            device: device,
            child: builder,
          ),
        );

    await pump(held(120, HingeStatus.partiallyOpen));
    await pump(held(118, HingeStatus.partiallyOpen));
    await pump(held(116, HingeStatus.partiallyOpen));
    expect(built, [DuoPosture.tabletop]);

    await pump(held(180, HingeStatus.fullyOpen));
    expect(built, [DuoPosture.tabletop, DuoPosture.flat]);
  });

  testWidgets('what the builder reads itself still rebuilds it', (
    tester,
  ) async {
    Future<void> pump(Size size) => tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(size: size),
            child: PostureBuilder(
              builder: (context, posture) => Text(
                '${MediaQuery.sizeOf(context).width} $posture',
                textDirection: TextDirection.ltr,
              ),
            ),
          ),
        );

    await pump(const Size(390, 844));
    expect(find.text('390.0 null'), findsOneWidget);
    await pump(const Size(844, 390));
    expect(find.text('844.0 null'), findsOneWidget);
  });
}
