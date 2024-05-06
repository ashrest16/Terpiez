
import 'dart:async';
import 'dart:math';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class Shake extends ChangeNotifier{
  bool _shake = false;
   late StreamSubscription<UserAccelerometerEvent> _accelerometerSubscription;

   Shake(){
     _accelerometerSubscription = userAccelerometerEventStream().listen((event) {
       final acc =
       sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
       if (acc > 10.0) {
         _shake = true;
         notifyListeners();
       }
       else{
         _shake = false;
         notifyListeners();
       }
     });
   }

   bool get shake => _shake;

  @override
  void dispose() {
    _accelerometerSubscription.cancel();
    super.dispose();
  }

}
