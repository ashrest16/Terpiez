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

  int get terpiez => appdata.terpiez;
  String get id => appdata.id;
  DateTime get initialDate => appdata.initialDate;

  void updateTerpiez() {
    appdata.terpiez += 1;
    notifyListeners(); // Notify listeners that the state has changed
  }


}
