import 'dart:async';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tu_commerce/function/Firebase.dart';
import 'package:tu_commerce/screen/createCreditScreen.dart';
import 'package:tu_commerce/screen/editBankAccount.dart';
import 'package:tu_commerce/screen/topUpScreen.dart';
import 'package:tu_commerce/screen/withdrawScreen.dart';

class WalletScreen extends StatefulWidget {
  Map<String, dynamic> username;
  @override
  WalletScreen({Key? key, required this.username}) : super(key: key);
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool isHaveCredit = false;
  double balance = 0;
  String bankNumber = '';
  String bankName = '';
  String name = '';
  bool isLoading = true;
  String creditID = '';
  String bankAccountID = '';
  DocumentSnapshot<Map<String, dynamic>>? userCredit;

  getCredit(email) async {
    var user = await getUserByEmail(email);
    var credit = (user?['Credit']);

    if (credit == null) {
      setState(() {
        isLoading = false;
      });
    } else {
      var creditDoc = await FirebaseFirestore.instance
          .collection("Credit")
          .doc(credit)
          .get();

      var bankAccountDoc = await FirebaseFirestore.instance
          .collection("BankAccount")
          .doc(creditDoc.data()?['bankAccount'])
          .get();
      if (mounted){
        setState(() {
          balance = creditDoc.data()?['balance'].toDouble();
          bankNumber = bankAccountDoc.data()?['bankNumber'];
          bankName = bankAccountDoc.data()?['bankName'];
          name = bankAccountDoc.data()?['name'];
          creditID = user?['Credit'];
          bankAccountID = creditDoc.data()?['bankAccount'];
          userCredit = creditDoc;
          isHaveCredit = true;
          isLoading = false;
        });

      }
    }
  }

  @override
  void initState() {
    User? user = FirebaseAuth.instance.currentUser;
    String? email = user!.email;
    getCredit(email!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    // print("---- mode -----");
    // print(widget.username['shoppingMode']);
    if (!isHaveCredit) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Wallet'),
        ),
        body: Column(
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreateCredit()))
                      .then((value) => setState(() {}));
                },
                child: Text("Create Credit")),
          ],
        ),
      );
    }
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Wallet',
            style: TextStyle(
              color: Color.fromRGBO(60, 91, 109, 1.0),
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: widget.username['shoppingMode']
              ? Color.fromRGBO(65, 193, 186, 1.0) // True condition
              : Color.fromRGBO(32, 157, 214, 1), // False condition
          toolbarHeight: 100,
          automaticallyImplyLeading: false,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(),
          ),
        ),
        body: Column(children: [
          const SizedBox(
            height: 20,
          ),
          Container(
            padding: EdgeInsets.all(20.0),
            width: screenWidth*0.75,
            height: 120.0,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: widget.username['shoppingMode']
                    ? Color.fromRGBO(98, 221, 214, 1.0) // True condition
                    : Color.fromRGBO(79, 184, 238, 1)),
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
                    text: "${balance.toStringAsFixed(2)} ฿",
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
          Padding(
            padding: EdgeInsets.all(20.0), // Add padding around the Row
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TopUpScreen(
                              username: widget.username , creditID: creditID, userCredit: userCredit!)),
                    );
                  },
                  child: const Text("Top Up"),
                ),
                const SizedBox(width: 40),
                
                
                 // Space between buttons
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WithdrawScreen(
                              username:widget.username ,creditID: creditID, userCredit: userCredit!)),
                    );
                  },
                  child: Text("Withdraw"),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text(
                "Your Bank Account",
                style: TextStyle(
                  fontSize: 16, // Adjust the font size as needed
                ),
              ),
              GestureDetector(
                child: const Text(
                  "Edit",
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditBankAccount(
                        bankAccountID: bankAccountID,
                        username: widget.username)),
                  );
                }
              )
            ],
          ),
          const SizedBox(height: 10,),
          Container(
            padding: EdgeInsets.all(20.0),
            width: screenWidth*0.75,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: widget.username['shoppingMode']
                  ? Color.fromRGBO(98, 221, 214, 1.0) // True condition
                  : Color.fromRGBO(79, 184, 238, 1),
            ),
            child: Row(
              children: [
                // First Column: Icon
                Icon(Icons.attach_money,
                    size: 48.0, color: Color.fromRGBO(54, 91, 109, 1.0)),
                SizedBox(width: 16.0),

                // Second Column: Texts
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Text("Account ${name}", style: TextStyle(color: Color.fromRGBO(54, 91, 109, 1.0))),
                      // SizedBox(height: 8.0),

                      Row(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceBetween, // This will align "Account" left and `${name}` right
                        children: [
                          const Text(
                            "Account",
                            style: TextStyle(
                              color: Color.fromRGBO(
                                  54, 91, 109, 1.0), // Your color
                            ),
                          ),
                          Text(
                            "${name}",
                            style: const TextStyle(
                              color: Color.fromRGBO(
                                  54, 91, 109, 1.0), // Your color
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),

                      Row(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceBetween, // This will align "Account" left and `${name}` right
                        children: [
                          const Text(
                            "Account No.",
                            style: TextStyle(
                              color: Color.fromRGBO(
                                  54, 91, 109, 1.0), // Your color
                            ),
                          ),
                          Text(
                            "${bankNumber}",
                            style: const TextStyle(
                              color: Color.fromRGBO(
                                  54, 91, 109, 1.0), // Your color
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),

                      Row(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceBetween, // This will align "Account" left and `${name}` right
                        children: [
                          const Text(
                            "Bank",
                            style: TextStyle(
                              color: Color.fromRGBO(
                                  54, 91, 109, 1.0), // Your color
                            ),
                          ),
                          Text(
                            "${bankName}",
                            style: const TextStyle(
                              color: Color.fromRGBO(
                                  54, 91, 109, 1.0), // Your color
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                    ],
                  ),
                ),
              ],
            ),
          )
        ]));
  }
}
