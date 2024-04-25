import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tu_commerce/screen/navigationbarCustomer.dart';
import 'package:tu_commerce/screen/navigationbarSeller.dart';
import 'registerScreen.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        final userLogin = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: _usernameController.text.trim())
            .get();
        if (userLogin.docs.isNotEmpty) {
          final email = userLogin.docs.first.data()['email'];
          await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: email, password: _passwordController.text.trim());
          _formKey.currentState!.reset();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => NavigationCustomer(email: email)),
                (Route<dynamic> route) => false,
          );
        }
      } on FirebaseAuthException {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: AppBar(
              title: Image.asset('assets/images/Logo.png'),
              backgroundColor: const Color.fromRGBO(54, 91, 109, 1.0),
              toolbarHeight: 600,
              automaticallyImplyLeading: false,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                )
              ),
            ),
          ),
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color.fromRGBO(65, 193, 186, 1.0)
              ),
              margin: const EdgeInsets.all(30),
              padding: const EdgeInsets.all(20),
              height: 400,
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          prefixIcon: const Icon(
                            Icons.account_circle_rounded,
                            color: Color.fromRGBO(65, 193, 186, 1.0),
                          ),
                          hintText: 'Username',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Enter your username' : null,
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: Color.fromRGBO(65, 193, 186, 1.0),
                          ),
                          hintText: 'Password',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Enter your password' : null,
                        obscureText: true,
                      ),
                      const SizedBox(height: 50),
                      ElevatedButton(
                        onPressed: _loginUser,
                        style:  ButtonStyle(
                          textStyle: MaterialStateProperty.all(
                            const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                              )
                            ),
                            foregroundColor: MaterialStateProperty.all(const Color.fromRGBO(54, 91, 109, 1.0)),
                          minimumSize: MaterialStateProperty.all(const Size(double.infinity, 50))
                        ),
                        child: const Text('Login'),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Text("Don't have an account?"),
                          const Spacer(),
                          GestureDetector(
                            child: const Text(
                              "Create an account.",
                              style: TextStyle(decoration: TextDecoration.underline),
                            ),
                            onTap: ()
                            {
                              Navigator.push(
                                context,MaterialPageRoute(builder: (context){
                                  return const RegisterScreen();
                                })
                              );
                            },
                          )

                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      )
    );
  }
}
