import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tu_commerce/model/product.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => CustomerHomeState();
}

class CustomerHomeState extends State<CustomerHome> {
  var cate = ['normal','electric'];
  List<DocumentSnapshot> newItem = [];
  late FirebaseFirestore query;
  final storage = FirebaseStorage.instance;
  List<DocumentSnapshot> searchItem = [];

  Future<List<DocumentSnapshot>> getProducts() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Product')
        .orderBy('time')
        .get();
    
    print('----------');
    print(querySnapshot.docs);
    return querySnapshot.docs;
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
    // setState(() {
    //   searchItem = newItem;
    // });

  }
  Future<void> _initializeData() async {
    List<DocumentSnapshot> items = await getProducts();
    print('---- item ----');
    print(items);
    setState(() {
      newItem = items;
      searchItem = items;
    });
  }
  void filterItem(String query){
    List<DocumentSnapshot> filteredItems = [];
    if (query.isEmpty) {
      filteredItems = newItem;
    }
    else{
      for (DocumentSnapshot item in newItem){
        String itemName = item['prodName'].toString().toLowerCase();

        if (itemName.contains(query.toLowerCase())){
          filteredItems.add(item);
        }
      }
    }
    setState(() {
      searchItem = filteredItems;
    });
  }

  void filterCategory(String query){
    List<DocumentSnapshot> filteredItems = [];

    for (DocumentSnapshot item in newItem){
        String itemName = item['category'].toString().toLowerCase();

        if (itemName.contains(query.toLowerCase())){
          filteredItems.add(item);
        }
    }
    setState(() {
      searchItem = filteredItems;
    });
  }
  @override
  Widget build(BuildContext context) {
    print('-------- start app');
    print(searchItem);
    print(newItem);
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
          Container(
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: (){
                      filterCategory('normal');
                    }, 
                    child: const Text('Normal Category')
                  ),
                  ElevatedButton(
                    onPressed: () {
                      filterCategory('electric');
                    }, 
                    child: const Text('Electric Category')
                  )
                ],
              ),
          ),
          Text("Product"),
          Container(
            child: Expanded(
              
              child: ListView.builder(
                itemCount: searchItem.length,
                itemBuilder: (context,index){
                  print('----------');
                  print(searchItem);
                  String? imageUrl = searchItem[index]['link'];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Image.network(imageUrl!),
                      ),
                      title: Text(searchItem[index]['prodName'].toString()),
                      subtitle: Text(searchItem[index]['category'].toString()),
                    ),
                  );
                }
              ),
            
            )
          )
        ],
      )
    );
  }
}

