import 'package:flutter/material.dart';
import 'app_state.dart';
import 'package:provider/provider.dart';

class PreferenceTab extends StatelessWidget{
  const PreferenceTab({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
      ),
      body: const BodyLayout(),
    );
  }
}

class BodyLayout extends StatelessWidget{
  const BodyLayout({super.key});
  @override
  Widget build(BuildContext context){
    final appProvider = Provider.of<AppState>(context, listen: true);
    return ListView(
      children: <Widget>[
        SwitchListTile(
          title: const Text('Play Sounds: ',style: TextStyle(fontSize: 16),),
          value: appProvider.Sound,
          onChanged: (bool value){
            appProvider.setSound(value);
          },
        ),
        ListTile(
          title: const Text('Reset User',style: TextStyle(fontSize: 16)),
          onTap: (){
               showDialog(
                   context: context,
                   builder: (BuildContext context){
                     return AlertDialog(
                       icon: const Icon(Icons.highlight_off_rounded),
                       title: const Text("Clear User Data?"),
                       content: const Text('This is a destructive action,\n'
                           ' and will delete all of your \n '
                           'progress. Do you really want to proceed?'),
                       actions: [
                         ElevatedButton(
                             onPressed: ()
                             {
                               Navigator.of(context).pop();
                             },
                             child: const Text('No, cancel and keep my data')),
                         ElevatedButton(
                             onPressed: ()
                             {
                               appProvider.resetUser(context);
                             },
                             child: const Text('Yes, really clear'))
                       ],
                     );
                   });
          },
        )
      ],
    );
  }
}