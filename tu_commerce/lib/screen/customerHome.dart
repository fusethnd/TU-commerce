import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tu_commerce/function/Firebase.dart';
import 'package:tu_commerce/model/product.dart';
import 'package:tu_commerce/screen/navigationbarCustomer.dart';
import 'package:tu_commerce/screen/searchPage.dart';

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


  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async { // 
    List<DocumentSnapshot> items = await getProducts();// query prodcut ทั้งหมด
    setState(() {
      allItem = items; // ตัว hold ไว้เฉยๆ
      searchItem = items; // ใช้ตัวนี้ในการโชว์
      fav = widget.username['favorite']; // เก็บแค่ favorite เอามาจาก init
    });
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

    
    return Scaffold(
      appBar: AppBar(title: Text('Home'),),
      body: Column(
        children: [
          Container(
            child: TextFormField(
              onChanged: filterItem,
              decoration: const InputDecoration(
                hintText: 'Search here'
              ),
            )
          ),
          Visibility( // เอาไว้ใช้ตอน search ถ้าเกิด search อยู่จะไม่โชว์ 2 ปุ่มนี้
              visible: isSearchEmpty,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: (){ // โชว์ถาม category
                      Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationCustomer(email: widget.username['email'],temp: 6,category: 'Normal',allItem: allItem,)));
                    }, 
                    child: const Text('Normal Category')
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationCustomer(email: widget.username['email'],temp: 6,category: 'electric',allItem: allItem)));
                    }, 
                    child: const Text('Electric Category')
                  )
                ],
              ),
          ),
          Text("Product"),
          Expanded(
            child: ListView.builder( // โชว์ product ทั้งหมด เรียงตามวันที่สร้าง
              itemCount: searchItem.length,
              itemBuilder: (context,index){
                
                bool favorite = isFavorite(searchItem[index].data() as  Map<String, dynamic>?,fav); // check ว่าตอนนี้กดปุ่มหรือยังเอาไว้โชว์ สี
                String? imageUrl = searchItem[index]['link']; // link image

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Image.network(imageUrl!),
                    ),
                    title: Text(searchItem[index]['prodName'].toString()),
                    subtitle: Row(
                      children: [
                        Expanded(child: Text(searchItem[index]['price'].toString()),),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              updateFavoriteStatus(index);
                            }, 
                            child: Icon(Icons.favorite,color: favorite ? Colors.pink : Colors.black,),
                          )
                        )
                      ],
                    ),
                  ),
                );
              }
            ),
          )
        ],
      )
    );
  }
}

