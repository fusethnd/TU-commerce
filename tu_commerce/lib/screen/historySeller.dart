import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tu_commerce/function/Firebase.dart';
import 'package:intl/intl.dart';

class HistorySeller extends StatefulWidget {
  final Map<String, dynamic> username;
  
  HistorySeller({Key? key, required this.username}) : super(key: key);
  @override
  State<HistorySeller> createState() => _HistorySellerState();
}

class _HistorySellerState extends State<HistorySeller> {

  late List<dynamic> allItem = [];
  late List<dynamic> searchItem = [];
  TextEditingController searchController = TextEditingController();
  bool? status;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async { // 
    Map<String, dynamic> items = await getHistory(widget.username['historyID']);// query prodcut ทั้งหมด
    if (!items.containsKey('ordersSeller')){
      items['ordersSeller'] = [];
    }

    setState(() {
      allItem = items['ordersSeller']; // ตัว hold ไว้เฉยๆ
      searchItem = items['ordersSeller']; // ใช้ตัวนี้ในการโชว์
    });
  }

  void filterItem(String query){ // คำสั่ง search 
    List<dynamic>? filteredItems = []; // ที่เก็บทุกตัวที่ตรงตามชื่อที่ search
    if (query.isEmpty) { // โชว์ทั้งหมดตอนที่ไม่ได้เขียนอะไร หมายถึงหลังจากเขียนแล้วลบ
      filteredItems = allItem; // set ให้เป็น Item ทั้งหมด
    } 
    else{ // กรณี มีคำทิ้งไว้ในที่ search
      for (Map<String, dynamic> item in allItem){
        String itemName = item['product']['prodName'].toString().toLowerCase();
        if (itemName.contains(query.toLowerCase())){
          filteredItems.add(item); // add ทั้งหมดเข้า
        }
      }
    }
    setState(() {
      searchItem = filteredItems!; // setค่า
    });
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('History'),),
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
          Expanded(
            child: ListView.builder(
              itemCount: searchItem.length, // Ensure itemCount is not greater than the length of the list
              itemBuilder: (context,index){
                Map<String, dynamic>? item = searchItem[index];
                DateTime timestamp = item!['date'].toDate(); 
                String formattedDate = DateFormat.yMMMd().format(timestamp); 

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Image.network(item?['product']['link']),
                    ),
                    title: Text(item['product']['prodName'] ?? ''),
                    subtitle: Text(formattedDate),
                      
                  )
                );
              } 
            ),
          ),
          ElevatedButton(
            onPressed: () async {
            await FirebaseFirestore.instance.collection('History').doc(widget.username['historyID']).update({'ordersSeller':[]});
            _initializeData();
                
            }, 
            child: Text('Remove History')
          )
        ],
      )
    );
  }
}