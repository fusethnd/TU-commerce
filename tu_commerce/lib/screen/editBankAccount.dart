import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tu_commerce/screen/navigationbarCustomer.dart';

class EditBankAccount extends StatefulWidget {
  final String bankAccountID;

  EditBankAccount({Key? key, required this.bankAccountID}) : super(key: key);

  @override
  State<EditBankAccount> createState() => _EditBankAccountState();
}

class _EditBankAccountState extends State<EditBankAccount> {
  final _bankNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _nameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  _editBankAccount() async {
    if (_formKey.currentState!.validate()) {
      try {

        await FirebaseFirestore.instance.collection("BankAccount").doc(widget.bankAccountID).update({
          "bankName": _bankNameController.text.trim(),
          "bankNumber": _bankNumberController.text.trim(),
          "name": _nameController.text.trim(),
        });

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => NavigationCustomer(
                  email: FirebaseAuth.instance.currentUser!.email.toString(),
                  temp: 0),
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
      appBar: AppBar(title: Text("Edit bank account")),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _bankNumberController,
              decoration: const InputDecoration(labelText: 'Bank number'),
              validator: (value) =>
                  value!.isEmpty ? 'Enter your bank number' : null,
            ),
            TextFormField(
              controller: _bankNameController,
              decoration: const InputDecoration(labelText: 'Bank name'),
              validator: (value) =>
                  value!.isEmpty ? 'Enter your bank name' : null,
            ),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) => value!.isEmpty ? 'Enter your name' : null,
            ),
            ElevatedButton(
              onPressed: () {
                _formKey.currentState!.save();
                _editBankAccount();
              },
              child: const Text('Edit'),
            ),
          ],
        ),
      ),
    );
  }
}
