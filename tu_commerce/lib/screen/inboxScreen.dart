import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tu_commerce/function/Firebase.dart';
import 'package:tu_commerce/screen/chat.dart';
import 'package:tu_commerce/screen/navigationbarCustomer.dart';

class InboxScreen extends StatefulWidget {
  final Map<String, dynamic> username;

  InboxScreen({Key? key, required this.username}) : super(key: key);

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  List<dynamic>? orders;
  List<dynamic>? chatRooms;
  // late StreamSubscription<List<DocumentSnapshot>>? _chatRoomSubscription;
  @override
  void initState() {
    super.initState();
    _initializeData();
    print(widget.username['shoppingMode']);
    print(orders);
  }

  void dispose() {
    // Cancel the stream subscription
    // _chatRoomSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      List<DocumentSnapshot> temp = await getOrders(
          widget.username['username'], widget.username['shoppingMode']);
      List<DocumentSnapshot> temp2 = await getChatRoom(
          widget.username['username'], widget.username['shoppingMode']);
      print('temp2 ----------');
      print(temp2);

      if (mounted) {
        setState(() {
          orders = temp;
          chatRooms = temp2;
        });
      }
    } catch (e) {
      print('Error initializing data: $e');
    }
  }

  Future<List<QueryDocumentSnapshot<Object?>>> getChatRoom(
      username, shoppingMode) async {
    QuerySnapshot querySnapshot;
    if (shoppingMode) {
      querySnapshot = await FirebaseFirestore.instance
          .collection('ChatRoom')
          .where(FieldPath.documentId,
              isGreaterThanOrEqualTo: '$username-', isLessThan: '$username~')
          .get();
    } else {
      querySnapshot = await FirebaseFirestore.instance
          .collection('ChatRoom')
          .where(FieldPath.documentId,
              isGreaterThanOrEqualTo: '-$username', isLessThan: '~$username')
          .get();
    }

    return querySnapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Scaffold(
        appBar: AppBar(
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MESSAGES', style: TextStyle(fontWeight: FontWeight.bold),),
              Divider(color: Colors.black,)
            ],
          ) ,
          automaticallyImplyLeading: false,
        ),
        body: orders == null? const Center(child: CircularProgressIndicator())
            : ListView.builder(
              padding: EdgeInsets.all(10),
                itemCount: chatRooms!.length,
                itemBuilder: (BuildContext context, int index) {
                  Map<String, dynamic> order =
                      orders![index].data() as Map<String, dynamic>;
                  Map<String, dynamic> chatRoom =
                      chatRooms![index].data() as Map<String, dynamic>;
                  // print('---------- length ');
                  // print(chatRooms!.length);
                  String sellerName = widget.username['shoppingMode']
                      ? (chatRoom['seller']['fname'] +
                          " " +
                          chatRoom['seller']['lname'])
                      : chatRoom['customer']['fname'] +
                          " " +
                          chatRoom['customer']['lname'];
                  // print(sellerName);
                  print('-------');
                  print(order);
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                    username: widget.username,
                                    order: chatRoom,
                                    seller: sellerName,
                                  )));
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(20),
                        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                        titleTextStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Color.fromRGBO(54, 91, 109, 1.0)
                        ),
                        // subtitleTextStyle: ,

                        leading: CircleAvatar(),
                        title: Text(sellerName),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
