import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tu_commerce/function/Firebase.dart';
import 'package:tu_commerce/model/noticeApi.dart';
import 'package:tu_commerce/model/order.dart';
import 'package:tu_commerce/model/product.dart';
import 'package:tu_commerce/screen/chat.dart';
import 'dart:ui';  // Import dart:ui for ImageFiltered

import 'navigationbarCustomer.dart';

class CheckOut extends StatefulWidget {
  final Map<String, dynamic>  username;
  final Map<String, dynamic>? product;

  CheckOut({Key? key, required this.username,this.product}) : super(key: key);

  @override
  State<CheckOut> createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOut> {
  Orders? order;
  final NotificationService _notificationService = NotificationService();
  @override
  void initState() {
    super.initState();
    setState(() {
      order = Orders(); 
      order?.buyer = widget.username; // set Username
      order?.product = widget.product; // set product คนขายจะอยู่ใร product
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Container(),
          SizedBox(
            height: screenHeight * 0.6,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: double.infinity,
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Image.network(
                        widget.product!['link'],
                        colorBlendMode: BlendMode.lighten,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Image.network(
                    widget.product!['link'],
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                height: screenHeight * 0.35,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.product!['price'].toStringAsFixed(2) + " ฿",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                            color: Color.fromRGBO(54, 91, 109, 1.0)
                          ),
                        ),
                        Spacer(),
                        Text(
                          "@" + widget.product!['seller']['username'].toString(),
                          style: const TextStyle(
                            fontSize: 20,
                            color: Color.fromRGBO(54, 91, 109, 1.0)
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Text(
                        widget.product!['prodName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 35,
                          color: Color.fromRGBO(54, 91, 109, 1.0)
                        ),
                      ),
                    ),
                    Text(
                      widget.product!['details'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color.fromRGBO(54, 91, 109, 1.0)
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 30,
            right: 30,
            child: ElevatedButton(
              style: ButtonStyle(
                textStyle: MaterialStateProperty.all(const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 15)),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))
              ),
              onPressed: () async{
                print('-----------');
                
                order!.time = DateTime.now(); // เพิ่มเวลา
                if (widget.username.containsKey('Credit') == false){ // ยังไม่เพิ่ม บัตร Credit
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No credit.')),
                    );
                } else {
                  DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('Credit').doc(widget.username['Credit']).get(); 
                  Map<String, dynamic> credit = snapshot.data() as  Map<String, dynamic>;
                  if (widget.username.containsKey('Credit') && credit['balance'] >= widget.product!['price']){ // กรณีเงินพอ จะเข้าเคสนี้
                    String? id = await getUserIDByEmail(widget.username['email']);
                    String nameRoom = widget.username['username'] + '-' + widget.product!['seller']['username']; // เซฟแชทรูม // ชื่อแชท buyer-seller ใช้ username
                    await FirebaseFirestore.instance.collection('ChatRoom').doc(nameRoom).set({ // สร้าง Chat Room
                      'roomName':nameRoom,
                      'customer':widget.username,
                      'seller':widget.product!['seller']
                    }); 
                  
                    await FirebaseFirestore.instance.collection('users').doc(id).collection('ChatRoomId').doc(nameRoom).set({ // สร้าง chat username
                      nameRoom:nameRoom
                    });
                  
                    await FirebaseFirestore.instance.collection('ChatRoom').doc(nameRoom).collection('Message').add({
                      // สร้างส่ง รูปเข้าไปในแชท
                        'sender':widget.username['username'],
                        'reciever':widget.product!['seller']['username'],
                        'time':FieldValue.serverTimestamp(),
                        'message':widget.product!['prodName'],
                        'link':widget.product!['link'],
                        'latitude': null,
                        'longitude': null,
                    });
                  
                    await saveOrderDB(order!); // save Order
                    await FirebaseFirestore.instance.collection('Credit').doc(widget.username['Credit']).update({
                    'balance': double.parse(credit['balance'].toString()) - double.parse(widget.product!['price'].toString()) }  ); // หัก credit user
                    // await updateUser(widget.username,widget.product,'No');
                    print('map order ---------------');
                    // print(order as Map<String, dynamic>);
                    // Map<String, dynamic> orderMap = order!.toMap();
                    Map<String, dynamic> orderMap =
                      {
                        'roomName':nameRoom,
                        'customer':widget.username,
                        'seller':widget.product!['seller']
                      };
                    Map<String,dynamic> data = {
                      'status':'Get Order',
                      'time' : DateTime.now(),
                      'sellerName' : order!.product!['seller']['username'],
                      'customer' : order!.buyer!['username'],
                      'product':widget.product
                    };
                    print('Notice-----------------------');
                    DocumentReference noticeRef = FirebaseFirestore.instance.collection("Notice").doc("seller"+order!.product!['seller']['username'].toString());
                    final docSnapshot = await noticeRef.get();
                    if (!docSnapshot.exists) {
                      await noticeRef.set(
                          {
                            "noticeList" : [data],
                            "length":0
                          }
                      );
                    }else{
                      await noticeRef.update({"noticeList":FieldValue.arrayUnion([data])});
                    }
                    if (order!.product!['seller'].containsKey('tokenNotice')){
                      await _notificationService.requestNotificationPermissions();
                        // print("Token: " + widget.username['tokenNotice']);
                      await sendNotificationToUser(order!.product!['seller']['tokenNotice'], "Fuck You Anny", "Fuck You Anny");
                      await _notificationService.sendNotification(widget.username['tokenNotice'],'Hello');
                    }
                    Navigator.pushReplacement(
                      context, 
                      // MaterialPageRoute(builder: (context) => NavigationCustomer(email: widget.username['email'],temp: 8,order: orderMap,chatName: widget.product!['seller']['fname'] + ' ' + widget.product!['seller']['lname'],))
                      
                      MaterialPageRoute(builder: (context) => ChatScreen(username: widget.username,order: orderMap,seller: widget.product!['seller']['fname'] + ' ' + widget.product!['seller']['lname'],))
                                         
                    );
                  }else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Your balance is not enough.')),
                      );
                  }
                }
              }, 
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart),
                  SizedBox(width: 15,),
                  Text('Check Out'),
                ],
              )
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: RawMaterialButton(
              padding: EdgeInsets.all(10),
              constraints: const BoxConstraints(minWidth: 36),
              shape: const CircleBorder(),
              fillColor: const Color.fromRGBO(54, 91, 109, 1.0),
              onPressed: () => Navigator.of(context).pop(),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white,),
            )
          )
        ],
      ),
    );
  }
}