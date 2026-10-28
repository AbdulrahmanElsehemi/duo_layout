/// The iPhone Duo as its simulator reports it, for an app's widget tests:
/// the window, the insets, the fold and the hinge of each way it can be
/// held, and a [BarEdgeScope] built from them.
///
/// ```dart
/// import 'package:iphone_duo/testing.dart';
///
/// testWidgets('one mattress a half', (tester) async {
///   await tester.pumpWidget(
///     DuoSimulator.onItsSide.scope(child: const ComparePage()),
///   );
/// });
/// ```
library;

export 'src/simulator.dart';
