import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tu_commerce/screen/addProduct.dart';
import 'package:tu_commerce/screen/inboxScreen.dart';
import 'package:tu_commerce/screen/navigationbarCustomer.dart';
import 'package:tu_commerce/screen/navigationbarSeller.dart';
import 'package:tu_commerce/screen/profileScreen.dart';
import 'package:tu_commerce/screen/stockscreen.dart';
import 'package:tu_commerce/screen/historySeller.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:tu_commerce/screen/walletscreen.dart';
import 'package:tu_commerce/function/Firebase.dart';

class SellerHome extends StatefulWidget {
  final Map<String, dynamic> username;
  
  SellerHome({Key? key, required this.username}) : super(key: key);

  @override
  State<SellerHome> createState() => _SellerHomeState();
}

class _SellerHomeState extends State<SellerHome> {

  // Map<String, dynamic>? userData;
  late Map<String, dynamic> userData; // Holding user
  bool isLoading = true; 
  
  // เอาไว้หาว่าตอนนี้ user คือใครไปหาใน firebase, getUserByEmail อยู่ใน folder fuction
  Future getData(String email) async{
    Map<String, dynamic> temp = await getUserByEmail(email) as Map<String, dynamic>;
    setState(() {
      userData = temp;
      isLoading = false;
      
    });
  }
  
  // เริ่มต้นให้มันหาว่าตอนนี้ที่ login อยู่ user อะไร
  @override
  void initState() {
    User? user = FirebaseAuth.instance.currentUser;
    String? email = user!.email;
    super.initState();
    getData(email!);
    print(widget.username['shoppingMode']);
  }
  // ใส่ container เข้าไป
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: isLoading ? const Center(child: CircularProgressIndicator()) // เอาไว้เช็คว่า query เสร็จยังถ้ายังมันจะหมุนๆ
          : Column(
              children: [
                // ตอนนี้โชว์แค่ ชื่อ หาต่อได้ที่ userDataมีตามใน firebase กับโชว์ลิ้งไป wallet
                Container( 
                  decoration: BoxDecoration(color: Colors.red),
                  height: 100,
                  child: Row(
                    children: [
                      Expanded(child: Text('${userData['fname']} ${userData['lname']}')), 
                      Expanded(child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context, MaterialPageRoute(
                              builder: (context){
                                return Navigation(username: widget.username,temp: 1);
                              }
                            )
                          );
                        },
                        child: const Text('MY WALLET'),))
                    ],
                  ),
                ),
                //-------------- จบ container แรก -------------------
                Container( // ทำตัวลิ้ง ไป stock กับอื่นแต่ตอนนี้ลิ้งมั่วนะ 
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {

                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    
                                    builder: (context) => Navigation(username: widget.username,temp: 7),
                                  ),(Route<dynamic> route) => false
                                );
                              },
                              child: const Text('TO SHIP'),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Navigation(username: widget.username,temp: 6),
                                  ),(Route<dynamic> route) => false
                                );
                              },
                              child: const Text('HISTORY'),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () async {

                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NavigationCustomer(email:widget.username['email'],temp: 4,),
                                  ),(Route<dynamic> route) => false
                                );
                              },
                              child: const Text('SHOPPING MODE'),
                            ),
                          ],
                        ),
                      ),  
                    ],
                  ),
                ),
                // จบ---- container 3 ปุ่ม-----------
                
                Container(
                  child: const Column(
                    children: [
                      Text('Shopping List')
                    ],
                  ),
                ),

              ],
            ),
    );
  }
}
