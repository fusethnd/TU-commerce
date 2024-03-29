import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tu_commerce/function/Firebase.dart';
import 'package:tu_commerce/screen/addProduct.dart';
import 'package:tu_commerce/screen/navigationbarSeller.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {

  late Map<String, dynamic> userData;
  bool isLoading = true; 

  Future getData(String email) async{
    Map<String, dynamic> temp = await getUserByEmail(email) as Map<String, dynamic>;
    setState(() {
      userData = temp;
      isLoading = false;
    });
  }
  
  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    String? email = user!.email;
    print(email);
    getData(email!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stock'),),

      body: isLoading ? const Center(child: CircularProgressIndicator()) 
      :ElevatedButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context){
              return AddProduct(username: userData);
          }
        ));
        }, 
        child: const Text('add')
      )
    
    );
  }
}