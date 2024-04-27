import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tu_commerce/function/Firebase.dart';
import 'package:tu_commerce/screen/addProduct.dart';
import 'package:tu_commerce/screen/navigationbarSeller.dart';
import 'package:tu_commerce/screen/productBox.dart';

class StockScreen extends StatefulWidget {
  final Map<String, dynamic> email;

  StockScreen({Key? key, required this.email}) : super(key: key);
  // const Profile({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  List<Map<String, dynamic>>? allProduct;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _init();
  }

  Future<void> _init() async {
    List<Map<String, dynamic>> temp =
        await getProductsByUsername(widget.email['username']);
    print('-------- fuck you');
    print(temp);
    if (mounted) {
      setState(() {
        allProduct = temp;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // print('----------');
    // print(allProduct);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Stock'),
      ),

      body: allProduct == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Expanded(
                // child: ListView.builder(
                //     itemCount: allProduct!.length,
                //     itemBuilder: (context,index) {
                //       Map<String,dynamic> item = allProduct![index];
                //       print(item);
                //       print(allProduct);

                //     }
                //   )
                // )

                Expanded(
                  child: ListView.builder(
                    itemCount: allProduct!.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> item =
                          allProduct![index]; // Safely assume non-null with '!'
                      print(
                          item); // Debugging statement to see the data structure
                      print(allProduct); // Debugging statement to see all data

                      return ListTile(
                        leading: item['link'] != null
                            ? Image.network(
                                item['link'],
                                width:
                                    50, // Specify the width of the image for consistent sizing
                                height: 50, // Specify the height of the image
                                fit: BoxFit
                                    .cover, // Ensures the image covers the box without changing the aspect ratio
                              )
                            : SizedBox(
                                width: 50,
                                height: 50), // Placeholder if the link is null
                        title: Text(item['prodName'] ??
                            'No Product Name'), // Display the product name
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Category: ${item['category'] ?? 'No Category'}'), // Display the category
                            Text(item['details'] ??
                                'No Details'), // Display details
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                '฿ ${item['price'] ?? 'N/A'}'), // Display the price
                          ],
                        ),
                        onTap: () {
                          // Action when the entire ListTile is tapped, e.g., navigate to a detail page
                        },
                      );
                    },
                  ),
                ),
                ElevatedButton(
        onPressed: (){
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context){
              return Navigation(username: widget.email, temp: 5);
          }
        ),(Route<dynamic> route) => false);
        },
        child: Icon(Icons.add),
      )

              ],
            ),

      // ElevatedButton(
      //   onPressed: (){
      //     Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context){
      //         return Navigation(username: widget.email, temp: 5);
      //     }
      //   ),(Route<dynamic> route) => false);
      //   },
      //   child: const Text('add')
      // )
    );
  }
}
