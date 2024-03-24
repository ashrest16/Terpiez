import 'package:flutter/material.dart';
import 'package:terpiez/AppState.dart';
import 'package:provider/provider.dart';

class FirstTab extends StatelessWidget {
   const FirstTab({super.key});

  @override

  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    return Consumer<AppState>(
      builder: (context, value, child){
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
                            Text('Terpiez Found: ${value.appdata.terpiez}', style: const TextStyle(fontSize: 20)),
                            Text('Days Active: ${now.difference(value.appdata.initialDate).inDays}', style: const TextStyle(fontSize: 20)),
                          ],
                        ),
                        SizedBox(
                          height: 500,
                          child: Center(
                            child: Text('User: ${value.appdata.id}', style: const TextStyle(fontSize: 16),),
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
                                Text('Terpiez Found: ${value.appdata.terpiez}', style: const TextStyle(fontSize: 18)),
                                Text('Days Active: ${now.difference(value.appdata.initialDate).inDays}', style: const TextStyle(fontSize: 18)),
                            SizedBox(
                              height: 150,
                              child: Center(
                                child: Text('User: ${value.appdata.id}', style: const TextStyle(fontSize: 18),),
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
      );
  }
}