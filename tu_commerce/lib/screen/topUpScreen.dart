import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tu_commerce/main.dart';
import 'navigationbarCustomer.dart';

class TopUpScreen extends StatefulWidget {
  Map<String, dynamic> username;
  final DocumentSnapshot<Map<String, dynamic>> userCredit;
  final String creditID;

  TopUpScreen(
      {Key? key,
      required this.username,
      required this.creditID,
      required this.userCredit})
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
    // print('--------asdsad');
    // print(widget.username);
    // print(widget.username['shoppingMode'])
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: GoBackButton(),
          title: Text(
            'Top Up',
            style: TextStyle(
              color: Color.fromRGBO(54, 91, 109, 1.0),
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: widget.username['shoppingMode']
              ? Color.fromRGBO(65, 193, 186, 1.0) // True condition
              : Color.fromRGBO(32, 157, 214, 1),
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
                color: widget.username['shoppingMode']
                    ? Color.fromRGBO(98, 221, 214, 1.0) // True condition
                    : Color.fromRGBO(38, 174, 236, 1)),
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
          const SizedBox(
            height: 20,
          ),
          Form(
            key: _formKey,
            child: Column(children: [
              Container(
                  padding: const EdgeInsets.all(20.0),
                  width: 350.0,
                  height: 200.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: widget.username['shoppingMode']
                          ? Color.fromRGBO(98, 221, 214, 1.0) // True condition
                          : Color.fromRGBO(38, 174, 236, 1)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Top Up \n ",
                        style: TextStyle(
                          color: Color.fromRGBO(54, 91, 109, 1.0),
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: TextFormField(
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                    color: Color.fromRGBO(54, 91, 109, 1.0),
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold),
                                controller: _amountController,
                                decoration: const InputDecoration(
                                    hintText: "Amount",
                                    hintStyle: TextStyle(
                                        color:
                                            Color.fromRGBO(54, 91, 109, 0.5))),
                                keyboardType: TextInputType.number,
                                validator: (value) => value!.isEmpty
                                    ? 'Enter your amount'
                                    : null),
                          ),
                          const Text(
                            " ฿",
                            style: TextStyle(
                              color: Color.fromRGBO(54, 91, 109, 1.0),
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),

              Row(
                children: [
                  SizedBox(
                height: 10,
              ),
                ],
              ),
              // TextFormField(
              //     controller: _amountController,
              //     decoration: const InputDecoration(labelText: "Amount"),
              //     keyboardType: TextInputType.number,
              //     validator: (value) =>
              //         value!.isEmpty ? 'Enter your amount' : null),

              Padding(
                padding: const EdgeInsets.all(
                    30.0), // Adjust the outer padding value as needed
                child: ElevatedButton(
                  onPressed: () {
                    _formKey.currentState!.save();
                    _topUp();
                  },
                  child: const Text("Top Up"),
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
