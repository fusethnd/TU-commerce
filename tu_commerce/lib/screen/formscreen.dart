import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import '../firebase_options.dart';
import '../model/student.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final formKey = GlobalKey<FormState>();
  Student myStudent = Student();

  final Future<FirebaseApp> firebase = Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );

  CollectionReference _studentCollection = FirebaseFirestore.instance.collection("students");

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: firebase, builder: (context,snapshot){
      if(snapshot.hasError){
        return Scaffold(
          appBar: AppBar(title: Text("Error"),),
          body: Center(child: Text("${snapshot.error}"),),
        );
      }
      if(snapshot.connectionState == ConnectionState.done){
        return Scaffold(
          appBar: AppBar(
            title: Text("Add Score Form"),
          ),
          body: Container(
            padding: EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Name",
                      style: TextStyle(fontSize: 20),
                    ),
                    TextFormField(
                      validator:
                      RequiredValidator(errorText: "Please fill this field"),
                      onSaved: (String? fname) {
                        myStudent.fname = fname!;
                      },
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      "Lastname",
                      style: TextStyle(fontSize: 20),
                    ),
                    TextFormField(
                        validator:
                        RequiredValidator(errorText: "Please fill this field"),
                        onSaved: (String? lname) {
                          myStudent.lname = lname!;
                        }),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      "Email",
                      style: TextStyle(fontSize: 20),
                    ),
                    TextFormField(
                        validator: MultiValidator([
                          RequiredValidator(errorText: "Please fill this field"),
                          EmailValidator(errorText: "Please use correct format email")
                        ]),
                        keyboardType: TextInputType.emailAddress,
                        onSaved: (String? email) {
                          myStudent.email = email!;
                        }),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      "Score",
                      style: TextStyle(fontSize: 20),
                    ),
                    TextFormField(
                        validator:
                        RequiredValidator(errorText: "Please fill this field"),
                        keyboardType: TextInputType.number,
                        onSaved: (String? score) {
                          myStudent.score = score!;
                        }),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        child: Text("Save"),
                        onPressed: () async{
                          if (formKey.currentState!.validate()) {
                            formKey.currentState?.save();
                            await _studentCollection.add({
                              "fname" : myStudent.fname,
                              "lname" : myStudent.lname,
                              "email" : myStudent.email,
                              "score" : myStudent.score,
                            }
                            );
                            formKey.currentState?.reset();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            shape: BeveledRectangleBorder()),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      }
      return Scaffold(
        body: Center(child: CircularProgressIndicator(),),
      );
    });

  }
}
