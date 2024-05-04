import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:terpiez/main.dart';

class Credentials extends StatefulWidget {
  const Credentials({super.key});

  @override
  CredentialsState createState() => CredentialsState();
}

class CredentialsState extends State<Credentials> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final FlutterSecureStorage storage = FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add login details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _username,
              decoration: const InputDecoration(labelText: 'Enter Username'),
            ),
            TextField(
              controller: _password,
              decoration: const InputDecoration(labelText: 'Enter Password'),
            ),
            ElevatedButton(
              child: const Text('Confirm'),
              onPressed: () async {
                await storage.write(key: 'dbUsername', value: _username.text);
                await storage.write(key: 'dbPassword', value: _password.text);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyApp(),
                  ),
                      (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
