import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'navigationbarCustomer.dart';

class TopUpScreen extends StatefulWidget {
  final DocumentSnapshot<Map<String, dynamic>> userCredit;
  final String creditID;

  TopUpScreen({Key? key, required this.creditID, required this.userCredit})
      : super(key: key);

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
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
        double newBalance = creditDoc.data()?['balance'].toDouble() +
            double.parse(_amountController.text.trim());

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
          centerTitle: true,
          title: const Text(
            'Top Up',
            style: TextStyle(
              color: Color.fromRGBO(54, 91, 109, 1.0),
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color.fromRGBO(98, 221, 214, 1.0),
          toolbarHeight: 100,
        ),
        body: Column(children: [
          const SizedBox(
            height: 20,
          ),
          Container(
            padding: const EdgeInsets.all(20.0),
            width: 350.0,
            height: 120.0,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color.fromRGBO(98, 221, 214, 1.0)),
            child: RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: "Total Balance \n ",
                    style: TextStyle(
                      color: Color.fromRGBO(54, 91, 109, 1.0),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const WidgetSpan(
                    child: SizedBox(height: 40),
                  ),
                  TextSpan(
                    text: "฿ ${widget.userCredit["balance"]}",
                    style: const TextStyle(
                      color: Color.fromRGBO(54, 91, 109, 1.0),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Form(
            key: _formKey,
            child: Column(children: [
              TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: "Amount"),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Enter your amount' : null),
              Padding(
                padding: const EdgeInsets.all(
                    30.0), // Adjust the outer padding value as needed
                child: ElevatedButton(
                  onPressed: () {
                    _formKey.currentState!.save();
                    _topUp();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        const Color.fromRGBO(54, 91, 109, 1.0)),
                    foregroundColor: MaterialStateProperty.all(
                        const Color.fromRGBO(255, 255, 255, 1)),
                    textStyle: MaterialStateProperty.all(
                      const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 40),
                    ),
                  ),
                  child: const Text("TopUp"),
                ),
              ),
              
              
              // ElevatedButton(
              //   onPressed: () {
              //     _formKey.currentState!.save();
              //     _topUp();
              //   },
              //   child: const Text('TopUp'),
              // ),
            ]),
          ),
        ]));
  }
}
