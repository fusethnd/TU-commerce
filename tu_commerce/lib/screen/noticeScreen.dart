import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NoticeSreen extends StatefulWidget {
  final Map<String, dynamic> username;

  NoticeSreen({Key? key, required this.username}) : super(key: key);

  @override
  State<NoticeSreen> createState() => _NoticeSreenState();
}

class _NoticeSreenState extends State<NoticeSreen> {
  Map<String, dynamic>? allNotice;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initialState();
  }

  Future<void> _initialState() async {
    Map<String, dynamic>? tempMap = (await FirebaseFirestore.instance
            .collection('Notice')
            .doc(widget.username['username'])
            .get())
        .data();
    setState(() {
      allNotice = tempMap;
    });
  }

  @override
  Widget build(BuildContext context) {
    // print(allNotice!['noticeList']);
    return Scaffold(
      appBar: AppBar(
        title: Text('Kuy'),
      ),

      body: allNotice == null
          ? const Center(child: CircularProgressIndicator()) :
      Container(
        child: ListView.builder(
            itemCount: allNotice!['noticeList'].length,
            itemBuilder: (context, index) {
              print('---------');
              // print(allNotice!['noticeList'][index]);
              // return null;
              Map<String, dynamic> notice = allNotice!['noticeList'][index];
              String status = notice['status'];
              // String message = notice['Message'];
              print(status);
              // return null;
              return Card(
                child: ListTile(
                  title: Text('Status: $status'),
                  // Add more ListTile properties as needed
                ),
              );
            }),
      ),
    );
  }
}
