import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tu_commerce/function/Firebase.dart';
import 'package:tu_commerce/screen/chat.dart';
import 'package:tu_commerce/screen/navigationbarCustomer.dart';
import 'package:tu_commerce/screen/navigationbarSeller.dart';
import 'package:tu_commerce/screen/profilePicture.dart';

class InboxScreen extends StatefulWidget {
  final Map<String, dynamic> username;

  InboxScreen({Key? key, required this.username}) : super(key: key);

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  // List<dynamic>? orders;
  List<dynamic>? chatRooms;
  List<dynamic>? last_message;

  // late StreamSubscription<List<DocumentSnapshot>>? _chatRoomSubscription;
  @override
  void initState() {
    super.initState();
    _initializeData();
    // print(widget.username['shoppingMode']);
    // print(orders);
  }

  void dispose() {
    // Cancel the stream subscription
    // _chatRoomSubscription?.cancel();
    super.dispose();
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 0)); // Simulate a delay
    widget.username['shoppingmode']
        ? Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => NavigationCustomer(
                    email: widget.username['email'], temp: 3)),
            (Route<dynamic> route) => false)
        : Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    Navigation(username: widget.username, temp: 3)),
            (Route<dynamic> route) => false);
  }

  Future<void> _initializeData() async {
    try {
      List<Map<String, dynamic>?> storeLast = [];
      // List<DocumentSnapshot> temp = await getOrders(
      //     widget.username['username'], widget.username['shoppingMode']);
      List<DocumentSnapshot> temp2 = await getChatRoom(
          widget.username['username'], widget.username['shoppingMode']);

      // print('temp2 ----------');
      // print(temp2);
      for (DocumentSnapshot roomSnapshot in temp2) {
        String chatId = roomSnapshot.id;
        String name = roomSnapshot == widget.username['username']
            ? widget.username['username']
            : roomSnapshot['customer']['username'];
        print(chatId);
        print(name);
        Map<String, dynamic>? lastMessageData = await lastMessage(chatId, name);
        // print('---------- last -----------');
        // print(lastMessageData);
        storeLast.add(lastMessageData);
      }
      print('--------- last ');
      print(storeLast.length);
      if (mounted) {
        setState(() {
          last_message = storeLast;
          chatRooms = temp2;
        });
      }
    } catch (e) {
      print('Error initializing data: $e');
    }
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>>>> getChatRoom(
      String username, bool shoppingMode) async {
    CollectionReference chatRoomCollection =
        FirebaseFirestore.instance.collection('ChatRoom');
    QuerySnapshot snapshot = await chatRoomCollection.get();
    List<String> documentIds = snapshot.docs.map((doc) => doc.id).toList();
    List<String> temp = [];
    for (String data in documentIds) {
      if (data.contains(username)) {
        List<String> parts = data.split("-");
        int index = parts.indexOf(username);
        print(shoppingMode);
        if ((shoppingMode == true) && (index == 0)) {
          print('in 0');
          temp.add(data);
        }
        if ((shoppingMode == false) && (index == 1)) {
          print('in 1');
          temp.add(data);
        }

        // print(index);
        // temp.add(data);
      }
    }
    print(temp);
    // await FirebaseFirestore.instance.collection('ChatRoom').where(username,arrayContains: temp).get();
    List<DocumentSnapshot<Map<String, dynamic>>> documents = [];
    for (String docID in temp) {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('ChatRoom')
          .doc(docID)
          .get();

      documents.add(snapshot);
    }
    print(documents);
    return documents;

    // if (shoppingMode) {
    //   querySnapshot = await FirebaseFirestore.instance
    //       .collection('ChatRoom')
    //       .where(FieldPath.documentId,
    //           isGreaterThanOrEqualTo: '$username-', isLessThan: '$username~')
    //       .get();
    // } else {
    //   querySnapshot = await FirebaseFirestore.instance
    //       .collection('ChatRoom')
    //       .where(FieldPath.documentId,
    //           isGreaterThanOrEqualTo: '-$username', isLessThan: '~$username')
    //       .get();
    // }
  }

  Future<Map<String, dynamic>?> lastMessage(chatId, senderName) async {
    Map<String, dynamic>? lastMessageData;
    print('-----in');
    print(chatId);
    print(senderName);
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(chatId)
        .collection('Message')
        // .where('sender', isEqualTo: senderName) // Filter by sender name
        .orderBy('time', descending: true)
        .limit(1)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      // Access the first document
      var firstDocument = querySnapshot.docs.first;
      // Convert document data to a map
      lastMessageData = firstDocument.data() as Map<String, dynamic>?;
    } else {
      // No documents found
    }
    print(querySnapshot);
    print(lastMessageData);
    print('end-------');
    return lastMessageData;
  }

  Future<Map<String, dynamic>?> message(id) async {
    List<Map<String, dynamic>> messages = await getMessages(id);
    if (messages.isNotEmpty) {
      // print(messages[0]);
      return messages[0];
    } else {
      // Handle the case where there are no messages
      return null; // or you can return an empty map {} depending on your use case
    }
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
              Text(
                'MESSAGES',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Divider(
                color: Color.fromRGBO(38, 174, 236, 0.3),
              )
            ],
          ),
          automaticallyImplyLeading: false,
        ),
        body: chatRooms == null
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: chatRooms!.length,
                itemBuilder: (BuildContext context, int index) {
                  // Map<String, dynamic> order =
                  //     orders![index].data() as Map<String, dynamic>;
                  Map<String, dynamic> chatRoom =
                      chatRooms![index].data() as Map<String, dynamic>;
                  // print('---------- length ');
                  // print(chatRooms!.length);
                  // print(chatRoom);
                  // getUserByEmail(widget.username);
                  String sellerName = widget.username['shoppingMode']
                      ? (chatRoom['seller']['fname'] +
                          " " +
                          chatRoom['seller']['lname'])
                      : chatRoom['customer']['fname'] +
                          " " +
                          chatRoom['customer']['lname'];
                  String lastMessage = last_message![index]['message'] != null
                      ? last_message![index]['message']
                      : last_message![index]['link'] != null
                          ? "Image"
                          : "Map";

                  String link_image = widget.username['shoppingMode']
                      ? chatRoom['seller']['email']
                      : chatRoom['customer']['email'];
                  print('------- check');
                  print(link_image);
                  // print(sellerName);
                  // print(order);
                  return FutureBuilder(
                      future: getUserByEmail(link_image),
                      builder: (BuildContext context,
                          AsyncSnapshot<dynamic> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          // While the future is being resolved, you can display a loading indicator.
                          return Center(child: CircularProgressIndicator());
                        } else {
                          if (snapshot.hasData && snapshot.data != null) {
                            // If data is available, you can access it using snapshot.data.
                            // Here, you can extract and display the user information.
                            Map<String, dynamic>? userData = snapshot.data;
                            // Example: Display user's name
                            print(userData);

                            return Column(children: [
                              GestureDetector(
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
                                  color: const Color.fromRGBO(242, 241, 236, 1),
                                  surfaceTintColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0)),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(10),
                                    // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                                    titleTextStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color:
                                            Color.fromRGBO(54, 91, 109, 1.0)),
                                    // subtitleTextStyle: ,

                                    leading: SizedBox(
                                      width: 100,
                                      height: 100,
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.all(Radius.circular(50)),
                                        child: Container(
                                          color: const Color.fromRGBO(219, 232, 231, 1),
                                          child: ProfilePicture(user: userData!)
                                        )
                                      ),
                                    ),
                                    title: Text(sellerName),
                                    subtitle: Text(lastMessage),
                                  ),
                                ),
                              ),
                              const Divider(
                                height: BorderSide.strokeAlignOutside,
                                color: Color.fromRGBO(38, 174, 236, 0.3),
                              ),
                              // const Divider(
                              //   color: Color.fromRGBO(219, 241, 240, 1.0),
                              // )
                            ]);
                          } else {
                            // If there's no data, it might mean the user doesn't exist or there was an error.
                            // You can display an appropriate message.
                            return Text('User not found');
                          }
                        }
                      });
                },
              ),
      ),
    );
  }
}
