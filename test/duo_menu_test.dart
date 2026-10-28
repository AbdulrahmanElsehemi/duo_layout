import 'package:iphone_duo/iphone_duo.dart';
import 'package:iphone_duo/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

void main() {
  final picked = <String>[];
  setUp(picked.clear);

  DuoAction action(String name) => DuoAction(
        icon: const Icon(Icons.star),
        tooltip: name,
        systemImage: 'star',
        onPressed: () => picked.add(name),
      );

  Widget page() => Scaffold(
        appBar: DuoAppBar(
          title: const Text('Detail'),
          actions: [
            for (final name in ['A', 'B', 'C', 'D', 'E']) action(name)
          ],
          menu: [
            DuoMenuItem(
              title: 'Delete',
              destructive: true,
              onSelected: () => picked.add('Delete'),
            ),
          ],
        ),
        body: const SizedBox(),
      );

  /// [page] pushed over a start page, so it has Back.
  Future<void> pumpPage(WidgetTester tester, DuoSimulator simulator) async {
    await pumpIn(tester, simulator, const Scaffold(body: Text('Start')));
    Navigator.of(tester.element(find.text('Start')))
        .push(MaterialPageRoute<void>(builder: (_) => page()));
    await tester.pumpAndSettle();
  }

  testWidgets('in the column, three actions and the rest behind "…"', (
    tester,
  ) async {
    await pumpPage(tester, DuoSimulator.closed);

    for (final name in ['A', 'B', 'C']) {
      expect(find.bySemanticsLabel(name), findsOneWidget, reason: name);
    }
    expect(find.bySemanticsLabel('D'), findsNothing);
    final back = tester.getCenter(find.bySemanticsLabel('Back'));
    final more = tester.getCenter(find.bySemanticsLabel('More'));
    // At the foot of the column, under the actions.
    expect(more.dx, back.dx);
    expect(
        more.dy, greaterThan(tester.getCenter(find.bySemanticsLabel('C')).dy));

    await tester.tap(find.bySemanticsLabel('More'));
    await tester.pumpAndSettle();
    expect(find.text('D'), findsOneWidget);
    expect(find.text('E'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(picked, ['Delete']);
  });

  testWidgets('on a phone, every action in the bar and the menu behind "…"', (
    tester,
  ) async {
    await pumpPage(tester, DuoSimulator.phone);
    for (final name in ['A', 'B', 'C', 'D', 'E']) {
      expect(find.byTooltip(name), findsOneWidget, reason: name);
    }
    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(picked, ['Delete']);
  });

  testWidgets('without overflow, no "…"', (tester) async {
    await pumpIn(
      tester,
      DuoSimulator.closed,
      Scaffold(
        appBar: DuoAppBar(title: const Text('Detail'), actions: [action('A')]),
      ),
    );
    expect(find.bySemanticsLabel('More'), findsNothing);
  });

  group('on iOS', () {
    late List<Map<Object?, Object?>> created;

    setUp(() {
      created = [];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform_views,
              (call) async {
        if (call.method == 'create') {
          final args = call.arguments as Map<Object?, Object?>;
          created.add(
            const StandardMessageCodec().decodeMessage(
              ByteData.sublistView(args['params']! as Uint8List),
            ) as Map<Object?, Object?>,
          );
        }
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform_views, null);
    });

    testWidgets('the menu is iOS\'s own, its picks come back', (tester) async {
      await pumpPage(tester, DuoSimulator.closed);

      expect(find.byType(UiKitView), findsOneWidget);
      expect(created, hasLength(1));
      expect(created.single['tooltip'], 'More');
      expect(created.single['items'], [
        {
          'id': 0,
          'title': 'D',
          'image': 'star',
          'destructive': false,
          'enabled': true,
        },
        {
          'id': 1,
          'title': 'E',
          'image': 'star',
          'destructive': false,
          'enabled': true,
        },
        {
          'id': 2,
          'title': 'Delete',
          'image': null,
          'destructive': true,
          'enabled': true,
        },
      ]);

      // iOS says which was picked, on the view's own channel.
      final id = tester.widget<UiKitView>(find.byType(UiKitView));
      expect(id.viewType, SideToolbarMenuButton.viewType);
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
        '${SideToolbarMenuButton.viewType}_0',
        const StandardMethodCodec().encodeMethodCall(
          const MethodCall('selected', 1),
        ),
        (_) {},
      );
      expect(picked, ['E']);
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));
  });
}
