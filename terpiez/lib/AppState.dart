import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

class AppData {
  int terpiez;
  final String id;
  DateTime initialDate;

  AppData({required this.terpiez, required this.id, required this.initialDate});
}

class AppState extends ChangeNotifier {
  AppData appdata = AppData(
    terpiez: 0,
    id: const Uuid().v4(),
    initialDate: DateTime.now()
  );

}
