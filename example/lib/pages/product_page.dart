import 'package:iphone_duo/iphone_duo.dart';
import 'package:flutter/material.dart';

import '../data.dart';

/// A product's page, pushed from a list. On a wide window its picture and
/// its details stand in two panes, one each side of the fold.
class ProductPage extends StatelessWidget {
  const ProductPage(this.product, {super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final picture = SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ProductPicture(product, iconSize: 120, radius: 24),
      ),
    );
    return Scaffold(
      appBar: DuoAppBar(
        title: Text(product.name(context)),
        actions: productActions(context),
      ),
      body:
          TwoPane.fits(context)
              ? TwoPane(start: picture, end: ProductDetails(product))
              : Column(
                children: [
                  SizedBox(
                    height: 300,
                    child: SafeArea(top: false, bottom: false, child: picture),
                  ),
                  Expanded(child: ProductDetails(product)),
                ],
              ),
    );
  }
}

/// Share and save: in the bar, or down the column on the iPhone Duo.
List<DuoAction> productActions(BuildContext context) => [
  DuoAction(
    icon: const Icon(Icons.ios_share),
    tooltip: tr(context, 'Share', 'مشاركة'),
    onPressed: () {},
  ),
  DuoAction(
    icon: const Icon(Icons.favorite_border),
    tooltip: tr(context, 'Save', 'حفظ'),
    onPressed: () {},
  ),
];

/// The name, price, words and the Add to bag button. The button has words,
/// so it stays in a bar across the foot, on the iPhone Duo too.
class ProductDetails extends StatelessWidget {
  const ProductDetails(this.product, {super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name(context),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              price(context, product.price),
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              tr(
                context,
                'Made to last, from materials picked by hand. Free delivery and '
                    'a hundred nights to try it at home.',
                'معمول يعيش، من خامات متنقية بالإيد. توصيل مجاني و١٠٠ ليلة '
                    'تجربه في البيت.',
              ),
              style: theme.textTheme.bodyMedium,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () {},
                child: Text(tr(context, 'Add to bag', 'أضف للحقيبة')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
