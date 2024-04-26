import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tu_commerce/screen/productBox.dart';
import '../function/Firebase.dart';
import 'navigationbarCustomer.dart';

class ShowCategory extends StatefulWidget {
  final String  category;
  final List<DocumentSnapshot>? allItem;
  final Map<String, dynamic>  username;

  ShowCategory({Key? key, required this.category, required this.allItem,required this.username}) : super(key: key);

  @override
  State<ShowCategory> createState() => _ShowCategoryState();
}

class _ShowCategoryState extends State<ShowCategory> {
  List<DocumentSnapshot> categoryItem = [];
  List<DocumentSnapshot> allItem = [];
  List<dynamic>? fav;
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
      fav = widget.username['favorite'];
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
  void updateFavoriteStatus(int index) async {
    List<dynamic>? favorites;

    if (isFavorite(categoryItem[index].data() as  Map<String, dynamic>?,fav)) { // กรณีที่หัวใจที่กดมันซ้ำก็จะถือว่าลบ
      favorites = await updateUser(widget.username, categoryItem[index].data() as Map<String, dynamic>?,'remove');
    } else { // กรณีที่หัวใจยังไม่ได้กดก็จะถือว่าให้เพิ่ม
      favorites = await updateUser(widget.username, categoryItem[index].data() as Map<String, dynamic>?,'update');
    }

    setState(() {
      fav = favorites;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category),),
      body: GridView.builder(
          padding: const EdgeInsets.all(ProductGridViewStyle.padding),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: ProductGridViewStyle.gridCrossAxisCount,
            childAspectRatio: ProductGridViewStyle.aspectRatio
          ),
          itemCount: categoryItem.length,
          itemBuilder: (context,index){
            bool favorite = isFavorite(categoryItem[index].data() as  Map<String, dynamic>?,fav); // check ว่าตอนนี้กดปุ่มหรือยังเอาไว้โชว์ สี
            String? imageUrl = categoryItem[index]['link'];

            return ProductBox(
              imageUrl: imageUrl,
              prodName: categoryItem[index]['prodName'].toString(),
              prodDetail: categoryItem[index]['details'].toString(),
              price: categoryItem[index]['price'].toString(),
              onPressed: () async {
                          updateFavoriteStatus(index);
                        },
              favorite: favorite,
              username: widget.username,
              item: categoryItem[index].data() as  Map<String, dynamic>?,
            );
          }
        )
    );
  }
}