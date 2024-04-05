import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'navigationbarCustomer.dart';

class WithdrawScreen extends StatefulWidget {
  final DocumentSnapshot<Map<String, dynamic>> userCredit;
  final String creditID;

  WithdrawScreen({Key? key, required this.creditID, required this.userCredit})
      : super(key: key);

  @override
  State<WithdrawScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<WithdrawScreen> {
  @override
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _topUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        var creditDoc = await FirebaseFirestore.instance
            .collection("Credit")
            .doc(widget.creditID)
            .get();

        if (double.parse(_amountController.text.trim()) >
            creditDoc.data()?['balance'].toDouble()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Your balance is not enough")),
          );
        }

        double newBalance = creditDoc.data()?['balance'].toDouble() - double.parse(_amountController.text.trim());
        await FirebaseFirestore.instance
            .collection("Credit")
            .doc(widget.creditID)
            .update({'balance': newBalance});

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
        appBar: AppBar(
          title: const Text("Withdraw"),
        ),
        body: Column(children: [
          Text("Your Balance ${widget.userCredit["balance"]}"),
          Form(
            key: _formKey,
            child: Column(children: [
              TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: "Amount"),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Enter your amount' : null),
              ElevatedButton(
                onPressed: () {
                  _formKey.currentState!.save();
                  _topUp();
                },
                child: const Text('Withdraw'),
              ),
            ]),
          ),
        ]));
  }
}
