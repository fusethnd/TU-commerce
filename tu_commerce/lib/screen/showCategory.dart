import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ShowCategory extends StatefulWidget {
  final String  category;
  final List<DocumentSnapshot>? allItem;

  ShowCategory({Key? key, required this.category, required this.allItem}) : super(key: key);

  @override
  State<ShowCategory> createState() => _ShowCategoryState();
}

class _ShowCategoryState extends State<ShowCategory> {
  List<DocumentSnapshot> categoryItem = [];
  List<DocumentSnapshot> allItem = [];

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  Future<void> _initializeState() async {
    List<DocumentSnapshot> item = await filterCategory(widget.category);

    setState(() {
      allItem = widget.allItem!;
      categoryItem = item;
    });
  }

  Future<List<DocumentSnapshot>> filterCategory(String query) async {
    List<DocumentSnapshot> filteredItems = [];

    for (DocumentSnapshot item in widget.allItem!) {
      String itemName = item['category'].toString().toLowerCase();

      if (itemName.contains(query.toLowerCase())) {
        filteredItems.add(item);
      }
    }

    return filteredItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category),),
      body: ListView.builder(
          itemCount: categoryItem.length,
          itemBuilder: (context,index){

            String? imageUrl = categoryItem[index]['link'];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Image.network(imageUrl!),
                ),
                title: Text(categoryItem[index]['prodName'].toString()),
                subtitle: Row(
                  children: [
                    Text(categoryItem[index]['price'].toString()),
                    SizedBox(width: 8,),
                    ElevatedButton(onPressed: (){}, child: Icon(Icons.favorite),)
                  ],
                ),
              ),
            );
          }
        )
      
    );
  }
}