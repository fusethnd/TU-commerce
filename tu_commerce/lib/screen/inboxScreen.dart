import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tu_commerce/function/Firebase.dart';

class InboxScreen extends StatefulWidget {
  final Map<String, dynamic>  username;
  
  InboxScreen({Key? key, required this.username}) : super(key: key);

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {

  List<dynamic>? orders;

  @override
  void initState() {
    super.initState();
    _initializeData();
    print(widget.username['shoppingMode']);
  }
  Future<void> _initializeData() async {
    List<DocumentSnapshot> temp = await getOrders(widget.username['username'],widget.username['shoppingMode']);
    setState(() {
      orders = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('MESSAGES'),),
      body: orders == null
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: orders!.length,
              itemBuilder: (BuildContext context, int index) {
                Map<String, dynamic> order = orders![index].data() as Map<String, dynamic>;
                String sellerName = widget.username['shoppingMode']
                    ? (order['product']['seller']['fname'] + " " + order['product']['seller']['lname'])
                    : order['username']['fname'] + " " + order['username']['lname'];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(),
                    title: Text(sellerName),
                  ),
                );
              },
            ),
      );  
  }
}