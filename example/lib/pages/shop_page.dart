import 'package:iphone_duo/iphone_duo.dart';
import 'package:flutter/material.dart';

import '../data.dart';
import 'product_page.dart';

/// The products as a list. On a wide window — the iPhone Duo open on its
/// side, an iPad — the product picked opens beside the list rather than over
/// it: the list one side of the fold, the product the other.
class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  var _selected = 0;

  @override
  Widget build(BuildContext context) {
    final twoPanes = TwoPane.fits(context);
    final list = Scaffold(
      appBar: DuoAppBar(title: Text(tr(context, 'Shop', 'المتجر'))),
      body: ListView.separated(
        padding: EdgeBleed.padding(
          context,
          const EdgeInsets.fromLTRB(16, 8, 16, 120),
        ),
        itemCount: products.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final product = products[i];
          return Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            color:
                twoPanes && i == _selected
                    ? Theme.of(context).colorScheme.secondaryContainer
                    : Theme.of(context).colorScheme.surface,
            child: ListTile(
              contentPadding: const EdgeInsets.all(8),
              leading: SizedBox.square(
                dimension: 56,
                child: ProductPicture(product, iconSize: 28, radius: 12),
              ),
              title: Text(product.name(context)),
              subtitle: Text(price(context, product.price)),
              trailing: const Icon(Icons.chevron_right),
              onTap:
                  () =>
                      twoPanes
                          ? setState(() => _selected = i)
                          : Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ProductPage(product),
                            ),
                          ),
            ),
          );
        },
      ),
    );
    if (!twoPanes) return list;

    final product = products[_selected];
    return TwoPane(
      start: list,
      end: Scaffold(
        appBar: DuoAppBar(
          title: Text(product.name(context)),
          actions: productActions(context),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 260,
              // Clear of the status bar's column beside this pane.
              child: SafeArea(
                top: false,
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: ProductPicture(product, iconSize: 96, radius: 24),
                ),
              ),
            ),
            Expanded(child: ProductDetails(product)),
          ],
        ),
      ),
    );
  }
}
