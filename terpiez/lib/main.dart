import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Thirdtab.dart';
import 'SecondTab.dart';
import 'FirstTab.dart';
import 'AppState.dart';


void main() {
  runApp(ChangeNotifierProvider<AppState>(
    create: (context) => AppState(), child: const MyApp()
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Terpiez',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const Home()
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          title: const Text('Terpiez'),
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
