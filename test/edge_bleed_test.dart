import 'package:iphone_duo/iphone_duo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

void main() {
  Widget row() => SizedBox(
        height: 120,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            for (var i = 0; i < 8; i++)
              SizedBox(width: 140, child: Card(child: Text('Card $i'))),
          ],
        ),
      );

  testWidgets('a row reaches through the column to the glass\'s edge', (
    tester,
  ) async {
    await pumpDuo(
      tester,
      Scaffold(
        body: SafeArea(
          left: false,
          right: false,
          child: Builder(
            builder: (context) => ListView(
              padding: EdgeBleed.sides(context),
              children: [
                const Text('Title'),
                EdgeBleed(child: row()),
              ],
            ),
          ),
        ),
      ),
    );
    final list = tester.getRect(find.byType(ListView).last);
    expect(list.left, 0);
    expect(list.right, outer.width);
    // The page's text keeps clear of the column.
    expect(
      tester.getTopRight(find.text('Title')).dx,
      lessThanOrEqualTo(outer.width - 84),
    );
  });

  testWidgets('in a column that scrolls it is as tall as its row', (
    tester,
  ) async {
    await pumpDuo(
      tester,
      Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              EdgeBleed(child: row()),
              const Text('Below'),
            ],
          ),
        ),
      ),
    );
    expect(tester.getTopLeft(find.text('Below')).dy, 120);
  });

  testWidgets('on a phone upright it is the row as it is', (tester) async {
    await pumpDuo(
      tester,
      Scaffold(body: row()),
      size: phone,
      insets: phoneInsets,
    );
    expect(tester.getRect(find.byType(ListView)).width, phone.width);
  });
}
