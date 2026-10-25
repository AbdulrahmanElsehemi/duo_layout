import 'package:duo_layout/duo_layout.dart';
import 'package:flutter/material.dart';

import 'data.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/saved_page.dart';
import 'pages/shop_page.dart';

/// The app's tabs: a bottom bar on a phone, an iPad and the iPhone Duo open
/// upright; a [SideTabBar] down the status bar's column on the Duo closed,
/// or open on its side.
class Shell extends StatefulWidget {
  const Shell({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  late var _index = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (Icons.home_outlined, Icons.home, tr(context, 'Home', 'الرئيسية')),
      (
        Icons.storefront_outlined,
        Icons.storefront,
        tr(context, 'Shop', 'المتجر'),
      ),
      (
        Icons.favorite_border,
        Icons.favorite,
        tr(context, 'Saved', 'المحفوظات'),
      ),
      (Icons.person_outline, Icons.person, tr(context, 'Profile', 'حسابي')),
    ];
    void select(int index) => setState(() => _index = index);

    return Scaffold(
      body: SideTabBar(
        tabs: [
          for (final (icon, selected, label) in tabs)
            SideTab(
              icon: Icon(icon),
              selectedIcon: Icon(selected),
              label: label,
            ),
        ],
        currentIndex: _index,
        onTap: select,
        child: IndexedStack(
          index: _index,
          children: const [HomePage(), ShopPage(), SavedPage(), ProfilePage()],
        ),
      ),
      bottomNavigationBar:
          SideTabBar.show(context)
              ? null
              : NavigationBar(
                selectedIndex: _index,
                onDestinationSelected: select,
                destinations: [
                  for (final (icon, selected, label) in tabs)
                    NavigationDestination(
                      icon: Icon(icon),
                      selectedIcon: Icon(selected),
                      label: label,
                    ),
                ],
              ),
    );
  }
}
