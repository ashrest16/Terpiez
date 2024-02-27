import 'package:flutter/material.dart';

class FirstTab extends StatelessWidget {
  const FirstTab({Key? key});

  @override
  Widget build(BuildContext context) {
    return  SafeArea(
      child: OrientationBuilder(
        builder: (context,orientation) {
          if (orientation == Orientation.portrait){
            return const Column(
              children: <Widget>[
                Text(
                  'Statistics',
                  style: TextStyle(fontSize: 48),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Terpiez Found: 12', style: TextStyle(fontSize: 20)),
                      Text('Days Active: 3', style: TextStyle(fontSize: 20)),
                    ],
                  ),
                ),
            ]
            );
          }
          else {
            return const Column(
                children: <Widget>[
                  Text(
                    'Statistics',
                    style: TextStyle(fontSize: 36),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Terpiez Found: 12', style: TextStyle(fontSize: 14)),
                        Text('Days Active: 3', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ]
            );
          }

        }
      ),
    );
  }
}