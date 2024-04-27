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
    if (tempMap == null) {
      tempMap = {
        "length":0,
        "noticeList":[]
      };
    }
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

      body: allNotice == null || allNotice!['noticeList'] == null
          ? const Center(child: CircularProgressIndicator()) :
          Column(
            children: [
                Expanded( // Wrap ListView.builder with Expanded
                  child: ListView.builder(
                    itemCount: allNotice!['noticeList'].length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> notice = allNotice!['noticeList'][index];
                      String status = notice['status'];
                      return Card(
                        child: ListTile(
                          title: Text('Status: $status'),
                        ),
                      );
                    }
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (allNotice!['noticeList'].isEmpty == false){
                      await FirebaseFirestore.instance.collection('Notice').doc(widget.username['username']).delete();
                    }
                    // setState(() {
                    //   allNotice = null;
                    // });
                    _initialState();
                  },
                  child: const Text('Delete')
                )
            ],
          )
    );
  }
}
