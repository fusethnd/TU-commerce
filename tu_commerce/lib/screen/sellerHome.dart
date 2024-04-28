import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tu_commerce/screen/addProduct.dart';
import 'package:tu_commerce/screen/inboxScreen.dart';
import 'package:tu_commerce/screen/navigationbarCustomer.dart';
import 'package:tu_commerce/screen/navigationbarSeller.dart';
import 'package:tu_commerce/screen/profileScreen.dart';
import 'package:tu_commerce/screen/stockscreen.dart';
import 'package:tu_commerce/screen/historySeller.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:tu_commerce/screen/walletscreen.dart';
import 'package:tu_commerce/screen/profilePicture.dart';
import 'package:tu_commerce/screen/noticeSeller.dart';
import 'package:tu_commerce/function/Firebase.dart';
import 'package:intl/intl.dart';

class SellerHome extends StatefulWidget {
  final Map<String, dynamic> username;
  
  SellerHome({Key? key, required this.username}) : super(key: key);

  @override
  State<SellerHome> createState() => _SellerHomeState();
}

class _SellerHomeState extends State<SellerHome> {

  Map<String, dynamic>? allNotice;
  List<dynamic>? allOrders;
  int? notReadNotice;
  // Map<String, dynamic>? userData;
  late Map<String, dynamic> userData; // Holding user
  bool isLoading = true; 
  
  // เอาไว้หาว่าตอนนี้ user คือใครไปหาใน firebase, getUserByEmail อยู่ใน folder fuction
  Future getData(String email) async{
    Map<String, dynamic> temp = await getUserByEmail(email) as Map<String, dynamic>;
    setState(() {
      userData = temp;
      isLoading = false;
      
    });
  }
  
  // เริ่มต้นให้มันหาว่าตอนนี้ที่ login อยู่ user อะไร
  @override
  void initState() {
    User? user = FirebaseAuth.instance.currentUser;
    String? email = user!.email;
    _initializeData();
    super.initState();
    getData(email!);
    print(widget.username['shoppingMode']);
  }

  
  Future<void> _initializeData() async {
    List<dynamic>? tempOrder =  await getOrders(widget.username['username'],widget.username['shoppingMode']);
    Map<String, dynamic>? tempMap = (await FirebaseFirestore.instance
        .collection('Notice')
        .doc(widget.username['username'])
        .get())
        .data();
    print('---------- data');
    print(tempOrder);
    if (tempMap == null) {
      tempMap = {
        "length":0,
        "noticeList":[]
      };
    }
    
    if (tempOrder == null) {
      tempOrder = [];
    }
    if (mounted){
      setState(() {
        allNotice = tempMap;
        allOrders = tempOrder;
      });

    }
  }

  // ใส่ container เข้าไป
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boxSize = screenWidth * 0.65 / 3;
    
    return allOrders == null
            ? const Center(child: CircularProgressIndicator()) :
            MaterialApp(
      theme: ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(const Color.fromRGBO(38, 174, 236, 1)),
            shape: MaterialStateProperty.all(const RoundedRectangleBorder()),
            foregroundColor: MaterialStateProperty.all(Colors.white),
            iconSize: MaterialStateProperty.all(boxSize*0.4),
          ),
        ),
        textTheme: Theme.of(context).textTheme.apply(bodyColor: const Color.fromRGBO(54, 91, 109, 1.0), fontSizeDelta: 1),
        scaffoldBackgroundColor: const Color.fromRGBO(242, 241, 236, 1),
      ),
      home: Scaffold(
      body: isLoading ? const Center(child: CircularProgressIndicator()) // เอาไว้เช็คว่า query เสร็จยังถ้ายังมันจะหมุนๆ
          : Stack(
            children: [
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 20, top: 40, bottom: 20),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(50)),
                              child: Container(
                                color: const Color.fromRGBO(219, 232, 231, 1),
                                child: ProfilePicture(user: userData)
                              )
                            ),
                          ),
                          const SizedBox(width: 20,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:[
                              Text(
                                '${userData['fname']} ${userData['lname']}',
                              ),
                              const SizedBox(height: 5,),
                              Text(
                                '@${userData['username']}',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              const Text("MY CREDIT", style: TextStyle(fontWeight: FontWeight.bold),),
                              Text('${userData['username']}'),
                            ],
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context, MaterialPageRoute(
                                  builder: (context){
                                    return Navigation(username: widget.username,temp: 1);
                                  }
                                )
                              );
                            },
                            child: const Text('MY WALLET'),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      color: const Color.fromRGBO(219, 232, 231, 1),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'MENU',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 5,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // SingleChildScrollView(
                              //   child: Column(),
                              // ),
                              Column(
                                children: [
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      minimumSize: MaterialStateProperty.all(Size(boxSize, boxSize)),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          
                                          builder: (context) => Navigation(username: widget.username,temp: 7),
                                        )
                                      );
                                      // Navigator.pushAndRemoveUntil(
                                      //   context,
                                      //   MaterialPageRoute(
                                          
                                      //     builder: (context) => Navigation(username: widget.username,temp: 7),
                                      //   ),(Route<dynamic> route) => false
                                      // );
                                    },
                                    child: const Icon(Icons.directions_car),
                                  ),
                                  const SizedBox(height: 10,),
                                  const Text("TO SHIP")
                                ],
                              ),
                              Column(
                                children: [
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      minimumSize: MaterialStateProperty.all(Size(boxSize, boxSize)),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Navigation(username: widget.username,temp: 6),
                                        )
                                      );
                                      // Navigator.pushAndRemoveUntil(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context) => Navigation(username: widget.username,temp: 6),
                                      //   ),(Route<dynamic> route) => false
                                      // );
                                    },
                                    child: const Icon(Icons.history),
                                  ),
                                  const SizedBox(height: 10,),
                                  const Text("HISTORY")
                                ],
                              ),
                              Column(
                                children: [
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      minimumSize: MaterialStateProperty.all(Size(boxSize, boxSize)),
                                    ),
                                    onPressed: () async {
                    
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => NavigationCustomer(email:widget.username['email'],temp: 4,),
                                        ),(Route<dynamic> route) => false
                                      );
                                    },
                                    child: const Icon(Icons.sell_outlined),
                                  ),
                                  const SizedBox(height: 10,),
                                  SizedBox(
                                    width: boxSize, 
                                    child: const Text("SHOPPING MODE", textAlign: TextAlign.center,)
                                  )
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                                    
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            // color: Colors.amber,
                            alignment: Alignment.topLeft,
                            child: const Text(
                              'Shipping List',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20
                              ),
                            )
                          ),
                    
                        ],
                      ),
                    ),
                    // Text('data')
                    Expanded(child: 
                      ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: allOrders!.length,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> order = allOrders![index].data();
                              print(order);
                              DateTime timestamp = order!['date'].toDate(); 
                              String formattedDate = DateFormat.yMMMd().format(timestamp); 
                              return Card(
                                margin: const EdgeInsets.only(top: 15, left: 20, right: 20),
                                color: const Color.fromRGBO(242, 241, 236, 1),
                                surfaceTintColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 100,
                                          height: 100,
                                          decoration: const BoxDecoration(color: Colors.white),
                                          child: Image.network(order['product']['link'], fit: BoxFit.contain,),
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
                                                      order['product']['prodName'],
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold,
                                                        color: Color.fromRGBO(54, 91, 109, 1.0),
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    Text(order['product']['price'].toStringAsFixed(2) + " ฿"),
                                                  ],
                                                ),
                                                Text(
                                                  order['product']['details'],
                                                  maxLines: 2,
                                                  style: const TextStyle(
                                                    color: Color.fromRGBO(54, 91, 109, 1.0),
                                                  ),
                                                ),
                                                const Spacer(),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Customer: @" + order['username']['username'],
                                                      style: const TextStyle(
                                                        color: Color.fromRGBO(54, 91, 109, 1),
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    Text(
                                                      formattedDate,
                                                      style: const TextStyle(
                                                        color: Color.fromRGBO(54, 91, 109, 0.7),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )
                                          )
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 10,),
                                    const Divider(
                                      height: BorderSide.strokeAlignOutside,
                                      color: Color.fromRGBO(38, 174, 236, 0.3),
                                    ),
                                  ],
                                ) 
                              );
                            }
                          ),
                    )
                  ],
                ),
              // Text('data'),
              
              Positioned(
                top: 50,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.notifications, size: 30,),
                  color:  (allNotice != null) && (allNotice!['length'] != allNotice!['noticeList'].length) ? Colors.red : Color.fromRGBO(54, 91, 109, 1.0),
                  onPressed: () async{
                    if (allNotice!['noticeList'].isEmpty == false) {
                      print('in notice if ---------');
                      await FirebaseFirestore.instance.collection('Notice').doc(widget.username['username']).update({'length':allNotice!['noticeList'].length});
                    }
                    Navigator.push(context, MaterialPageRoute(builder: (context) => NoticeSeller(username: widget.username)));
                    if (mounted){
                      setState(() {
                        _initializeData();
                      });
                    }
                  },
                )
              ),
            ],
          )
          ),
    );


  }
}
