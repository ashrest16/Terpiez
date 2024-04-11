import 'package:flutter/material.dart';
import 'package:terpiez/app_state.dart';
import 'package:provider/provider.dart';

class FirstTab extends StatelessWidget {
   const FirstTab({super.key});

  @override

  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    final provider = Provider.of<AppState>(context);
    final id = provider.id;
    final initialDate = provider.initialDate;
    final terpiez = provider.terpiez;
    final difference = now.difference(initialDate).inDays;
    return SafeArea(
      child: OrientationBuilder(
        builder: (context,orientation) {
          if (orientation == Orientation.portrait){
            return  Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  const Text(
                    'Statistics',
                    style: TextStyle(fontSize: 48),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Terpiez Found: $terpiez', style: const TextStyle(fontSize: 20)),
                      Text('Days Active: $difference', style: const TextStyle(fontSize: 20)),
                    ],
                  ),
                  SizedBox(
                    height: 400,
                    child: Center(
                      child: Text('User: $id', style: const TextStyle(fontSize: 12),),
                    ),
                  )
              ]
              ),
            );
          }
          else {
            return  Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  children: <Widget>[
                    const Text(
                      'Statistics',
                      style: TextStyle(fontSize: 36),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Terpiez Found: $terpiez', style: const TextStyle(fontSize: 18)),
                          Text('Days Active: $difference', style: const TextStyle(fontSize: 18)),
                      SizedBox(
                        height: 100,
                        child: Center(
                          child: Text('User: $id', style: const TextStyle(fontSize: 18),),
                        ),
                      ),

                        ],
                      ),
                    ),
                  ]
              ),
            );
          }

        }
      ),
    );
  }
}