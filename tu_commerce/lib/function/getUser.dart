import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';


Future<Map<String, dynamic>?> getUserByEmail(String email) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: email).get();
  if (querySnapshot.docs.isNotEmpty) {
    DocumentSnapshot docSnapshot = querySnapshot.docs.first;
    return docSnapshot.data() as Map<String, dynamic>;

  }
  return null;
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