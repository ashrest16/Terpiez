// import 'dart:async';
//
// import 'package:provider/provider.dart';
// import 'package:flutter/material.dart';
// import 'package:sensors_plus/sensors_plus.dart';
//
// class Shake extends ChangeNotifier{
//   StreamSubscription? motion;
//
//   Shake(){
//     _setState();
//   }
//
//   Future<void> _setState() async{
//     userAccelerometerEventStream().listen(
//         (AccelerometerEvent event) {
//             print(event);
//         },
//     );
//   }
//
// }