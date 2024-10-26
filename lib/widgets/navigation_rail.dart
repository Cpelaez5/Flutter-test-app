import 'package:flutter/material.dart';

class CustomNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final String? userRole;

  const CustomNavigationRail({
    Key? key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.userRole,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      extended: MediaQuery.of(context).size.width >= 600,
      destinations: [
        NavigationRailDestination(
          icon: Icon(Icons.storefront),
          label: Text('Shop'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.favorite),
          label: Text('Favorites'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.search),
          label: Text('Search'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person),
          label: Text('User Profile'),
        ),
        if (userRole == 'cliente')
          NavigationRailDestination(
            icon: Icon(Icons.shopping_cart),
            label: Text('Cart'),
          ),
        if (userRole == 'administrador')
          NavigationRailDestination(
            icon: Icon(Icons.admin_panel_settings),
            label: Text('Admin'),
          ),
      ],
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
    );
  }
}