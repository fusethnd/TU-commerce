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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100), // Adjust height as needed
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),

          // Add horizontal padding
          child: AppBar(
            title: const Text(
              'My Stock',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(60, 91, 109, 1.0),
              ),
            ),
            automaticallyImplyLeading: false,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(),
            ),
          ),
        ),
      ),

      body: allProduct == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: allProduct!.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> item =
                          allProduct![index];

                      return Column(
                        children: [
                          // Container(
                          //   width: 100,
                          //   height: 100,
                          //   decoration: BoxDecoration(color: Colors.white),
                          //   child: Image.network(
                          //     item['link'], // Use item['link'] as the image URL
                          //     fit: BoxFit.contain,
                          //   ),
                          // ),
                          ListTile(
                            leading: item['link'] != null
                                ? Container(
                                    width: 100,
                                    height: 100,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    child: Image.network(
                                      item['link'],
                                      // fit: BoxFit.contain,
                                    ),
                                  )
                                : const SizedBox(
                                    width: 100,
                                    height: 100,
                                  ),
                            title: Text(
                              item['prodName'] ?? 'No Product Name',
                              style: const TextStyle(
                                color: Color.fromRGBO(60, 91, 109, 1.0),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Category: ${item['category'] ?? 'No Category'}'),
                                const SizedBox(height: 30,),
                                Text(item['details'] ??
                                    'No Details'), // Display details
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    '฿ ${item['price'] ?? 'N/A'}',
                                    style: const TextStyle(fontSize: 15),
                                ), 
                              ],
                            ),
                            onTap: () {
                              Navigator.push(context,
                              MaterialPageRoute(builder: (context) => Navigation(username: widget.email,temp: 8,product: item),));
                            },
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width *0.9,
                            child: const Divider(
                              color: Color.fromRGBO(174, 190, 199,1),
                              thickness: 1,
                              height: 0,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Padding(
                  padding:const EdgeInsets.all(20),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Navigation(username: widget.email, temp: 5))
                        );
                        // Navigator.pushAndRemoveUntil(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) =>
                        //           Navigation(username: widget.email, temp: 5)),
                        //   (Route<dynamic> route) => false,
                        // );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(20),
                      ),
                      child: Icon(Icons.add),
                    ),
                  ),
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
