import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tu_commerce/screen/display.dart';
import 'package:tu_commerce/screen/formscreen.dart';
import 'package:tu_commerce/screen/register_screen.dart';

import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          body: TabBarView(
            children: [RegisterScreen(), DisplayScreen()],
          ),
          backgroundColor: Colors.greenAccent,
          bottomNavigationBar: TabBar(tabs: [
            Tab(text: "Add Score"),
            Tab(
              text: "Student List",
            )
          ]),
        ));
  }
}
