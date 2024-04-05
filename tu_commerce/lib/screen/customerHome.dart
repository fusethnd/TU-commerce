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
  List<DocumentSnapshot> newItem = [];
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




  Future<void> _initializeData() async {
    List<DocumentSnapshot> items = await getProducts();
    setState(() {
      newItem = items;
      searchItem = items;
      fav = widget.username['favorite'];
    });
  }
  void filterItem(String query){
    List<DocumentSnapshot> filteredItems = [];
    if (query.isEmpty) {
      filteredItems = newItem;
      setState(() {
        isSearchEmpty = true;
      });
    } 
    else{
      for (DocumentSnapshot item in newItem){

        String itemName = item['prodName'].toString().toLowerCase();

        if (itemName.contains(query.toLowerCase())){
          filteredItems.add(item);
        }
      }
      setState(() {
        isSearchEmpty = false;
      });
    }
    setState(() {
      searchItem = filteredItems;
    });
  }

  void updateFavoriteStatus(int index) async {
    List<dynamic>? favorites;

    if (isFavorite(searchItem[index].data() as  Map<String, dynamic>?,fav)) {
      favorites = await updateUser(widget.username, searchItem[index].data() as Map<String, dynamic>?,'remove');
    } else {
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
          Visibility(
              visible: isSearchEmpty,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationCustomer(email: widget.username['email'],temp: 6,category: 'Normal',allItem: newItem,)));
                    }, 
                    child: const Text('Normal Category')
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationCustomer(email: widget.username['email'],temp: 6,category: 'electric',allItem: newItem)));
                    }, 
                    child: const Text('Electric Category')
                  )
                ],
              ),
          ),
          Text("Product"),
          Expanded(
            child: ListView.builder(
              itemCount: searchItem.length,
              itemBuilder: (context,index){
                
                bool favorite = isFavorite(searchItem[index].data() as  Map<String, dynamic>?,fav);
                String? imageUrl = searchItem[index]['link'];
                // print('item------');
                // print(searchItem[index].data() as Map<String, dynamic>?);
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
                                //   Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context){
                                //       return NavigationCustomer(email: widget.username['email'],);
                                //   }
                                // ),(Route<dynamic> route) => false);
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

