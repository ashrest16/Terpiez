import 'package:flutter/material.dart';

class ThirdTab extends StatelessWidget {
  const ThirdTab({Key? key});

  @override
  Widget build(BuildContext context) {
    final items = ['Bug', 'Plane'];
    final icons = [Icons.bug_report_rounded, Icons.airplanemode_active];
    return ListView.builder(
      itemCount: 2,
      itemBuilder: (context, index) {
        String itemTitle = items[index];
        IconData itemIcon = icons[index];
        return ListTile(
          title: Text(items[index]),
          leading: Icon(icons[index]),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtherView(itemIcon: itemIcon),
                settings: RouteSettings(arguments: items[index]),
              ),
            );
          },
        );
      },
    );
  }
}

class OtherView extends StatelessWidget {
  final IconData itemIcon;

  OtherView({required this.itemIcon, Key? key});

  @override
  Widget build(BuildContext context) {
    final itemTitle = ModalRoute
        .of(context)!
        .settings
        .arguments as String;

    return Scaffold(
      appBar: AppBar(title: Text(itemTitle),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) =>
           Center(
            child: Column(
              children: [
                Icon(itemIcon, size: 0.5 * constraints.biggest.shortestSide),
                Text(itemTitle, style: const TextStyle(fontSize: 48),),
              ],
            ),
          ),
    ),
    );
  }
}
