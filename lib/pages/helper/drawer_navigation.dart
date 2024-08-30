import 'package:flutter/material.dart';

class DrawerNavigation extends StatefulWidget {
  const DrawerNavigation({Key? key}) : super(key: key);

  @override
  State<DrawerNavigation> createState() => _DrawerNavigationState();
}

class _DrawerNavigationState extends State<DrawerNavigation> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Drawer(
      child: ListView(children: <Widget>[
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text('Home'),
          onTap: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
        ListTile(
          leading: const Icon(Icons.monetization_on),
          title: const Text('Transactions'),
          onTap: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.pushReplacementNamed(context, '/transactions');
          },
        ),
        ListTile(
          leading: const Icon(Icons.autorenew_rounded),
          title: const Text('Recurrings'),
          onTap: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.pushReplacementNamed(context, '/recurring');
          },
        ),
        ListTile(
          leading: const Icon(Icons.category),
          title: const Text('Categories'),
          onTap: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.pushReplacementNamed(context, '/categories');
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete),
          title: const Text('Trash'),
          onTap: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.pushReplacementNamed(context, '/trash');
          },
        ),
        const Divider(color: Colors.black87),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/settings');
          },
        )
      ]),
    ));
  }
}
