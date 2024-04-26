import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tu_commerce/function/Firebase.dart';
import 'package:tu_commerce/model/user.dart';

class EditProfile extends StatefulWidget {
  final Map<String, dynamic> user;

  EditProfile({Key? key, required this.user}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  editProfile() async {
    QuerySnapshot querySnapshot = await firestore
        .collection('users')
        .where('email', isEqualTo: widget.user['email'])
        .get();

    var usernameIsExist = await FirebaseFirestore.instance
        .collection('users')
        .where("username", isEqualTo: widget.user['username'])
        .get();

    var emailIsExist = await FirebaseFirestore.instance
        .collection('users')
        .where("email", isEqualTo: widget.user['email'])
        .get();

    if (usernameIsExist.size > 0 &&
        widget.user['username'] != usernameIsExist.docs.first['username']) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('This username is already exist')));
    }
    // else if (emailIsExist.size > 0 && widget.user['email'] != usernameIsExist.docs.first['email']) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('This username is already exist')));
    // }
    else {
      querySnapshot.docs.forEach((doc) async {
        await doc.reference.update({
          'address': widget.user['address'],
          'email': widget.user['email'],
          'favorite': widget.user['favorite'],
          'fname': widget.user['fname'],
          'lname': widget.user['lname'],
          'phone': widget.user['phone'],
          'shoppingMode': true,
          'username': widget.user['username'],
        });
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Save success')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: Form(
        key: _formKey,
        child: Column(children: [
          TextFormField(
            initialValue: widget.user['username'],
            decoration: const InputDecoration(labelText: 'Username'),
            onSaved: (newValue) => widget.user['username'] = newValue,
          ),
          TextFormField(
            initialValue: widget.user['fname'],
            decoration: const InputDecoration(labelText: 'name'),
            onSaved: (newValue) => widget.user['fname'] = newValue,
          ),
          TextFormField(
            initialValue: widget.user['lname'],
            decoration: const InputDecoration(labelText: 'Surname'),
            onSaved: (newValue) => widget.user['lname'] = newValue,
          ),
          // TextFormField(
          //   initialValue: widget.user['email'],
          //   decoration: const InputDecoration(
          //     labelText: 'email'
          //   ),
          //   onSaved: (newValue)  {
          //     email = widget.user['email'];
          //     widget.user['email'] = newValue;
          //   },
          // ),
          TextFormField(
            initialValue: widget.user['phone'],
            decoration: const InputDecoration(labelText: 'phone'),
            onSaved: (newValue) => widget.user['phone'] = newValue,
          ),
          TextFormField(
            initialValue: widget.user['address'],
            decoration: const InputDecoration(labelText: 'address'),
            onSaved: (newValue) => widget.user['address'] = newValue,
          ),
          ElevatedButton(
              onPressed: () async {
                _formKey.currentState!.save();
                editProfile();
              },
              child: const Text('Save'))
        ]),
      ),
    );
  }
}
