import 'package:duo_layout/duo_layout.dart';
import 'package:flutter/material.dart';

import '../data.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.receipt_long_outlined, tr(context, 'Orders', 'الطلبات')),
      (Icons.location_on_outlined, tr(context, 'Addresses', 'العناوين')),
      (Icons.credit_card, tr(context, 'Payment', 'الدفع')),
      (Icons.language, tr(context, 'Language', 'اللغة')),
      (Icons.help_outline, tr(context, 'Help', 'المساعدة')),
    ];
    return Scaffold(
      appBar: DuoAppBar(title: Text(tr(context, 'Profile', 'حسابي'))),
      body: ListView(
        padding: EdgeBleed.padding(
          context,
          const EdgeInsets.fromLTRB(16, 8, 16, 120),
        ),
        children: [
          for (final (icon, label) in items)
            ListTile(
              leading: Icon(icon),
              title: Text(label),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
        ],
      ),
    );
  }
}
