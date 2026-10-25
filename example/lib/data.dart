import 'package:flutter/material.dart';

/// [en] or [ar], by the app's language.
String tr(BuildContext context, String en, String ar) =>
    Localizations.localeOf(context).languageCode == 'ar' ? ar : en;

class Product {
  const Product(this.en, this.ar, this.price, this.icon, this.color);

  final String en;
  final String ar;
  final int price;
  final IconData icon;
  final Color color;

  String name(BuildContext context) => tr(context, en, ar);
}

const products = [
  Product(
    'Linen Sofa',
    'كنبة كتان',
    1290,
    Icons.weekend_outlined,
    Color(0xFFDCE7F3),
  ),
  Product(
    'Oak Chair',
    'كرسي بلوط',
    240,
    Icons.chair_outlined,
    Color(0xFFF3E6D8),
  ),
  Product(
    'Cloud Bed',
    'سرير كلاود',
    980,
    Icons.bed_outlined,
    Color(0xFFE3EEE4),
  ),
  Product(
    'Floor Lamp',
    'أباجورة أرضية',
    160,
    Icons.light_outlined,
    Color(0xFFF5EED3),
  ),
  Product('Wool Rug', 'سجادة صوف', 420, Icons.texture, Color(0xFFEDE1EE)),
  Product(
    'Side Table',
    'ترابيزة جانبية',
    190,
    Icons.table_bar_outlined,
    Color(0xFFE0ECEF),
  ),
  Product(
    'Writing Desk',
    'مكتب كتابة',
    560,
    Icons.desk_outlined,
    Color(0xFFF1E3DD),
  ),
  Product('Bookshelf', 'مكتبة كتب', 610, Icons.shelves, Color(0xFFE6E9F5)),
];

/// The product's picture: its colour with its icon on it.
class ProductPicture extends StatelessWidget {
  const ProductPicture(
    this.product, {
    super.key,
    this.iconSize = 48,
    this.radius = 16,
  });

  final Product product;
  final double iconSize;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: product.color,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Center(
        child: Icon(
          product.icon,
          size: iconSize,
          color: const Color(0xFF3A4A5C),
        ),
      ),
    );
  }
}

String price(BuildContext context, int value) =>
    tr(context, '\$$value', '$value\$');
