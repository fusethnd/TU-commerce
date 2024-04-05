import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

Future<List<dynamic>?> updateUser(Map<String, dynamic> user, Map<String, dynamic>? product,String status) async {
  List<dynamic>? favorites;

  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: user['username']).get();
    querySnapshot.docs.forEach((doc) async {
      // Get the existing favorites from the document data //remove
      favorites = user['favorite'] as List<dynamic>?;

      if (status == 'remove' && favorites != null && product != null){
        favorites!.removeWhere((item) => item['prodID'] == product['prodID']);
      }else {
        if (favorites != null && product != null) {
          favorites!.add(product);
        } else if (product != null) {
          favorites = [product];
        }
      }

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
bool isFavorite(Map<String, dynamic>? name,List<dynamic>? fav) {
  if (fav == null) {
    return false;
  } else {
    for (var item in fav!) {
      if (item is Map<String, dynamic> && item['prodName'] == name!['prodName']) {
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
// class GetData {
//   late String email;
//   late Map<String, dynamic> userData;
//   bool isLoading = true;

//   Future<Map<String, dynamic>?> getUserByEmail(String email) async {
//     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//         .collection('users')
//         .where('email', isEqualTo: email)
//         .get();
//     if (querySnapshot.docs.isNotEmpty) {
//       DocumentSnapshot docSnapshot = querySnapshot.docs.first;
//       return docSnapshot.data() as Map<String, dynamic>;
//     }
//     return null;
//   }

//   Future<void> getData() async {
//     userData = await getUserByEmail(email) ?? {}; // Set default value if null
//     isLoading = false;
//   }
// }