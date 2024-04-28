import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tu_commerce/main.dart';
import 'package:intl/intl.dart';

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
        title: const Text('Notifications'),
        leading: const GoBackButton(),
      ),

      body: allNotice == null || allNotice!['noticeList'] == null
          ? const Center(child: CircularProgressIndicator()) :
          Column(
            children: [
                Expanded( // Wrap ListView.builder with Expanded
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: allNotice!['noticeList'].length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> notice = allNotice!['noticeList'][index];
                      String status = notice['status'];
                      
                      DateTime timestamp = notice!['time'].toDate(); 
                      String formattedDate = DateFormat.yMMMd().format(timestamp); 

                      return Card(
                        shape: const RoundedRectangleBorder(),
                        // color: Colors.grey[200],
                        // shadowColor: Colors.transparent,
                        // color: Colors.red,
                        // child: ListTile(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 100,
                                height: 100,
                                child: Image.network(
                                  notice['product']['link'],
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  color: Colors.grey[300],
                                  height: 100,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              (status),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17
                                              ),
                                            ),
                                            Text("Product: " + notice['product']['prodName']),
                                            Text("@" + notice['product']['seller']['username']),
                                          ],
                                        ),
                                      ),
                                      Text(formattedDate),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        // ),
                      );
                    }
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (allNotice!['noticeList'].isEmpty == false){
                        await FirebaseFirestore.instance.collection('Notice').doc(widget.username['username']).delete();
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
