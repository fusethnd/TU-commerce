import 'package:flutter/material.dart';
import 'package:tu_commerce/screen/favorite.dart';

import 'navigationbarCustomer.dart';

class ProductGridViewStyle {
  static const double padding = 5;
  static const int gridCrossAxisCount = 2;
  static const double aspectRatio = 7/10;
}

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
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 430;
    
    return GestureDetector(
      onTap: (){
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NavigationCustomer(email: username!['email'],temp: 7,product: item,))
        );
      },
      child: Card(
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: isSmallScreen ? 170 : 200,
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                      right: 0,
                      top: 0,
                      child: RawMaterialButton(
                        constraints: const BoxConstraints(minWidth: 36),
                        shape: const CircleBorder(),
                        onPressed: onPressed,
                        child: favorite ?
                          const Icon(
                            Icons.favorite,
                            color: Colors.pink,
                            size: 30,
                          ) :
                          const Icon(
                            Icons.favorite_border_outlined,
                            color: Colors.pink,
                            size: 30,
                          )
                      )
                  )
                ]
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(219, 241, 240, 1.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prodName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(54, 91, 109, 1.0),
                          fontSize: 20
                        ),
                      ),
                      Text(
                        prodDetail,
                        maxLines: 2,
                        style: const TextStyle(
                          color: Color.fromRGBO(54, 91, 109, 0.7),
                        ),

                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          price,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(54, 91, 109, 1.0),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              )
            ]
        )
      ),
    );
  } 
}