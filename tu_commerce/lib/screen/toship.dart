import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tu_commerce/function/Firebase.dart';
import 'package:tu_commerce/main.dart';
import 'package:tu_commerce/screen/historyBox.dart';
import 'package:tu_commerce/screen/tabContent.dart';
import 'package:intl/intl.dart';
import 'package:dotted_line/dotted_line.dart';

import '../model/noticeApi.dart';

class ToShipScreen extends StatefulWidget {
  final Map<String, dynamic> username;
  
  ToShipScreen({Key? key, required this.username}) : super(key: key);

  @override
  State<ToShipScreen> createState() => _ToShipScreenState();
}

class _ToShipScreenState extends State<ToShipScreen> {
  List<dynamic>? orders;
  Map<int, bool> _isBottomSheetOpen = {};
  final NotificationService _notificationService = NotificationService();
  @override
  void initState() {
    // super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    List<DocumentSnapshot> temp = await getOrders(widget.username['username'], widget.username['shoppingMode']); // query หา order ตาม Mode
    if (mounted) {
      setState(() {
        orders = temp;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    initState();
    return Scaffold(
      appBar: AppBar(
        title: const Text('TO SHIP'),
        leading: const GoBackButton(),
      ),
      body: orders == null
          ? Center(child: CircularProgressIndicator()) //  ฝากแก้ด้วยละกันให้ถ้าไม่มี orders ให้แก้เเป็น text
          : ListView.builder(
              itemCount: orders!.length,
              itemBuilder: (BuildContext context, int index) {

                Map<String, dynamic> order = orders![index].data(); // get Order ทั้งหมด
                int status = order['status'];
                String name = widget.username['shoppingMode'] // check ว่าอยู่่โหมดไหนถ้าอยุ่โหมดคนซื้อจะโชว์ชื่อคนขาย ถ้าอยุ่โหมดคนขายจะโ๙ว์ชื่อคนซื้อแทน
                    ? (order['product']['seller']['fname'] +
                        " " +
                        order['product']['seller']['lname'])
                    : order['username']['fname'] + " " + order['username']['lname'];
//  String nameRoom = widget.username['username'] + '-' + widget.product!['seller']['username']; // เซฟแชทรูม // ชื่อแชท buyer-seller ใช้ username
                String nameRoom = order['username']['username'] + '-' + order['product']['seller']['username'];
                print(widget.username['shoppingMode']);
                
                String formattedDate = DateFormat.yMMMd().format(order['date'].toDate());

                return Container(
                  // padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          HistoryBox(
                            partner: widget.username['shoppingMode'] ? order['product']['seller']  : order['username'],
                            product: order['product'],
                            date: formattedDate,
                            status: status
                          ),

                          Positioned(
                            bottom: 0,
                            right: 10,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isBottomSheetOpen[index] = !(_isBottomSheetOpen[index] ?? false); // จะสร้าง index ของแต่ละ สินค้าไว้ว่าได้กดปุ่มลุกศรหรือยังเอาไว้เช็คลูกศรเปิดปิด
                                });
                              },
                              icon: Icon((_isBottomSheetOpen[index] ?? false) ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                            ),
                          ),
                        ]
                      ),
                      // แนะนำตั้งแต่บรรทัดนี้คิดให้ดีก่อนแก้ 
                      // ตอนนี้ทำเป็นแบบให้กดปุ่มถัดไปได้ 1 ปุ่ม เพื่อที่จะขยับ status
                      Visibility(
                        visible: _isBottomSheetOpen[index] ?? false,
                        child: Container( // จะโชว์ status ตอนกดลุกศร
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                          color: const Color.fromRGBO(219, 232, 231, 1),
                          child:  Stack(
                            alignment: Alignment.center,
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 30),
                                child: DottedLine()
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        "STATUS",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Spacer(),
                                      Visibility(
                                        visible: status == 0,
                                        child: ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all(Colors.red),
                                            shape: MaterialStateProperty.all(
                                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))
                                            ),
                                            padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 15))
                                          ),
                                          onPressed: () async {
                                            QuerySnapshot<Map<String, dynamic>> data = await FirebaseFirestore.instance.collection('Orders').where('date',isEqualTo: order['date']).where('username.username',isEqualTo: order['username']['username']).where('product.seller.username',isEqualTo: order['product']['seller']['username']).get();
                                            String chatRoom = order['username']['username'] + '-' + order['product']['seller']['username'];
                                            print(orders!.length);

                                            DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('Credit').doc(order['username']['Credit']).get(); 
                                            Map<String, dynamic> credit = snapshot.data() as  Map<String, dynamic>;
                                            await FirebaseFirestore.instance.collection('Credit').doc(order['username']['Credit']).update({
                                            'balance': double.parse(credit['balance'].toString()) + double.parse(order['product']['price'].toString()) }  );


                                            if (orders!.length == 1){
                                              await FirebaseFirestore.instance.collection('ChatRoom').doc(chatRoom).delete();
                                              await FirebaseFirestore.instance.collection('ChatRoom').doc(chatRoom).collection('Message').get().then((snapshot) {
                                                for (DocumentSnapshot doc in snapshot.docs) {
                                                  doc.reference.delete();
                                                }
                                              });}
                                            
                                            for (DocumentSnapshot<Map<String, dynamic>> document in data.docs) {
                                                await document.reference.delete();              
                                            }
  // ===============================        
                                          }, 
                                          child: const Text('Cancel')
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // status ที่ 0 คือเริ่มต้น
                                          IgnorePointer(
                                            ignoring: (status > 0) , 
                                            child: Column(
                                              children: [
                                                IconButton(
                                                  onPressed: () async{
                                                    await updateStatus(order,0,index); // เปลี่ยน status หลังกด
                                                    // if (widget.username.containsKey('tokenNotice')){
                                                    //   await _notificationService.requestNotificationPermissions();
                                                    //   // print("Token: " + widget.username['tokenNotice']);
                                                    //   await sendNotificationToUser(widget.username['tokenNotice'], "New Message", "You have a new message!");
                                                    //   await _notificationService.sendNotification(widget.username['tokenNotice'],'Hello');
                                                    //
                                                    // }
                                                    Map<String,dynamic> data = {
                                                      'status':'Get Order',
                                                      'time' : DateTime.now(),
                                                      'sellerName' : order['product']['seller']['username'],
                                                      'customer' : order['username']['username'],
                                                      'product':order['product']
                                                    };
                                                    DocumentReference noticeRef = FirebaseFirestore.instance.collection("Notice").doc(order['username']['username']);
                                                    final docSnapshot = await noticeRef.get();
                                                    if (!docSnapshot.exists) {
                                                      await noticeRef.set(
                                                        {
                                                          "noticeList" : [data],
                                                          "length":0
                                                        }
                                                      );
                                                    }else{
                                                      await noticeRef.update({"noticeList":FieldValue.arrayUnion([data])});
                                                    }
                                                    setState(()  {
                                                      _initializeData(); //ให้มันไปรี query พวกไอเท็มๆ ต่างๆใหม่บรรทัดสำคัญเพราะว่ามันจะทำให้สี status เปลี่ยนทันที
                                                    });
                                                  },
                                                  color: status == 0 ? Colors.red : Colors.grey,
                                                  iconSize: 30,
                                                  icon: const Icon(Icons.shopping_bag),
                                                ),
                                                const Text("To Ship")
                                              ],
                                            ),
                                          ),
                                        // จบ status ที่ 0
                                        // status ที่ 1
                                          IgnorePointer(
                                            ignoring: (status > 1 ) || (widget.username['shoppingMode'] == true),
                                            child: Column(
                                              children: [
                                                IconButton(
                                                  onPressed: () async {
                                                    // ส่งข้อความเข้าแชท
                                                    await FirebaseFirestore.instance.collection('ChatRoom').doc(nameRoom).collection('Message').add({
                                                        'sender': widget.username['username'],
                                                        'reciever': order['username']['username'],
                                                        'time':FieldValue.serverTimestamp(),
                                                        'message': 'On The Way', // แก้ข้อความตรงนี้นะ
                                                        'link': null,
                                                        'latitude': null,
                                                        'longitude': null,
                                                    });
                                                    await updateStatus(order,1,index);
                                                    Map<String,dynamic> data = {
                                                      'status':'On the way',
                                                      'time' : DateTime.now(),
                                                      'sellerName' : order['product']['seller']['username'],
                                                      'customer' : order['username']['username'],
                                                      'product':order['product']
                                                    };
                                                    print('Notice-----------------------');
                                                    DocumentReference noticeRef = FirebaseFirestore.instance.collection("Notice").doc(order['username']['username']);
                                                    final docSnapshot = await noticeRef.get();
                                                    if (!docSnapshot.exists) {
                                                      await noticeRef.set(
                                                          {
                                                            "noticeList" : [data],
                                                            "length":0
                                                          }
                                                      );
                                                    }else{
                                                      await noticeRef.update({"noticeList":FieldValue.arrayUnion([data])});
                                                    }
                                                    if (order['username'].containsKey('tokenNotice')){
                                                      await _notificationService.requestNotificationPermissions();
                                                      // print("Token: " + widget.username['tokenNotice']);
                                                      await sendNotificationToUser(order['username']['tokenNotice'], "TU Commerce", "Status update: On the way");
                                                      // await _notificationService.sendNotification(order['username']['tokenNotice'],'Hello');
                                                    }
                                                    setState(()  {

                                                      _initializeData();
                                                    });
                                                  },
                                                  color: status == 1 ? Colors.red : Colors.grey,
                                                  iconSize: 30,
                                                  icon: const Icon(Icons.directions_car),
                                                ),
                                                const Text("On the Way")
                                              ],
                                            )
                                          ),
                                          IgnorePointer(
                                            ignoring: ((status > 2 || status < 1) || (widget.username['shoppingMode'] == true)),
                                            child: Column(
                                              children: [
                                                IconButton(
                                                  onPressed: ()async {
                                                    // ส่งข้อความเข้าแชท
                                                    await FirebaseFirestore.instance.collection('ChatRoom').doc(nameRoom).collection('Message').add({
                                                        'sender': widget.username['username'],
                                                        'reciever': order['username']['username'],
                                                        'time':FieldValue.serverTimestamp(), 
                                                        'message': 'At Place', // แก้ข้อความตรงนี้นะ
                                                        'link': null, 
                                                        'latitude': null,
                                                        'longitude': null,
                                                    });
                                                    await updateStatus(order,2,index);
                                                    Map<String,dynamic> data = {
                                                      'status':'At Place',
                                                      'time' : DateTime.now(),
                                                      'sellerName' : order['product']['seller']['username'],
                                                      'customer' : order['username']['username'],
                                                      'product':order['product']
                                                    };
                                                    print('Notice-----------------------');
                                                    DocumentReference noticeRef = FirebaseFirestore.instance.collection("Notice").doc(order['username']['username']);
                                                    final docSnapshot = await noticeRef.get();
                                                    if (!docSnapshot.exists) {
                                                      await noticeRef.set(
                                                          {
                                                            "noticeList" : [data],
                                                            "length":0
                                                          }
                                                      );
                                                    }else{
                                                      await noticeRef.update({"noticeList":FieldValue.arrayUnion([data])});
                                                    }
                                                    if (order['username'].containsKey('tokenNotice')){
                                                      await _notificationService.requestNotificationPermissions();
                                                      // print("Token: " + widget.username['tokenNotice']);
                                                      await sendNotificationToUser(order['username']['tokenNotice'], "TU Commerce", "Status update: At Place");
                                                      // await _notificationService.sendNotification(widget.username['tokenNotice'],'Hello');
                                                    }
                                                    setState(()  {

                                                      _initializeData();
                                                    });
                                                  },
                                                  color: status == 2 ? Colors.red : Colors.grey,
                                                  iconSize: 30,
                                                  icon: const Icon(Icons.location_on),
                                                ),
                                                const Text("At Place")
                                              ],
                                            ),
                                          ),
                                          IgnorePointer(
                                            ignoring: ((status > 3 || status < 2) ),
                                            child: Column(
                                              children: [
                                                IconButton(
                                                  onPressed: ()async {
                                                    if (widget.username['username'] == order['username']['username']){
                                                      print('in site delete');
                                                      // ถ้าเกิดคนกดเป็นคือคนซื้อก็จะลบ order นี้ออกแต่ยังไม่ได้ตัดตังนะ
                                                      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('Credit').doc(order['product']['seller']['Credit']).get();
                                                      Map<String, dynamic>? seller =  await getUserByEmail(order['product']['seller']['email']);
                                                      if (widget.username.containsKey('historyID')){
                                                        print('contain key');
                                                        // customer
                                                        await saveHistory(order,order['username']['historyID'],widget.username,'customer');
                                                        // seller
                                                      } else{
                                                        print('dont contain key');
                                                        await saveHistory(order,'No',widget.username,'customer');
                                                      }
                                                                                
                                                      if (seller!.containsKey('historyID')){
                                                        print('contain key');
                                                        // customer
                                                        await saveHistory(order,seller['historyID'],seller,'seller');
                                                        // seller
                                                      } else{
                                                        print('dont contain key');
                                                        await saveHistory(order,'No',seller,'seller');
                                                      }
                                                                                
                                                      Map<String, dynamic> credit = snapshot.data() as  Map<String, dynamic>;
                                                      await FirebaseFirestore.instance.collection('Credit').doc(order['product']['seller']['Credit']).update({
                                                      'balance': double.parse(credit['balance'].toString()) + double.parse(order['product']['price'].toString())});

                                                      await FirebaseFirestore.instance.collection('Orders').doc(orders![index].id).delete();
                                                      String chatRoom = order['username']['username'] + '-' + order['product']['seller']['username'];
                                                      if (orders!.length == 1){
                                                        await FirebaseFirestore.instance.collection('ChatRoom').doc(chatRoom).delete();
                                                        await FirebaseFirestore.instance.collection('ChatRoom').doc(chatRoom).collection('Message').get().then((snapshot) {
                                                          for (DocumentSnapshot doc in snapshot.docs) {
                                                            doc.reference.delete();
                                                          }
                                                        });}
                                                      
                                                    }
                                                    else {
                                                      // ส่งข้อความเข้าแชท
                                                      await FirebaseFirestore.instance.collection('ChatRoom').doc(nameRoom).collection('Message').add({
                                                          'sender': widget.username['username'],
                                                          'reciever': order['username']['username'],
                                                          'time':FieldValue.serverTimestamp(), 
                                                          'message': 'Finish', // แก้ข้อความตรงนี้นะ
                                                          'link': null, 
                                                          'latitude': null,
                                                          'longitude': null,
                                                      });
                                                      // ถ้าเกิดคนกดเป็นคือคนขายก็จะถือว่า updata status ปกติ
                                                      await updateStatus(order,3,index);
                                                      Map<String,dynamic> data = {
                                                        'status':'On the way',
                                                        'time' : DateTime.now(),
                                                        'sellerName' : order['product']['seller']['username'],
                                                        'customer' : order['username']['username'],
                                                        'product':order['product']
                                                      };
                                                      print('Notice-----------------------');
                                                      DocumentReference noticeRef = FirebaseFirestore.instance.collection("Notice").doc(order['username']['username']);
                                                      final docSnapshot = await noticeRef.get();
                                                      if (!docSnapshot.exists) {
                                                        await noticeRef.set(
                                                            {
                                                              "noticeList" : [data],
                                                              "length":0
                                                            }
                                                        );
                                                      }else{
                                                        await noticeRef.update({"noticeList":FieldValue.arrayUnion([data])});
                                                      }
                                                      if (widget.username.containsKey('tokenNotice')){
                                                        await _notificationService.requestNotificationPermissions();
                                                          // print("Token: " + widget.username['tokenNotice']);
                                                        await sendNotificationToUser(order['username']['tokenNotice'], "TU Commerce", "Status update: Finish");
                                                        // await _notificationService.sendNotification(widget.username['tokenNotice'],'Hello');
                                                      }
                                                    }
                                                                                
                                                    setState(() {
                                                                                
                                                      _initializeData();
                                                    });
                                                  },
                                                  color: status == 3 ? Colors.red : Colors.grey,
                                                  iconSize: 30,
                                                  icon: const Icon(Icons.check_circle),
                                                ),
                                                const Text("Complete"),
                                                // DottedLine(lineLength: 100,)
                                              ],
                                            ),
                                        )
                                      ],
                                  ),
                                ]
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

