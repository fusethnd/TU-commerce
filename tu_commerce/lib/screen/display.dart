import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DisplayScreen extends StatefulWidget {
  const DisplayScreen({super.key});

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Student List")),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("students").orderBy('score').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator(),);
            }
            return ListView(
              children: snapshot.data!.docs.map((doc){
                return Container(
                  child: ListTile(
                    leading: CircleAvatar(radius: 30,child: FittedBox(child: Text(doc["score"]))),
                    title: Text(doc["fname"]+" "+doc["lname"]),
                    subtitle: Text(doc["email"]),
                  ),
                );
              }).toList(),
            );
          }),
    );
  }
}
