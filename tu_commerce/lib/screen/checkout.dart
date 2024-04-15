import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tu_commerce/function/Firebase.dart';
import 'package:tu_commerce/model/order.dart';
import 'package:tu_commerce/model/product.dart';
import 'package:tu_commerce/screen/chat.dart';

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
    return Scaffold(
      appBar: AppBar(title: Text(widget.product!['prodName']),), 
      body: Column(
        children: [
          Image.network(widget.product!['link']),
          Text(widget.product!['price'].toString()),
          Text(widget.product!['prodName']),
          Text(widget.product!['details']),
          ElevatedButton(
            onPressed: () async{
              print('-----------');
              
              order!.time = DateTime.now(); // เพิ่มเวลา
              if (widget.username.containsKey('Credit') == false){ // ยังไม่เพิ่ม บัตร Credit
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ไปเพิ่ม Credit ก่อนไอเวร')),
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
                      'message':null,
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
                  Map<String, dynamic> orderMap = order!.toMap();
                  Navigator.pushReplacement(
                    context, 
                    MaterialPageRoute(builder: (context) => NavigationCustomer(email: widget.username['email'],temp: 8,order: orderMap,))
                  );
                }else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('เงินไม่พอ ไอเวร')),
                    );
                }
              }
            }, 
            child: const Text('check out'))
        ],
      ),
    );
  }
}