
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'home.dart';
import 'credentials.dart';
import 'shake.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'dart:ui';
import 'dart:io';
import 'dart:async';


final navigatorKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterLocalNotificationsPlugin p = FlutterLocalNotificationsPlugin();
  final NotificationAppLaunchDetails? notificationAppLaunchDetails = await p.getNotificationAppLaunchDetails();
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (context) => const Home(index: 1,)));
  }
  await initializeService();
  runApp(MyApp(notificationAppLaunchDetails: notificationAppLaunchDetails));
}

const notificationChannelId = 'my_foreground';
const notificationId = 888;

 Future<void> onSelectNotification(NotificationResponse response) async {
   navigatorKey.currentState?.push(
       MaterialPageRoute(builder: (context) => const Home(index: 1,)));
 }

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  bool sound = preferences.getBool("sound") ?? true;
  AndroidNotificationChannel channel = AndroidNotificationChannel(
    playSound: sound,
    sound: const RawResourceAndroidNotificationSound("notification"),
    notificationChannelId, // id
    'MY FOREGROUND SERVICE', // title
    description:
    'This channel is used for important notifications.', // description
    importance: Importance.high, // importance must be at low or higher level

  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

  if (Platform.isIOS || Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(
          iOS: DarwinInitializationSettings(),
          android: AndroidInitializationSettings('ic_bg_service_small'),
        ),
        onDidReceiveNotificationResponse: onSelectNotification,
    );
  }



  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,

      notificationChannelId: notificationChannelId, // this must match with notification channel you created above.
      foregroundServiceNotificationId: notificationId,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
    ),
  );
  service.startService();
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);

  return true;
}

Future<void> onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });
  SharedPreferences preferences = await SharedPreferences.getInstance();
  // bring to foreground
  Timer.periodic(const Duration(seconds: 15), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        await preferences.reload();
        double? distance = preferences.getDouble("distance");
        if (distance! <= 20.00) {
          flutterLocalNotificationsPlugin.show(
            notificationId,
            'A Terpiez is near!',
            'Its ${distance.toStringAsFixed(1)}m away! Catch it before it escapes.',
            payload: 'Second Tab',
            const NotificationDetails(
              android: AndroidNotificationDetails(
                notificationChannelId,
                'MY FOREGROUND SERVICE',
                icon: 'ic_bg_service_small',
                ongoing: true,
                priority: Priority.high,
                importance: Importance.max,
              ),
            ),
          );
        }
      }
    }
  });
}

class MyApp extends StatelessWidget {
  final NotificationAppLaunchDetails? notificationAppLaunchDetails;
  const MyApp({Key? key, this.notificationAppLaunchDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<AppState>
            (create: (context) => AppState()),
          ChangeNotifierProvider<Shake>(
              create: (context) => Shake()),
        ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Terpiez',
        theme: ThemeData(useMaterial3: true),
        home: HomeOrCredentials(notificationAppLaunchDetails: notificationAppLaunchDetails),
      ),
    );
  }
}

class HomeOrCredentials extends StatefulWidget {

  final NotificationAppLaunchDetails? notificationAppLaunchDetails;
  const HomeOrCredentials({Key? key, this.notificationAppLaunchDetails}) : super(key: key);


  bool get didNotificationLaunchApp =>
      notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;

  int get _index => didNotificationLaunchApp ? 1 : 0;
  @override
  State<HomeOrCredentials> createState() => _HomeOrCredentialsState();
}

class _HomeOrCredentialsState extends State<HomeOrCredentials> {
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
            : Home(index: widget._index);
      },
    );
  }
}
