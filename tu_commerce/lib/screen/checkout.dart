import 'package:flutter/material.dart';
import 'package:tu_commerce/function/Firebase.dart';
import 'package:tu_commerce/model/order.dart';
import 'package:tu_commerce/screen/chat.dart';

import 'navigationbarCustomer.dart';

class CheckOut extends StatefulWidget {
  final Map<String, dynamic>  username;
  final Map<String, dynamic>? product;

  CheckOut({Key? key, required this.username,this.product}) : super(key: key);

  @override
  State<CheckOut> createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOut> {
  Orders? order;
  @override
  void initState() {
    super.initState();
    setState(() {
      order = Orders();
      order?.buyer = widget.username;
      order?.product = widget.product;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.product!['prodName']),),
      body: Column(
        children: [
          Image.network(widget.product!['link']),
          Text(widget.product!['price'].toString()),
          Text(widget.product!['prodName']),
          Text(widget.product!['details']),
          ElevatedButton(
            onPressed: () async{
              print('-----------');
              
              order!.time = DateTime.now();
              await saveOrderDB(order!);
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (context) => NavigationCustomer(email: widget.username['email'],temp: 8,product: widget.product,))
              );
            }, 
            child: Text('check out'))
        ],
      ),
    );
  }
}