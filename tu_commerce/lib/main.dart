import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:tu_commerce/model/noticeApi.dart';
import 'package:tu_commerce/screen/navigationbarCustomer.dart';
import 'package:tu_commerce/screen/navigationbarSeller.dart';
import 'firebase_options.dart';
import 'screen/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final _firebaseMessage = FirebaseMessaging.instance;
  await _firebaseMessage.requestPermission();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

}


class _MyAppState extends State<MyApp> {
  var auth = FirebaseAuth.instance;
  var isLogin = false;

  checkLogin() async {
    auth.authStateChanges().listen((User? user) {
      if (user != null && mounted) {
        setState(() {
          isLogin = true;
        });
      }
    });
  }

  @override
  void initState() {
    checkLogin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color.fromRGBO(242, 241, 236, 1),
          appBarTheme: const AppBarTheme(backgroundColor: Color.fromRGBO(242, 241, 236, 1)),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(const Color.fromRGBO(54, 91, 109, 1.0)),
              foregroundColor: MaterialStateProperty.all(const Color.fromRGBO(255, 255, 255, 1)),
              textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 16,),),
              padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal:40),),
            ),
          )
          
        ),
        home: const HomeScreen());
  }
}
