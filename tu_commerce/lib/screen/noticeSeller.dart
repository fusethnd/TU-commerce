import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NoticeSeller extends StatefulWidget {
  final Map<String, dynamic> username;

  NoticeSeller({Key? key, required this.username}) : super(key: key);

  @override
  State<NoticeSeller> createState() => _NoticeSellerState();
}

class _NoticeSellerState extends State<NoticeSeller> {
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
        .doc("seller"+widget.username['username'])
        .get())
        .data();
    if (tempMap == null) {
      tempMap = {
        "length":0,
        "noticeList":[]
      };
    }
    if (mounted){
      setState(() {
        allNotice = tempMap;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    // print(allNotice!['noticeList']);
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),

      body: allNotice == null || allNotice!['noticeList'] == null
      ? const Center(child: CircularProgressIndicator()):
      Column(
        children: [
            Expanded( // Wrap ListView.builder with Expanded
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: allNotice!['noticeList'].length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> notice = allNotice!['noticeList'][index];
                  String status = notice['status'];
                  return Card(
                    shape: const RoundedRectangleBorder(),
                    child: ListTile(
                      title: Text('Status: $status'),
                    ),
                  );
                }
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () async {
                if (allNotice!['noticeList'].isEmpty == false){
            
                  await FirebaseFirestore.instance.collection('Notice').doc("seller${widget.username['username']}").delete();
                }
                // setState(() {
                //   allNotice = null;
                // });
                _initialState();
              },
              child: const Text('Clear')
            ),
          )


        ],
      )
    );
  }
}