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
  late StreamSubscription<List<DocumentSnapshot>>? _chatRoomSubscription;
  @override
  void initState() {
    super.initState();
    _initializeData();
    print(widget.username['shoppingMode']);
  }

  void dispose() {
    // Cancel the stream subscription
    _chatRoomSubscription?.cancel();
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
    return Scaffold(
      appBar: AppBar(
        title: Text('MESSAGES'),
      ),
      body: orders == null
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
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
                    child: ListTile(
                      leading: CircleAvatar(),
                      title: Text(sellerName),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
