import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tu_commerce/function/Firebase.dart';
import 'package:tu_commerce/main.dart';
import 'package:tu_commerce/model/message.dart';
import 'package:tu_commerce/screen/navigationbarCustomer.dart';
import 'map_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> username;
  final Map<String, dynamic>? order;
  String? seller;

  ChatScreen({Key? key, required this.username, this.order, this.seller})
      : super(key: key);
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Message message = Message(); // hold message
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _textEditingController =
      TextEditingController(); // hold text
  String? chatId; // hold ID room // patern "username_customer-username_buyer"
  List<Map<String, dynamic>>? allMessage; // Hold all message sort by Time
  late GoogleMapController mapController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('------- string ---------');
    print(widget.seller.toString());
    if (mounted) {
      bool isSender =
          widget.username['username'] == widget.order!['customer']['username'];
      setState(() {
        message.sender = widget.username['username'];
        message.reciever = isSender
            ? widget.order!['customer']['username']
            : widget.order!['seller']['username'];
        chatId = widget.order!['customer']['username'] +
            '-' +
            widget.order!['seller']['username'];
      });
    }
    _initializeData();
  }

  Future<void> _initializeData() async {
    List<Map<String, dynamic>> temp = await getMessages(chatId); //get message

    if (mounted) {
      setState(() {
        allMessage = temp;
      });
    }
    // _initializeData();
  }

  Future<void> addMessage() async {
    // save message ไว้ใน firebase
    if (message.message != null && message.message!.trim().isNotEmpty) {
      // ถ้าเกิดไม่มีข้อความจะไม่เซฟให้
      _formKey.currentState!.save();

      await FirebaseFirestore.instance
          .collection('ChatRoom')
          .doc(chatId)
          .collection('Message')
          .add({
        'sender': message.sender,
        'reciever': message.reciever,
        'time': FieldValue.serverTimestamp(),
        'message': message.message,
        'link': null,
        'latitude': null,
        'longitude': null,
      });
      if (mounted) {
        setState(() {
          message.message = '';
        });
      }
      _textEditingController.clear(); // clear text ในช้องแชท
      _initializeData(); // ให้ไป query ข้อความทั้งหมด ทำให้มัน realtime
    }
  }

  void _getCurrentLocation() async {
    // get location
    Position position =
        await determinePosition(); // determinePosition เอาไว้หา latitude กับ longitude
    // Position? temp2 = await determinePosition();
    await FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(chatId)
        .collection('Message')
        .add({
      'sender': message.sender,
      'reciever': message.reciever,
      'time': FieldValue.serverTimestamp(),
      'message': null,
      'link': null,
      'latitude': position.latitude,
      'longitude': position.longitude,
    });
    if (mounted) {
      setState(() {
        message.message = '';
      });
    }
    // _markerPosition = LatLng(widget.latitude, widget.longitude);
    _initializeData(); // requery
  }

  void _onMapTapped(LatLng tappedPoint) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    QuerySnapshot snapshot = await firestore
        .collection('ChatRoom')
        .doc(chatId)
        .collection('Message')
        .where('latitude', isNull: false)
        .get();
    snapshot.docs.forEach((doc) async {
      // Get the document ID
      String docId = doc.id;
      // Update the latitude field with the new value
      await firestore
          .collection('ChatRoom')
          .doc(chatId)
          .collection('Message')
          .doc(docId)
          .update({
        'latitude': tappedPoint.latitude,
        'longitude': tappedPoint.longitude
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _initializeData();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.seller.toString()),
        leading: const GoBackButton(),
      ),
      body: Column(
        children: [
          Expanded(
            child: allMessage != null? ListView.builder(
              reverse: true,
              itemCount: allMessage?.length,
              itemBuilder: (context, index) {
                Map<String, dynamic>? messageData = allMessage?[index];

                bool isSender = messageData?['sender'] ==
                    widget.username['username'];

                return Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    margin: EdgeInsets.symmetric(
                        vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      // ใส่กรอบ
                      color: isSender ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: isSender
                        ? Alignment.centerRight
                        : Alignment
                            .centerLeft, // เอาไว้เช็คว่าเป็นคนส่งมั้ยถ้าเป็นจะโยนแชทไว้ฝั่งขวา

                    child: messageData?['link'] !=
                            null // เช็ค 3 อย่างถ้าเป็นแบบไหนจะโชว์อันนั้น เช็คว่าเป็นภาพมั้ยจาก field link
                        ? Image.network(messageData!['link']) //
                        : (messageData?['message'] !=
                                null // เช็คว่า เป็น field message มั้ยจะโชว์เป็น text
                            ? Text(messageData!['message']) //
                            : (messageData?['latitude'] !=
                                    null // เช็คว่า เป็น latitude มั้ยจะโชว์เป็น map
                                ? SizedBox(
                                    width: 500,
                                    height: 500,
                                    child: GoogleMap(
                                      initialCameraPosition:
                                          CameraPosition(
                                        target: LatLng(
                                            messageData?['latitude'],
                                            messageData?['longitude']),
                                        zoom: 15,
                                      ),
                                      onMapCreated: (controller) {
                                        mapController = controller;
                                      },
                                      markers: {
                                        Marker(
                                          markerId: MarkerId('Marker'),
                                          position: LatLng(
                                              messageData?['latitude'],
                                              messageData?[
                                                  'longitude']),
                                          infoWindow: InfoWindow(
                                            title: 'Your Location',
                                          ),
                                        ),
                                      },
                                      onTap: _onMapTapped,
                                    ),
                                  )
                                : Container() // อันนี้ไม่รู้แต่ไว้งี้หละ 5555
                            )
                          )
                        );
                      },
                    )
                  : CircularProgressIndicator()),
          Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                      child: IconButton(
                          onPressed: _getCurrentLocation,
                          icon: const Icon(Icons
                              .add)) // ปุ่มกด location กดแล้วจะโชว์ map ทันที
                      ),
                  // Expanded(
                  //   child: IconButton(
                  //     onPressed: () {},
                  //     icon: const Icon(Icons.image))
                  // ),
                  Expanded(
                    child: TextFormField(
                      // ช่องพิมพ์
                      controller: _textEditingController,
                      onChanged: (context) {
                        message.message = context;
                        // message.time = FieldValue.serverTimestamp() as DateTime?;
                      },
                      decoration:
                          const InputDecoration(hintText: 'Message here'),
                    ),
                  ),
                  Expanded(
                      // ปุ่มกดส่ง
                      child: IconButton(
                          onPressed: addMessage, icon: const Icon(Icons.send)))
                ],
              ))
        ],
      ),
    );
  }
}
