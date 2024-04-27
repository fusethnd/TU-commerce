import 'package:flutter/material.dart';
import 'package:tu_commerce/function/Firebase.dart';
import 'package:tu_commerce/screen/productBox.dart';

class Favorite extends StatefulWidget {
  final Map<String, dynamic>  username;
  
  Favorite({Key? key, required this.username}) : super(key: key);

  @override
  State<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {

  void updateFavoriteStatus(int index,) async { //เอาไว้ลบตอนกดหัวใจ
    List<dynamic>? favorites;
    favorites = await updateUser(widget.username, widget.username['favorite'][index],'remove'); 
    setState(() {
      widget.username['favorite'] = favorites;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Favorites'), automaticallyImplyLeading: false,),
      body: GridView.builder(
          padding: const EdgeInsets.all(ProductGridViewStyle.padding),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: ProductGridViewStyle.gridCrossAxisCount,
            childAspectRatio: ProductGridViewStyle.aspectRatio
          ),
          itemCount: widget.username['favorite'].length,
          itemBuilder: (context,index){
            String? imageUrl = widget.username['favorite'][index]['link']; // เอาลิ้ง image มาจากตอน init

            return ProductBox(
              imageUrl: imageUrl,
              prodName: widget.username['favorite'][index]['prodName'].toString(),
              prodDetail: widget.username['favorite'][index]['details'].toString(),
              price: widget.username['favorite'][index]['price'].toString(),
              username: widget.username,
              item: widget.username['favorite'][index],
              onPressed: (){
                          updateFavoriteStatus(index); //ถ้ากดหัวใจจะเข้าคำสั่งนี้
                        },
              favorite: true
            );
          }
        )
      
    );
  }
}
