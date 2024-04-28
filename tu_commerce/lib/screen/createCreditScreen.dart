import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tu_commerce/function/Firebase.dart';
import 'package:tu_commerce/model/Credit.dart';
import 'package:tu_commerce/model/bankAccount.dart';
import 'package:tu_commerce/main.dart';
import 'package:tu_commerce/screen/navigationbarCustomer.dart';

class CreateCredit extends StatefulWidget {
  const CreateCredit({super.key});

  @override
  State<CreateCredit> createState() => _createCreditState();
}

class _createCreditState extends State<CreateCredit> {
  Credit credit = Credit(0);
  BankAccount bankAccount = BankAccount();

  final _formKey = GlobalKey<FormState>();

  Future<void> _createCredit() async {
    if (_formKey.currentState!.validate()) {
      try {
        var bankAccountDoc =
            await FirebaseFirestore.instance.collection("BankAccount").add({
          'bankNumber': bankAccount.bankNumber,
          'bankName': bankAccount.bankName,
          'name': bankAccount.name,
        });

        var creditDoc = await FirebaseFirestore.instance
            .collection("Credit")
            .add({'balance': credit.balance, 'bankAccount': bankAccountDoc.id});

        var email = FirebaseAuth.instance.currentUser?.email;
        var userID = await getUserIDByEmail(email!);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userID)
            .update({'Credit': creditDoc.id});

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => NavigationCustomer(email: email, temp: 0),
            ),
            (Route<dynamic> route) => false);
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Error, Please try again later')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: const GoBackButton(),
        title: const Text(
          'Create Credit',
          style: TextStyle(
            color: Color.fromRGBO(54, 91, 109, 1.0),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color.fromRGBO(65, 193, 186, 1.0),
        toolbarHeight: 100,
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
                  fillColor: Color.fromRGBO(219, 241, 240, 1.0),
                  contentPadding: const EdgeInsets.only(left: 25),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all( Color.fromRGBO(98, 221, 214, 1.0)),
                        foregroundColor: MaterialStateProperty.all(Color.fromRGBO(54, 91, 109,1.0)),
                        minimumSize: MaterialStateProperty.all(
                            const Size(double.infinity, 50))))),
            home: SingleChildScrollView(
              child: SizedBox(
                height: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Bank number'),
                      validator: (value) =>
                          value!.isEmpty ? 'Enter your bank number' : null,
                      onSaved: (String? bankNumber) {
                        bankAccount.bankNumber = bankNumber!;
                      },
                    ),
                    TextFormField(
                        decoration: const InputDecoration(labelText: 'Bank name'),
                        validator: (value) =>
                            value!.isEmpty ? 'Enter your bank name' : null,
                        onSaved: (String? bankName) {
                          bankAccount.bankName = bankName!;
                        }),
                    TextFormField(
                        decoration: const InputDecoration(labelText: 'Name'),
                        validator: (value) => value!.isEmpty ? 'Enter your name' : null,
                        onSaved: (String? name) {
                          bankAccount.name = name!;
                        }),
                    ElevatedButton(
                      onPressed: () {
                        _formKey.currentState!.save();
                        _createCredit();
                      },
                      child: const Text('Create'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    // return Scaffold(
    //   appBar: AppBar(title: Text("Create Credit")),
    //   body: Form(
    //     key: _formKey,
    //     child: Column(
    //       children: [
    //         TextFormField(
    //           decoration: const InputDecoration(labelText: 'Bank number'),
    //           validator: (value) =>
    //               value!.isEmpty ? 'Enter your bank number' : null,
    //           onSaved: (String? bankNumber) {
    //             bankAccount.bankNumber = bankNumber!;
    //           },
    //         ),
    //         TextFormField(
    //             decoration: const InputDecoration(labelText: 'Bank name'),
    //             validator: (value) =>
    //                 value!.isEmpty ? 'Enter your bank name' : null,
    //             onSaved: (String? bankName) {
    //               bankAccount.bankName = bankName!;
    //             }),
    //         TextFormField(
    //             decoration: const InputDecoration(labelText: 'Name'),
    //             validator: (value) => value!.isEmpty ? 'Enter your name' : null,
    //             onSaved: (String? name) {
    //               bankAccount.name = name!;
    //             }),
    //         ElevatedButton(
    //           onPressed: () {
    //             _formKey.currentState!.save();
    //             _createCredit();
    //           },
    //           child: const Text('Create'),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
