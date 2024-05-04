import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'home.dart';
import 'credentials.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'Terpiez',
        theme: ThemeData(useMaterial3: true),
        home: const HomeOrCredentials(),
      ),
    );
  }
}

class HomeOrCredentials extends StatelessWidget {
  const HomeOrCredentials({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<AppState>(context, listen: false).loadCredentials(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        return Provider.of<AppState>(context).needCredentials
            ? const Credentials()
            : const Home();
      },
    );
  }
}
