import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tu_commerce/function/Firebase.dart';
import 'package:tu_commerce/main.dart';
import 'package:tu_commerce/model/message.dart';
// import 'package:tu_commerce/screen/navigationbarCustomer.dart';
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
          Flexible(
            child: allMessage != null ? ListView.builder(
              reverse: true,
              itemCount: allMessage?.length,
              itemBuilder: (context, index) {
                Map<String, dynamic>? messageData = allMessage?[index];
            
                bool isSender = messageData?['sender'] == widget.username['username'];
                bool isImg = messageData?['link'] != null;
                bool isText = messageData?['message'] != null;
                bool isLocation = messageData?['latitude'] != null;
            
                final screenWidth = MediaQuery.of(context).size.width;
                final screenHeight = MediaQuery.of(context).size.height;

                return Row(
                  mainAxisAlignment: isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        margin: EdgeInsets.only(bottom: 10, left: isImg ? 10 : 20, right: isImg ? 10 : 20),
                        constraints: isLocation 
                          ? BoxConstraints(maxWidth: screenWidth*0.9, maxHeight: screenHeight*0.5)
                          : BoxConstraints(maxWidth: screenWidth*0.7, maxHeight: screenHeight*0.5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: isImg ? Colors.transparent 
                                : isSender ? const Color.fromRGBO(65, 193, 186, 1.0) : const Color.fromRGBO(219, 232, 231, 1)
                        ),
                        child: isImg 
                            ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  child: Image.network(
                                    messageData!['link'],
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  width: double.infinity,
                                  height: 50,
                                  decoration: const BoxDecoration(
                                    color: Color.fromRGBO(65, 193, 186, 1.0),
                                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(10))
                                  ),
                                  child: Text(
                                    messageData['message'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  )
                                )
                              ],
                            )
                            : isText ? Text(messageData!['message'])
                            : isLocation != null ? SizedBox(
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
                    ),
                  ],
                );
              },
            )
            : CircularProgressIndicator()
          ),
          Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.all(10),
              color: widget.username['shoppingMode'] ? const Color.fromRGBO(65, 193, 186, 1.0) : const Color.fromRGBO(38, 174, 236, 1),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _getCurrentLocation,
                    icon: const Icon(Icons.add),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 5,),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Message here',
                      ),
                      controller: _textEditingController,
                      onChanged: (context) {
                        message.message = context;
                        // message.time = FieldValue.serverTimestamp() as DateTime?;
                      },
                    ),
                  ),
                  const SizedBox(width: 5,),
                  IconButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white)
                    ),
                    onPressed: addMessage, icon: const Icon(Icons.send)
                  )
                ],
              ),
            )
          )
        ],
      ),
    );
  }
}
