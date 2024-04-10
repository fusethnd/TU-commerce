import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tu_commerce/function/Firebase.dart';
import 'package:tu_commerce/screen/tabContent.dart';

class ToShipScreen extends StatefulWidget {
  final Map<String, dynamic> username;
  
  ToShipScreen({Key? key, required this.username}) : super(key: key);

  @override
  State<ToShipScreen> createState() => _ToShipScreenState();
}

class _ToShipScreenState extends State<ToShipScreen> {
  List<dynamic>? orders;
  Map<int, bool> _isBottomSheetOpen = {};

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    List<DocumentSnapshot> temp = await getOrders(widget.username['username'], widget.username['shoppingMode']); // query หา order ตาม Mode
    setState(() {
      orders = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MESSAGES'),
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
                return Card(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(name),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _isBottomSheetOpen[index] = !(_isBottomSheetOpen[index] ?? false); // จะสร้าง index ของแต่ละ สินค้าไว้ว่าได้กดปุ่มลุกศรหรือยังเอาไว้เช็คลูกศรเปิดปิด
                              });
                            },
                            icon: Icon((_isBottomSheetOpen[index] ?? false) ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                          ),
                        ],
                      ),
                      Text(order['product']['prodName']),
                      Image.network(order['product']['link'],),
                      // แนะนำตั้งแต่บรรทัดนี้คิดให้ดีก่อนแก้ 
                      // ตอนนี้ทำเป็นแบบให้กดปุ่มถัดไปได้ 1 ปุ่ม เพื่อที่จะขยับ status
                      Visibility( // จะโชว์ status ตอนกดลุกศร
                        visible: _isBottomSheetOpen[index] ?? false,
                        child:  Row(
                          children: [
                            // status ที่ 0 คือเริ่มต้น
                              IgnorePointer(
                                ignoring: status > 0, 
                                child:IconButton(onPressed: () async{
                                    await updateStatus(order,0,index); // เปลี่ยน status หลังกด
                                    setState(() {
                                      _initializeData(); //ให้มันไปรี query พวกไอเท็มๆ ต่างๆใหม่บรรทัดสำคัญเพราะว่ามันจะทำให้สี status เปลี่ยนทันที
                                    });
                                  }, icon: Icon(Icons.star),color: status == 0 ? Colors.red : Colors.grey, // 
                                ),
                              ),
                            // จบ status ที่ 0
                            // status ที่ 1
                              IgnorePointer(
                                ignoring: status > 1,
                                child: IconButton(onPressed: () async {
                                    await updateStatus(order,1,index);
                                    setState(() {
                                      _initializeData();
                                    });
                                }, icon: Icon(Icons.directions_car),color: status == 1 ? Colors.red : Colors.grey,)
                              ),
                              IgnorePointer(
                                ignoring: status > 2 || status < 1,
                                child: IconButton(onPressed: ()async {
                                    await updateStatus(order,2,index);
                                    setState(() {
                                      _initializeData();
                                    });
                                }, icon: Icon(Icons.location_on),color: status == 2 ? Colors.red : Colors.grey,),
                              ),
                              IgnorePointer(
                                ignoring: status > 3 || status < 2,
                                child: IconButton(onPressed: ()async {
                                  if (widget.username['username'] == order['username']['username']){
                                    print('in site delete');
                                    // ถ้าเกิดคนกดเป็นคือคนซื้อก็จะลบ order นี้ออกแต่ยังไม่ได้ตัดตังนะ
                                    await FirebaseFirestore.instance.collection('Orders').doc(orders![index].id).delete();
                                  }
                                  else {
                                    // ถ้าเกิดคนกดเป็นคือคนขายก็จะถือว่า updata status ปกติ
                                    await updateStatus(order,3,index);
                                  }

                                  setState(() {
                                    _initializeData();
                                  });
                              }, icon: Icon(Icons.flag),color: status == 3 ? Colors.red : Colors.grey,),
                              )
                          ],
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

