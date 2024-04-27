import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tu_commerce/function/Firebase.dart';
import 'package:tu_commerce/screen/addProduct.dart';
import 'package:tu_commerce/screen/navigationbarSeller.dart';
import 'package:tu_commerce/screen/productBox.dart';

class StockScreen extends StatefulWidget {
  final Map<String, dynamic> email;
  
  StockScreen({Key? key, required this.email}) : super(key: key);
  // const Profile({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {

  List<Map<String, dynamic>>? allProduct;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _init();
  }
  Future<void> _init() async{
    List<Map<String, dynamic>> temp = await getProductsByUsername(widget.email['username']);
    print('-------- fuck you');
    print(temp);
    if(mounted){
      setState(() {
        allProduct = temp;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    // print('----------');
    // print(allProduct);
    return Scaffold(
      appBar: AppBar(title: const Text('My Stock'),),

      body: Column(
        children: [
          Expanded(
          child: ListView.builder(
              itemCount: allProduct!.length,
              itemBuilder: (context,index) {
                Map<String,dynamic> item = allProduct![index];
                print(item);
                print(allProduct);

              }
            )
          )
        ],
      ),

      




      // ElevatedButton(
      //   onPressed: (){
      //     Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context){
      //         return Navigation(username: widget.email, temp: 5);
      //     }
      //   ),(Route<dynamic> route) => false);
      //   }, 
      //   child: const Text('add')
      // )
    
    );
  }
}