import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tu_commerce/function/Firebase.dart';
import 'package:tu_commerce/model/product.dart';
import 'package:tu_commerce/screen/navigationbarCustomer.dart';
import 'package:tu_commerce/screen/noticeScreen.dart';
import 'package:tu_commerce/screen/searchPage.dart';
import 'package:tu_commerce/screen/productBox.dart';
import 'package:http/http.dart' as http;
import '../model/noticeApi.dart';

class CustomerHome extends StatefulWidget {
  final Map<String, dynamic>  username;
  
  CustomerHome({Key? key, required this.username}) : super(key: key);

  @override
  State<CustomerHome> createState() => CustomerHomeState();
}

class CustomerHomeState extends State<CustomerHome> {
  var cate = ['normal','electric'];
  List<DocumentSnapshot> allItem = [];
  late FirebaseFirestore query;
  final storage = FirebaseStorage.instance;
  List<DocumentSnapshot> searchItem = [];
  TextEditingController searchController = TextEditingController();
  bool isSearchEmpty = true;
  List<dynamic>? fav;
  Map<String, dynamic>? allNotice;
  final NotificationService _notificationService = NotificationService();
  @override
  void initState() {
    super.initState();
    _initializeData();
    print(widget.username['shoppingMode']);
  }



  Future<void> _initializeData() async { // 
    List<DocumentSnapshot> items = await getProducts();// query prodcut ทั้งหมด
    // String? token = await FirebaseApi().initNotifications();
    // print(token);
    Map<String, dynamic>? tempMap = (await FirebaseFirestore.instance
        .collection('Notice')
        // ignore: prefer_interpolation_to_compose_strings
        .doc(widget.username['username'])
        .get())
        .data();

    if (tempMap == null) {
      tempMap = {
        "length":0,
        "noticeList":[]
      };
    }
    print(tempMap);
    // if (widget.username.containsKey('tokenNotice')){
    //   await _notificationService.requestNotificationPermissions();
    //   // print("Token: " + widget.username['tokenNotice']);
    //   await sendNotificationToUser(widget.username['tokenNotice'], "New Message", "You have a new message!");
    //   await _notificationService.sendNotification(widget.username['tokenNotice'],'Hello');

    // }
    if (mounted){
      setState(() {
        allItem = items; // ตัว hold ไว้เฉยๆ
        searchItem = items; // ใช้ตัวนี้ในการโชว์
        fav = widget.username['favorite']; // เก็บแค่ favorite เอามาจาก init
        allNotice = tempMap;
      });

    }
  }

  void filterItem(String query){ // คำสั่ง search 
    List<DocumentSnapshot> filteredItems = []; // ที่เก็บทุกตัวที่ตรงตามชื่อที่ search
    if (query.isEmpty) { // โชว์ทั้งหมดตอนที่ไม่ได้เขียนอะไร หมายถึงหลังจากเขียนแล้วลบ
      filteredItems = allItem; // set ให้เป็น Item ทั้งหมด
      setState(() {
        isSearchEmpty = true; // ถ้าเกิดโล่งก็โชว์ค่าว่างไว้
      });
    } 
    else{ // กรณี มีคำทิ้งไว้ในที่ search
      for (DocumentSnapshot item in allItem){
        String itemName = item['prodName'].toString().toLowerCase();
        if (itemName.contains(query.toLowerCase())){
          filteredItems.add(item); // add ทั้งหมดเข้า
        }
      }
      setState(() {
        isSearchEmpty = false; //set ว่าไม่ False เพื่อจะได้ไม่โชว์ทั้งหมด
      });
    }
    setState(() {
      searchItem = filteredItems; // setค่า
    });
  }
  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 0)); // Simulate a delay
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) =>
                NavigationCustomer(email: widget.username['email'])),
        (Route<dynamic> route) => false);
  }
  void updateFavoriteStatus(int index) async {
    List<dynamic>? favorites;

    if (isFavorite(searchItem[index].data() as  Map<String, dynamic>?,fav)) { // กรณีที่หัวใจที่กดมันซ้ำก็จะถือว่าลบ
      favorites = await updateUser(widget.username, searchItem[index].data() as Map<String, dynamic>?,'remove');
    } else { // กรณีที่หัวใจยังไม่ได้กดก็จะถือว่าให้เพิ่ม
      favorites = await updateUser(widget.username, searchItem[index].data() as Map<String, dynamic>?,'update');
    }

    setState(() {
      fav = favorites;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Scaffold(
        body: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AppBar(
                  title: Image.asset(
                    'assets/images/Banner.png',
                    fit: BoxFit.contain,
                  ),
                  backgroundColor: Colors.grey,
                  toolbarHeight: 200,
                  automaticallyImplyLeading: false,
                ),
                Positioned(
                  top: 50,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(Icons.notifications, size: 30,),
                    color:  (allNotice != null) && (allNotice!['length'] != allNotice!['noticeList'].length) ? Colors.red : const Color.fromRGBO(54, 91, 109, 1.0),
                    onPressed: () async{
                      print(allNotice!['noticeList'].isEmpty);
                      print(allNotice!['noticeList'] != []);
                      if (allNotice!['noticeList'].isEmpty == false) {
                        print('in notice if ---------');
                        await FirebaseFirestore.instance.collection('Notice').doc(widget.username['username']).update({'length':allNotice!['noticeList'].length});
                      }
                      Navigator.push(context, MaterialPageRoute(builder: (context) => NoticeSreen(username: widget.username)));
                      if (mounted){
                        setState(() {
                          _initializeData();
                        });
                      }
                    },
                  )
                ),
                Positioned(
                  top: 200,
                  left: 70,
                  right: 70,
                  child: TextFormField(
                    onChanged: filterItem,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search here',
                      fillColor: Color.fromRGBO(65, 193, 186, 1.0),
                      filled: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40,),
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.all(10),
              child: const Text(
                "Categories",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(54, 91, 109, 1.0)
                ),  
              ),
            ),
            Visibility( // เอาไว้ใช้ตอน search ถ้าเกิด search อยู่จะไม่โชว์ 2 ปุ่มนี้
                visible: isSearchEmpty,
                child: MaterialApp(
                  theme: ThemeData(
                    elevatedButtonTheme: ElevatedButtonThemeData(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(const Color.fromRGBO(65, 193, 186, 1.0)),
                        shape: MaterialStateProperty.all(const RoundedRectangleBorder()),
                        fixedSize: MaterialStateProperty.all(const Size(100, 100))
                      )
                    )
                  ),
                  home: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(EdgeInsets.zero),
                          foregroundColor: MaterialStateProperty.all(Colors.white),
                          iconSize: MaterialStateProperty.all(35)
                        ),
                        onPressed: (){ // โชว์ถาม category
                          Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationCustomer(email: widget.username['email'],temp: 6,category: 'Normal',allItem: allItem,)));
                        }, 
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.storefront),
                            Text("Normal")
                          ],
                        )
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(EdgeInsets.zero),
                          foregroundColor: MaterialStateProperty.all(Colors.white),
                          iconSize: MaterialStateProperty.all(35)
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationCustomer(email: widget.username['email'],temp: 6,category: 'electric',allItem: allItem)));
                        }, 
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.devices_other),
                            Text("Electronics")
                          ],
                        )
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(EdgeInsets.zero),
                          foregroundColor: MaterialStateProperty.all(Colors.white),
                          iconSize: MaterialStateProperty.all(35)
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationCustomer(email: widget.username['email'],temp: 6,category: 'fashion',allItem: allItem)));
                        }, 
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.checkroom),
                            Text("Fashion")
                          ],
                        )
                      )
                    ],
                  ),
                ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.all(10),
              child: const Text(
                "New Product",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(54, 91, 109, 1.0)
                ),  
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(ProductGridViewStyle.padding),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: ProductGridViewStyle.gridCrossAxisCount,
                  childAspectRatio: ProductGridViewStyle.aspectRatio
                ), // โชว์ product ทั้งหมด เรียงตามวันที่สร้าง
                itemCount: searchItem.length,
                itemBuilder: (context,index){
                  bool favorite = isFavorite(searchItem[index].data() as  Map<String, dynamic>?,fav); // check ว่าตอนนี้กดปุ่มหรือยังเอาไว้โชว์ สี
                  String? imageUrl = searchItem[index]['link']; // link image
      
                  return ProductBox(
                    imageUrl: imageUrl,
                    prodName: searchItem[index]['prodName'].toString(),
                    prodDetail: searchItem[index]['details'].toString(),
                    price: searchItem[index]['price'].toStringAsFixed(2),
                    onPressed: () async {
                                updateFavoriteStatus(index);
                              },
                    favorite: favorite,
                    username: widget.username,
                    item: searchItem[index].data() as  Map<String, dynamic>?,
                  );
                }
              ),
            )
          ],
        )
      ),
    );
  }
}

