import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HistoryBox extends StatelessWidget { 
  final Map<String, dynamic> partner;
  final Map<String, dynamic> product;
  final String date;
  final int status;

  HistoryBox({
    required this.partner,
    required this.product,
    required this.date,
    required this.status,
  }); 

  @override 
  Widget build(BuildContext context) { 
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: const Color.fromRGBO(242, 241, 236, 1),
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(),
              const SizedBox(width: 10,),
              Text(
                "@" + partner['username'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                status == 3 ? "Completed" : "Not Completed",
                style: const TextStyle(fontSize: 15),
              )
            ],
          ),
          const SizedBox(height: 5,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(color: Colors.white),
                child: Image.network(product['link'], fit: BoxFit.contain,),
              ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.only(left: 20),
                  height: 100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            product['prodName'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(54, 91, 109, 1.0),
                            ),
                          ),
                          const Spacer(),
                          Text(product['price'].toStringAsFixed(2) + " ฿"),
                        ],
                      ),
                      Text(
                        product['details'],
                        maxLines: 2,
                        style: const TextStyle(
                          color: Color.fromRGBO(54, 91, 109, 1.0),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        date,
                        style: const TextStyle(
                          color: Color.fromRGBO(54, 91, 109, 0.7),
                        ),
                      ),
                    ],
                  )
                )
              )
            ],
          ),
          const Divider()
          
        ],
      ) 
    );
  }
}