import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:tu_commerce/model/user.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _fnameController = TextEditingController();
  final _lnameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _fnameController.dispose();
    _lnameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  UserModel user = UserModel(shoppingmode: true);

  Future<bool> usernameIsExist(username) async {
    var data = await FirebaseFirestore.instance
        .collection('users')
        .where("username",isEqualTo: username).get();
    return data.size > 0;
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        bool check = await usernameIsExist(user.username);

        if (check) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Username is already used")),
          );
        } else {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: user.email.toString(),
            password: user.password.toString(),
          );

          await FirebaseFirestore.instance.collection('users').doc().set({
            'email': user.email,
            'fname': user.fname,
            'lname': user.lname,
            'username': user.username,
            'phone': user.phone,
            'address': user.address,
            'shoppingMode' : user.shoppingmode}
          );


          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration Successful')),
          );

          _formKey.currentState!.reset();
          Navigator.pop(context);
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Registration Failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: MultiValidator([
                    RequiredValidator(errorText: "Enter your email"),
                    EmailValidator(errorText: "Please use correct email")
                  ]),
                  keyboardType: TextInputType.emailAddress
                  ,
                  onSaved: (String? email){
                    user.email = email!;
                  },
                ),
                TextFormField(
                  controller: _lnameController,
                  decoration: const InputDecoration(labelText: 'First name'),
                  validator: (value) =>
                  value!.isEmpty ? 'Enter your first name' : null,
                  onSaved: (String? fname){
                    user.fname = fname!;
                  },
                ),
                TextFormField(
                  controller: _lnameController,
                  decoration: const InputDecoration(labelText: 'Last name'),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter your last name' : null,
                  onSaved: (String? lname){
                    user.lname = lname!;
                  },
                ),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'User name'),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter your username' : null,
                  onSaved: (String? username){
                    user.username = username!;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (value) => value!.length < 6
                      ? 'Password must be at least 6 characters'
                      : null,
                ),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: 'Confirm Password'),
                  validator: (value) => value != _passwordController.text
                      ? 'Passwords do not match'
                      : null,
                  onSaved: (String? password){
                    user.password = password!;
                  },
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter your phone number' : null,
                  keyboardType: TextInputType.phone,
                  onSaved: (String? phone){
                    user.phone = phone!;
                  },
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter your address' : null,
                  onSaved: (String? address){
                    user.address = address!;
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    _formKey.currentState!.save();
                    _registerUser();
                  },
                  child: const Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
