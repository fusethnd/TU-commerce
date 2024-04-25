import 'package:flutter/material.dart';
import 'package:tu_commerce/screen/favorite.dart';

import 'navigationbarCustomer.dart';

class ProductBox extends StatelessWidget { 
  final String? imageUrl; 
  final String prodName; 
  final String prodDetail; 
  final String price; 
  void Function()? onPressed;
  final bool favorite;
  final Map<String, dynamic>? username;
  final Map<String, dynamic>? item;

  ProductBox({
    required this.imageUrl, 
    required this.prodName, 
    required this.prodDetail, 
    required this.price, 
    required this.onPressed, 
    required this.favorite,
    required this.username,
    required this.item,
  }); 

  @override 
  Widget build(BuildContext context) { 
    // return Card(
    //     child: ListTile(
    //       leading: CircleAvatar(
    //         child: Image.network(imageUrl!),
    //       ),
    //       title: Text(prodName),
    //       subtitle: Row(
    //         children: [
    //           Expanded(child: Text(price),),
    //           Expanded(
    //             child: ElevatedButton(
    //               onPressed: onPressed,
    //               child: Icon(Icons.favorite, color: favorite ? Colors.pink : Colors.black,),
    //             )
    //           )
    //         ],
    //       ),
    //     ),
    // );
    return GestureDetector(
      onTap: (){
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NavigationCustomer(email: username!['email'],temp: 7,product: item,))
        );
      },
      child: Card(
        child: Column(
          children: [
            Stack(
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                        color: Colors.white
                    ),
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                      right: 5,
                      top: 5,
                      child: Icon(Icons.favorite, color: favorite ? Colors.pink : Colors.black,)
                  )
                ]
            ),
            Container(
              width: 150,
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Color.fromRGBO(219, 241, 240, 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(prodName),
                  Text(prodDetail),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(price),
                  )
                ],
              ),
            )
          ],
        ),
      )
    ) ;


  } 
}