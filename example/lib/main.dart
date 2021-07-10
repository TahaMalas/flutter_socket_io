import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:flutter/material.dart';

import 'data.dart';

const uri = 'https://tcp.disrupt-x.io:3004';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) =>
      super.createHttpClient(context)
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          print('host $host');
          print('port $port');
          print('cert ${cert.issuer}');
          return true;
        };
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SocketIOManager manager;
  SocketIO socket;

  @override
  void initState() {
    super.initState();
    manager = SocketIOManager();
    initSocket('default');
  }

  Future<void> initSocket(String identifier) async {
    StreamSubscription connectSubscription;
    StreamSubscription echoSubscription;

    final value = await SocketIOManager().createInstance(
      SocketOptions(
        // 'https://tcp.disrupt-x.io:13579',
        'https://deviot-back.disrupt-x.io',
        transports: [
          Transports.polling,
        ],
        auth: {
          'token':
              "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsImVtYWlsIjoiY3VzdG9tZXJAZGlzcnVwdC14LmlvIiwiaWF0IjoxNjI1OTI1NTA1LCJleHAiOjE2MjU5MjkxMDV9.AFugagYCyoYQWvndmzTwVdpPSdZOx9mhRKU3-JTuJf4",
        },
        path: '/socket/metrowatch',
        enableLogging: true,
      ),
    );
    socket = value;
    // Listen to socket connect event
    final subscription = socket.onConnect.listen((data) {
      print('connected: $data');
    }).onError((error) async {
      print('error is $error');
      await SocketIOManager().clearInstance(socket);
    });
    socket.on('connect_error').listen((event) {
      print('connect error $event');
    });
    await socket.connectSync();
    print('isConnected ${socket.isConnected()}');
  }

  @override
  void dispose() {
    SocketIOManager().clearInstance(socket);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            textTheme: const TextTheme(
              headline6: TextStyle(color: Colors.white),
              headline5: TextStyle(color: Colors.white),
              subtitle2: TextStyle(color: Colors.white),
              subtitle1: TextStyle(color: Colors.white),
              bodyText2: TextStyle(color: Colors.white),
              bodyText1: TextStyle(color: Colors.white),
              button: TextStyle(color: Colors.white),
              caption: TextStyle(color: Colors.white),
              overline: TextStyle(color: Colors.white),
              headline4: TextStyle(color: Colors.white),
              headline3: TextStyle(color: Colors.white),
              headline2: TextStyle(color: Colors.white),
              headline1: TextStyle(color: Colors.white),
            ),
            buttonTheme: ButtonThemeData(
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
                disabledColor: Colors.lightBlueAccent.withOpacity(0.5),
                buttonColor: Colors.lightBlue,
                splashColor: Colors.cyan)),
        home: Scaffold(),
      );
}
