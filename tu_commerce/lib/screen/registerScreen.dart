import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:tu_commerce/main.dart';
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
 final _firebaseMessage = FirebaseMessaging.instance;

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
            'shoppingMode' : user.shoppingmode,
            'favorite': [],
            'tokenNotice': await _firebaseMessage.getToken(),
            }
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
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: const GoBackButton(),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 40,
          color:  Color.fromRGBO(54, 91, 109, 1.0)
        ),
        toolbarHeight: 200,
        backgroundColor: const Color.fromRGBO(65, 193, 186, 1.0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10))
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: MaterialApp(
            theme: ThemeData(
              inputDecorationTheme: InputDecorationTheme(
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(50),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(50),
                ),
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color.fromRGBO(219, 241, 240, 1.0),
                contentPadding: const EdgeInsets.only(left: 25),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(const Color.fromRGBO(65, 193, 186, 1.0)),
                  foregroundColor: MaterialStateProperty.all(const Color.fromRGBO(54, 91, 109, 1.0)),
                  minimumSize: MaterialStateProperty.all(const Size(double.infinity, 50))
                )
              )
            ),
            home:  SingleChildScrollView(
              child: SizedBox(
                height: 600,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(hintText: 'Email'),
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
                      controller: _fnameController,
                      decoration: const InputDecoration(hintText: 'First name'),
                      validator: (value) =>
                      value!.isEmpty ? 'Enter your first name' : null,
                      onSaved: (String? fname){
                        user.fname = fname!;
                      },
                    ),
                    TextFormField(
                      controller: _lnameController,
                      decoration: const InputDecoration(hintText: 'Last name'),
                      validator: (value) =>
                          value!.isEmpty ? 'Enter your last name' : null,
                      onSaved: (String? lname){
                        user.lname = lname!;
                      },
                    ),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(hintText: 'User name'),
                      validator: (value) =>
                          value!.isEmpty ? 'Enter your username' : null,
                      onSaved: (String? username){
                        user.username = username!;
                      },
                    ),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(hintText: 'Password'),
                      validator: (value) => value!.length < 6
                          ? 'Password must be at least 6 characters'
                          : null,
                    ),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration:
                          const InputDecoration(hintText: 'Confirm Password'),
                      validator: (value) => value != _passwordController.text
                          ? 'Passwords do not match'
                          : null,
                      onSaved: (String? password){
                        user.password = password!;
                      },
                    ),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(hintText: 'Phone Number'),
                      validator: (value) =>
                          value!.isEmpty ? 'Enter your phone number' : null,
                      keyboardType: TextInputType.phone,
                      onSaved: (String? phone){
                        user.phone = phone!;
                      },
                    ),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(hintText: 'Address'),
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
        ),
      ),
    );
  }
}
