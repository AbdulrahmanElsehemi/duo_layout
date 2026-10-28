import 'package:iphone_duo/iphone_duo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

/// What the plugin sends from the iPhone Duo simulator (iOS 27.1), open on
/// its side.
Map<String, Object?> openOnItsSide({
  double angle = 180,
  String status = 'fullyOpen',
  double foldX = 455.5,
}) =>
    {
      'available': true,
      'barEdge': 'right',
      'hinge': {'angle': angle, 'status': status},
      'folds': [
        {
          'frame': [foldX, 0.0, 40.0, 669.0],
          'margins': [0.0, 20.0, 0.0, 20.0],
          'active': status == 'partiallyOpen',
        },
      ],
      'occlusions': [
        {
          'frame': [867.0, 0.0, 84.0, 124.0],
          'margins': [0.0, 0.0, 0.0, 0.0],
          'active': true,
        },
      ],
    };

void main() {
  group('DuoDevice.fromMap', () {
    test('reads the column, the hinge, the fold and the camera', () {
      final device = DuoDevice.fromMap(openOnItsSide());
      expect(device.fromIOS, isTrue);
      expect(device.barEdge, BarEdge.right);
      expect(
        device.hinge,
        const Hinge(angle: 180, status: HingeStatus.fullyOpen),
      );
      expect(device.fold!.axis, Axis.vertical);
      expect(device.fold!.rect, const Rect.fromLTWH(475.5, 0, 0, 669));
      expect(device.fold!.isActive, isFalse);
      expect(device.occlusions.single.frame.bottom, 124);
      expect(device.posture, DuoPosture.flat);
    });

    test('tells a book from a tabletop by the way the fold runs', () {
      expect(
        DuoDevice.fromMap(
          openOnItsSide(angle: 110, status: 'partiallyOpen'),
        ).posture,
        DuoPosture.book,
      );
      final upright = DuoDevice.fromMap({
        'available': true,
        'hinge': {'angle': 110.0, 'status': 'partiallyOpen'},
        'folds': [
          {
            'frame': [0.0, 455.5, 669.0, 40.0],
            'margins': [20.0, 0.0, 20.0, 0.0],
            'active': true,
          },
        ],
      });
      expect(upright.posture, DuoPosture.tabletop);
      expect(upright.barEdge, isNull);
    });

    test('is unknown when iOS has none of it', () {
      final device = DuoDevice.fromMap({'available': false});
      expect(device, DuoDevice.unknown);
      expect(device.posture, isNull);
    });
  });

  group('BarEdge.resolve', () {
    const column = EdgeInsets.only(right: 84, bottom: 34);

    test('takes the side iOS gives, where the insets leave room', () {
      final device = DuoDevice.fromMap(openOnItsSide());
      expect(BarEdge.resolve(column, device), BarEdge.right);
      expect(BarEdge.resolve(const EdgeInsets.only(top: 82), device), isNull);
    });

    test('takes iOS at its word when it says there is no column', () {
      const device = DuoDevice(fromIOS: true);
      expect(BarEdge.resolve(column, device), isNull);
    });

    test('guesses from the insets when iOS says nothing', () {
      expect(BarEdge.resolve(column, DuoDevice.unknown), BarEdge.right);
    });
  });

  group('DuoScope on iOS', () {
    const methods = MethodChannel('iphone_duo');
    const changes = EventChannel('iphone_duo/changes');

    Future<void> answer(
      WidgetTester tester,
      Map<String, Object?> snapshot, {
      List<Map<String, Object?>> later = const [],
    }) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final messenger = tester.binding.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(methods, (_) async => snapshot);
      messenger.setMockStreamHandler(
        changes,
        MockStreamHandler.inline(
          onListen: (_, events) {
            events.success(snapshot);
            later.forEach(events.success);
          },
        ),
      );
      addTearDown(() {
        messenger.setMockMethodCallHandler(methods, null);
        messenger.setMockStreamHandler(changes, null);
      });
    }

    testWidgets('without the plugin it reads the safe area, quietly', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      late DuoDevice device;
      await pumpDuo(
        tester,
        Builder(
          builder: (context) {
            device = DuoDevice.of(context);
            return Text('${context.barEdge}');
          },
        ),
      );
      await tester.pumpAndSettle();
      expect(device, DuoDevice.unknown);
      expect(find.text('${BarEdge.right}'), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('TwoPane splits where iOS says the fold is', (tester) async {
      await answer(tester, openOnItsSide(foldX: 480));
      await pumpDuo(
        tester,
        const TwoPane(start: Text('List'), end: Text('Detail')),
        size: innerLandscape,
      );
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.text('Detail')).dx, 500);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('a hinge tick rebuilds what reads it, not the layouts', (
      tester,
    ) async {
      late MockStreamHandlerEventSink sink;
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final messenger = tester.binding.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(
        methods,
        (_) async => openOnItsSide(angle: 180, status: 'partiallyOpen'),
      );
      messenger.setMockStreamHandler(
        changes,
        MockStreamHandler.inline(onListen: (_, events) {
          sink = events;
        }),
      );
      addTearDown(() {
        messenger.setMockMethodCallHandler(methods, null);
        messenger.setMockStreamHandler(changes, null);
      });
      var layouts = 0;
      var readers = 0;
      await pumpDuo(
        tester,
        Column(
          children: [
            Builder(
              builder: (context) {
                DuoDevice.regionsOf(context);
                layouts++;
                return const SizedBox();
              },
            ),
            Builder(
              builder: (context) {
                DuoDevice.of(context);
                readers++;
                return const SizedBox();
              },
            ),
          ],
        ),
        size: innerLandscape,
      );
      await tester.pumpAndSettle();
      final (layoutsBefore, readersBefore) = (layouts, readers);

      for (final angle in [179.0, 178.0, 177.0]) {
        sink.success(openOnItsSide(angle: angle, status: 'partiallyOpen'));
        await tester.pumpAndSettle();
      }
      expect(readers, readersBefore + 3);
      expect(layouts, layoutsBefore);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('the column starts under the clock iOS reports, once settled', (
      tester,
    ) async {
      // On the outer screen the status bar's region grows a moment after
      // the window changes.
      var asked = 0;
      Map<String, Object?> outerScreen(double height) => {
            'available': true,
            'barEdge': 'right',
            'hinge': {'angle': 0.0, 'status': 'closed'},
            'folds': <Object?>[],
            'occlusions': [
              {
                'frame': [382.0, 0.0, 84.0, height],
                'margins': [0.0, 0.0, 0.0, 0.0],
                'active': true,
              },
            ],
          };
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final messenger = tester.binding.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(
        methods,
        (_) async => outerScreen(asked++ < 2 ? 84 : 174),
      );
      addTearDown(() => messenger.setMockMethodCallHandler(methods, null));
      late double top;
      await pumpDuo(
        tester,
        Builder(
          builder: (context) {
            top = SideToolbar.topOf(context);
            return const SizedBox();
          },
        ),
      );
      await tester.pump();
      expect(top, 92);
      await tester.pump(const Duration(seconds: 1));
      expect(top, 182);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('a screen reads the hinge as it moves', (tester) async {
      await answer(
        tester,
        openOnItsSide(),
        later: [openOnItsSide(angle: 100, status: 'partiallyOpen')],
      );
      late DuoDevice device;
      await pumpDuo(
        tester,
        Builder(
          builder: (context) {
            device = DuoDevice.of(context);
            return const SizedBox();
          },
        ),
        size: innerLandscape,
      );
      await tester.pumpAndSettle();
      expect(device.hinge!.angle, 100);
      expect(device.posture, DuoPosture.book);
      debugDefaultTargetPlatformOverride = null;
    });
  });
}
