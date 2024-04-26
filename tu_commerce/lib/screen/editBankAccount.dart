import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tu_commerce/screen/navigationbarCustomer.dart';

class EditBankAccount extends StatefulWidget {
  final String bankAccountID;
  final Map<String, dynamic> username;
  EditBankAccount(
      {Key? key, required this.bankAccountID, required this.username})
      : super(key: key);

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
        await FirebaseFirestore.instance
            .collection("BankAccount")
            .doc(widget.bankAccountID)
            .update({
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
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Edit Bank Account',
          style: TextStyle(
            color: Color.fromRGBO(54, 91, 109, 1.0),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: widget.username['shoppingMode']
            ? Color.fromRGBO(98, 221, 214, 1.0)
            : Color.fromRGBO(32, 157, 214, 1),
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
                  fillColor: widget.username['shoppingMode']
        ? Color.fromRGBO(219, 241, 240, 1.0) // True condition: light teal
        : Color.fromARGB(255, 182, 226, 250),
                  contentPadding: const EdgeInsets.only(left: 25),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            widget.username['shoppingMode']
                                ? Color.fromRGBO(
                                    98, 221, 214, 1.0) // True condition
                                : Color.fromRGBO(
                                    38, 174, 236, 1) // False condition
                            ),
                        foregroundColor: MaterialStateProperty.all(
                            widget.username['shoppingMode']
                                ? Color.fromRGBO(54, 91, 109,
                                    1.0) // True condition: dark blue-gray
                                : Colors.white // False condition: white
                            ),
                        minimumSize: MaterialStateProperty.all(
                            const Size(double.infinity, 50))))),
            home: SingleChildScrollView(
              child: SizedBox(
                height: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration:
                          const InputDecoration(labelText: 'Your Account Name'),
                      validator: (value) =>
                          value!.isEmpty ? 'Enter your name' : null,
                    ),
                    TextFormField(
                      controller: _bankNumberController,
                      decoration:
                          const InputDecoration(labelText: 'Account No.'),
                      validator: (value) =>
                          value!.isEmpty ? 'Enter your bank number' : null,
                    ),
                    TextFormField(
                      controller: _bankNameController,
                      decoration: const InputDecoration(labelText: 'Bank'),
                      validator: (value) =>
                          value!.isEmpty ? 'Enter your bank name' : null,
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
            ),
          ),
        ),
      ),
    );
  }
}
