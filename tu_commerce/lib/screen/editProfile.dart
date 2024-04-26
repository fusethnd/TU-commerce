import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tu_commerce/function/Firebase.dart';
import 'package:tu_commerce/screen/profilePicture.dart';

class EditProfile extends StatefulWidget {
  final Map<String, dynamic> user;

  const EditProfile({super.key, required this.user});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  void refresh() {
    if (mounted) {
      Navigator.of(context).build(context);
    }
  }

  editProfileForm() async {
    try {
      var userID = await getUserIDByEmail(widget.user['email']);
      var existUser = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: _usernameController.text.trim())
          .get();

      if (existUser.size > 0 &&
          existUser.docs.first['username'] != widget.user['username']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Username is already used')),
        );
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userID)
            .update({
          'username': _usernameController.text.trim(),
          'fname': _nameController.text.trim(),
          'lname': _surnameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved')),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Error, Please try again later')),
      );
    }
  }

  updateProfilePicture() async{
    try {
      File _picture;
      final pickedFile = await ImagePicker().pickImage(
          source: ImageSource.gallery);
      _picture = File(pickedFile!.path);
      String filename = widget.user['username'] + '_pic.png';
      Reference ref = await FirebaseStorage.instance.ref();
      await ref.child('profile/$filename').putFile(_picture);
      String pictureURL = (await FirebaseStorage.instance.ref().child(
          'profile/$filename').getDownloadURL()).toString();

      var userID = await getUserIDByEmail(widget.user['email']);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .update({'profilePicture': pictureURL});

      setState(() {
        widget.user['profilePicture'] = pictureURL;
      });
    }
    catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error, Please try again later')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Column(
        children: [
          ProfilePicture(user: widget.user),
          ElevatedButton(onPressed: (){
            updateProfilePicture();
          }, child: Text('Edit Image')),
          Form(
            key: _formKey,
            child: Column(children: [
              TextFormField(
                controller: _usernameController..text = widget.user['username'],
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextFormField(
                controller: _nameController..text = widget.user['fname'],
                decoration: const InputDecoration(labelText: 'name'),
              ),
              TextFormField(
                controller: _surnameController..text = widget.user['lname'],
                decoration: const InputDecoration(labelText: 'Surname'),
              ),
              TextFormField(
                controller: _phoneController..text = widget.user['phone'],
                decoration: const InputDecoration(labelText: 'phone'),
              ),
              TextFormField(
                controller: _addressController..text = widget.user['address'],
                decoration: const InputDecoration(labelText: 'address'),
              ),
              ElevatedButton(
                  onPressed: () async {
                    _formKey.currentState!.save();
                    editProfileForm();
                  },
                  child: const Text('Save'))
            ]),
          ),
        ],
      ),
    );
  }
}
