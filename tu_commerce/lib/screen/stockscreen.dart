import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tu_commerce/function/Firebase.dart';
import 'package:tu_commerce/screen/addProduct.dart';
import 'package:tu_commerce/screen/navigationbarSeller.dart';

class StockScreen extends StatefulWidget {
  final Map<String, dynamic> email;
  
  StockScreen({Key? key, required this.email}) : super(key: key);
  // const Profile({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stock'),),

      body: ElevatedButton(
        onPressed: (){
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context){
              return Navigation(username: widget.email, temp: 5);
          }
        ),(Route<dynamic> route) => false);
        }, 
        child: const Text('add')
      )
    
    );
  }
}