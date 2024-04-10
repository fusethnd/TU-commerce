import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tu_commerce/function/Firebase.dart';
import 'package:tu_commerce/screen/createCreditScreen.dart';
import 'package:tu_commerce/screen/editBankAccount.dart';
import 'package:tu_commerce/screen/topUpScreen.dart';
import 'package:tu_commerce/screen/withdrawScreen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

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

  @override
  void initState() {
    User? user = FirebaseAuth.instance.currentUser;
    String? email = user!.email;
    getCredit(email!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(isLoading){
      return Center(child: CircularProgressIndicator(),);
    }
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
          title: Text('Wallet'),
        ),
        body: Column(children: [
          Text("Balance: ${balance.toString()}"),
          Text("Bank number: ${bankNumber}"),
          Text("Bank name: ${bankName}"),
          Text("Name: ${name}"),
          Row(children: [
            ElevatedButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> TopUpScreen(creditID: creditID,userCredit: userCredit!,)));
            }, child: Text("Top up")),
            ElevatedButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> WithdrawScreen(creditID: creditID,userCredit: userCredit!,)));
            }, child: Text("Withdraw"))
          ],
          ),
          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> EditBankAccount(bankAccountID: bankAccountID,)));
          }, child: Text("Edit BankAccount"))
        ]));
  }
}
