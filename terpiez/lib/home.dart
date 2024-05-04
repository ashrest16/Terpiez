import 'package:flutter/material.dart';
import 'first_tab.dart';
import 'second_tab.dart';
import 'third_tab.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          title: const Text('Terpiez', style: TextStyle(fontSize: 30),),
          toolbarHeight: isLandscape ? 30 : 60,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Stats', icon: Icon(Icons.auto_graph)),
              Tab(text: 'Finder', icon: Icon(Icons.search)),
              Tab(text: 'List', icon: Icon(Icons.format_list_bulleted)),
            ],
          ),
        ),
        body:  const TabBarView(
          children: [FirstTab(), SecondTab(), ThirdTab(),],
        ),
      ),
    );
  }

}