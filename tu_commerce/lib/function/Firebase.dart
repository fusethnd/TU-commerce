import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tu_commerce/model/order.dart';
import '../model/product.dart';


Future<Map<String, dynamic>?> getUserByEmail(String email) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: email).get();
  if (querySnapshot.docs.isNotEmpty) {
    DocumentSnapshot docSnapshot = querySnapshot.docs.first;
    return docSnapshot.data() as Map<String, dynamic>;

  }
  return null;
}

Future<String?> getUserIDByEmail(String email) async {
  var querySnapshot = await FirebaseFirestore.instance
      .collection("users")
      .where('email', isEqualTo: email)
      .get();
  if (querySnapshot.docs.isNotEmpty) {
    String documentId = querySnapshot.docs.first.id;
    return documentId;
  }
  return null;
}

Future<void> saveOrderDB(Orders order) async {
  try {
    
    await FirebaseFirestore.instance.collection('Orders').add(
        {
          'product':order.product,
          'username':order.buyer,
          'status':order.status,
          'date':order.time
        }
    );
    print('------------------------------------------');
    print('Order save successfull');
  } catch (e) {
    print('---------------- Error ------------- ');
    print(e);
  }
}

Future<void> saveProductDB(Product prod) async {
  try {
    await FirebaseFirestore.instance.collection('Product').add(
        {
          'prodName':prod.prodName,
          'price':prod.price,
          'prodID':prod.prodID,
          'details':prod.details,
          'category':prod.category,
          'imageUrl':prod.imageUrl,
          'instock' :prod.instock,
          'seller':prod.seller,
          'time':prod.time,
          'link':prod.linkUrl
        }
    );
    print('------------------------------------------');
    print('Product save successfull');
  } catch (e) {
    print('---------------- Error ------------- ');
    print(e);
  }
}


Future<void> saveHistory(order,id,user,type) async{
    DocumentReference  historyRef;
    String? docID;
    if (id == 'No'){
      final temp = FirebaseFirestore.instance.collection('History').doc();
      docID = temp.id;  
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: user['username']).get();
      querySnapshot.docs.forEach((doc) { 
        doc.reference.update(
          {'historyID':docID.toString()}
        );
      });
    }else{
      docID = id.toString();
    }
    print(docID);
    historyRef = FirebaseFirestore.instance.collection('History').doc(docID);
    final docSnapshot = await historyRef.get();
    if (!docSnapshot.exists) {
      print('here did not has');
      if (type == 'customer'){
        await historyRef.set({'ordersCustomer': [order]});
      }else{
        await historyRef.set({'ordersSeller': [order]});
      }
    } else {
      print('has');
      if (type == 'customer') {
        await historyRef.update({
          'ordersCustomer': FieldValue.arrayUnion([order]),
        });
      }else {
        await historyRef.update({
          'ordersSeller': FieldValue.arrayUnion([order]),
        });
      }
    }

}

Future<void> updateStatus(order,status,index) async { // update field status 
  QuerySnapshot querySnapshot =await FirebaseFirestore.instance.collection('Orders')
                                                                .where('product.prodID', isEqualTo: order['product']['prodID'])
                                                                .where('username.username',isEqualTo: order['username']['username']).get();
    order['status'] = status;
    querySnapshot.docs.forEach((doc) async { 
      await doc.reference.update(order);
    }
  );

}

Future<List<Map<String, dynamic>>> getMessages(chatId) async { 
  List<Map<String, dynamic>> messages = [];

  QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('ChatRoom').doc(chatId).collection('Message').orderBy('time',descending: true).get();
  querySnapshot.docs.forEach((doc) {
    Map<String, dynamic> messageData = doc.data() as Map<String, dynamic>;
    messages.add(messageData);
    // print(messageData);
  });

  return messages;
}

Future<Position> determinePosition() async {
  LocationPermission permission;

  permission = await Geolocator.checkPermission();

  if(permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if(permission == LocationPermission.denied) {
      return Future.error('Location Permissions are denied');
    }
  }
  return await Geolocator.getCurrentPosition();
}

Future<List<QueryDocumentSnapshot<Object?>>> getOrders(username,shoppingMode) async {// หยิบตาม shopping mode ถ้าเกิดเป็นโหมดคนซื้อก็จะหาแค่อันที่ตัวเองซื้อ ถ้าโหมดคนขายก็จะหาแค่โหมดที่ตัวเองได้ request
  QuerySnapshot querySnapshot;
  if (shoppingMode){
    querySnapshot = await FirebaseFirestore.instance
        .collection('Orders')
        .where('username.username', isEqualTo: username).get();
  }else{
    querySnapshot = await FirebaseFirestore.instance
        .collection('Orders')
        .where('product.seller.username', isEqualTo: username).get();
  }

  return querySnapshot.docs;
}

Future<List<dynamic>?> updateUser(Map<String, dynamic> user, Map<String, dynamic>? product,String status) async {
  List<dynamic>? favorites;

  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: user['username']).get(); // query data
    querySnapshot.docs.forEach((doc) async {
      // Get the existing favorites from the document data //remove
      favorites = user['favorite'] as List<dynamic>?;
      // check ก่อนว่าที่ส่งมาเป็น type ไหน remove หรือ update 
      if (status == 'remove' && favorites != null && product != null){
        favorites!.removeWhere((item) => item['prodID'] == product['prodID']); 
      }else if(status == 'No'){
        favorites = user['favorite'];
      }else {
        if (favorites != null && product != null) {
          favorites!.add(product);
        } else if (product != null) {
          favorites = [product];
        }
      }      
      // save
      await doc.reference.update({
        'address': user['address'],
        'email': user['email'],
        'favorite': favorites,
        'fname': user['fname'],
        'lname': user['lname'],
        'phone': user['phone'],
        'shoppingMode': true,
        'username': user['username'],
      });
    });
    print('------ success ----');
  } catch (e) {
    print('---------------- Error ------------- ');
    print(e);
  }

  return favorites;
}

// Future<void> updateStatus(orders,status) async {
//   QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Orders')
//                                                                 .where('product.prodID', isEqualTo: orders['product']['prodID'])
//                                                                 .where('username.username',isEqualTo: orders['username']['username']).get();
//   orders['status'] = status;
//     querySnapshot.docs.forEach((doc) async { 
//       await doc.reference.update(orders);
//     }
//   );
// }
  bool isFavorite(Map<String, dynamic>? name,List<dynamic>? fav) { // check ว่ามี item นี้อยุ่แล้วมั้ย 
    if (fav == null) {
      return false;
    } else {
      for (var item in fav!) {
        if (item is Map<String, dynamic> && item['prodID'] == name!['prodID']) { // productID ใช้ check
          return true;
        }
      }
      return false;
    } 
  }


Future<bool> isEmailVerified() async {
  FirebaseAuth auth = FirebaseAuth.instance;
  try {
    User? user = auth.currentUser;

    if (user != null) {
      await user.reload();
      return user.emailVerified;
    } else {
      return false;
    }
  } catch (e) {
    print('Error checking email verification status: $e');
    return false;
  }
}

Future<void> sendEmailVerification() async {
  FirebaseAuth auth = FirebaseAuth.instance;
  try {
    User? user = auth.currentUser;

    if (user != null) {
      await user.sendEmailVerification();
      print('Verification email sent.');
    } else {
      print('No user signed in.');
    }
  } catch (e) {
    print('Error sending verification email: $e');
  }
}
Future<List<DocumentSnapshot>> getProducts() async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('Product')
      .orderBy('time')
      .get();
  return querySnapshot.docs;
}
Future<Map<String, dynamic>> getHistory(String id) async {
  DocumentSnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance.collection('History').doc(id).get();
  Map<String, dynamic> historyData = querySnapshot.data()!;
  return historyData;
}

