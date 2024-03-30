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
    }
  );
  print('------------------------------------------');
  print('Product save successfull');
  } catch (e) {
    print('---------------- Error ------------- ');
    print(e);
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