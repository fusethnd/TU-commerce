import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tu_commerce/function/Firebase.dart';
import 'package:tu_commerce/screen/historyCustomer.dart';
import 'package:tu_commerce/screen/home.dart';
import 'package:tu_commerce/screen/navigationbarCustomer.dart';
import 'package:tu_commerce/screen/navigationbarSeller.dart';
import 'package:tu_commerce/screen/noticeScreen.dart';
import 'package:tu_commerce/screen/profilePicture.dart';
import 'package:tu_commerce/screen/toship.dart';
import 'package:tu_commerce/screen/walletscreen.dart';

class Profile extends StatefulWidget {
  final Map<String, dynamic> email;

  Profile({Key? key, required this.email}) : super(key: key);
  // const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic>? allNotice;
  int? notReadNotice;

  logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 0)); // Simulate a delay
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) =>
                NavigationCustomer(email: widget.email['email'], temp: 4)),
        (Route<dynamic> route) => false);
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  Future<void> _init() async {
    Map<String, dynamic>? tempMap = (await FirebaseFirestore.instance
        .collection('Notice')
        .doc(widget.email['username'])
        .get())
        .data();
    print(tempMap);
    
    if (tempMap == null) {
      tempMap = {
        "length":0,
        "noticeList":[]
      };
    }
    if (mounted){
      setState(() {
        allNotice = tempMap;
      });

    }
    // if (mounted){
    //   if (tempMap != null) {
    //     setState(() {
    //       allNotice = tempMap;
    //       notReadNotice = tempMap!['noticeList'].length - tempMap['length'];
    //     });

    //   }else{
    //     setState(() {
    //       allNotice = null;
    //       notReadNotice = 0;
    //     });
    //   }
    // }



  }


  @override
  Widget build(BuildContext context) {
    // _init();
    final screenWidth = MediaQuery.of(context).size.width;
    final boxSize = screenWidth * 0.65 / 3;
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromRGBO(242, 241, 236, 1),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(const Color.fromRGBO(65, 193, 186, 1.0)),
            shape: MaterialStateProperty.all(const RoundedRectangleBorder()),
            foregroundColor: MaterialStateProperty.all(Colors.white),
            iconSize: MaterialStateProperty.all(boxSize*0.4),
          ),
        ),
        textTheme: Theme.of(context).textTheme.apply(bodyColor: const Color.fromRGBO(54, 91, 109, 1.0), fontSizeDelta: 1),
      ),
      home: Scaffold(
          body: RefreshIndicator(
              onRefresh: _refreshData,
              child: Stack(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.all(Radius.circular(50)),
                                      child: Container(
                                        color: const Color.fromRGBO(219, 232, 231, 1),
                                        child: ProfilePicture(user: widget.email)
                                      )
                                    ),
                                  ),
                                  const SizedBox(width: 20,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children:[
                                      Text(
                                        '${widget.email['fname']} ${widget.email['lname']}',
                                      ),
                                      const SizedBox(height: 5,),
                                      Text(
                                        '@${widget.email['username']}',
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
                                      Text('${widget.email['username']}'),
                                    ],
                                  ),
                                  const Spacer(),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) {
                                        return NavigationCustomer(
                                          email: widget.email['email'],
                                          temp: 0,
                                        );
                                      }),
                                      (Route<dynamic> route) => false);
                                    },
                                    child: const Text('MY WALLET'),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: 10,),
                            Container(
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
                                  SizedBox(height: 5,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
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
                                                    builder: (context) => NavigationCustomer(
                                                      email: widget.email['email'],
                                                      temp: 9,
                                                    ),
                                                  ));
                                              // Navigator.pushAndRemoveUntil(
                                              //     context,
                                              //     MaterialPageRoute(
                                              //       builder: (context) => NavigationCustomer(
                                              //         email: widget.email['email'],
                                              //         temp: 9,
                                              //       ),
                                              //     ),
                                              //     (Route<dynamic> route) => false);
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
                                                    builder: (context) => NavigationCustomer(
                                                      email: widget.email['email'],
                                                      temp: 10,
                                                    ),
                                                  )
                                              );
                                              // Navigator.pushAndRemoveUntil(
                                              //     context,
                                              //     MaterialPageRoute(
                                              //       builder: (context) => NavigationCustomer(
                                              //         email: widget.email['email'],
                                              //         temp: 10,
                                              //       ),
                                              //     ),
                                              //     (Route<dynamic> route) => false);
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
                                            onPressed: () {
                                              Navigator.pushAndRemoveUntil(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        Navigation(username: widget.email),
                                                  ),
                                                  (Route<dynamic> route) => false);
                                            },
                                            child: const Icon(Icons.sell_outlined),
                                          ),
                                          const SizedBox(height: 10,),
                                          SizedBox(
                                            width: boxSize, 
                                            child: const Text("SELLING MODE", textAlign: TextAlign.center,)
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                    
                            Container(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'MY ACCOUNT', 
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        )
                                      ),
                                      GestureDetector(
                                        child: const Text(
                                          "Edit Profile",
                                          style: TextStyle(decoration: TextDecoration.underline),
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => NavigationCustomer(
                                                email: widget.email['email'],
                                                temp: 5,
                                              ),
                                            ));
                                        },
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 10,),
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'Name',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        )
                                      ),
                                      Text(
                                          '${widget.email['fname']} ${widget.email['lname']}'),
                                    ],
                                  ),
                                  const SizedBox(height: 10,),
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'Username',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        )
                                      ),
                                      Text(widget.email['username']),
                                    ],
                                  ),
                                  const SizedBox(height: 10,),
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'Email',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        )
                                      ),
                                      Text(widget.email['email']),
                                    ],
                                  ),
                                  const SizedBox(height: 10,),
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'Phone Number',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        )
                                      ),
                                      Text(widget.email['phone']),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    
                        // Container(
                        //   child: Column(
                        //     children: [
                        //       ElevatedButton(onPressed: logout, child: Text('log out')),
                              // FutureBuilder(
                              //   future: isEmailVerified(),
                              //   builder: (context,snapshot){
                              //     if (snapshot.connectionState == ConnectionState.waiting) {
                              //       return CircularProgressIndicator();
                              //     }else{
                              //       bool emailVerified = snapshot.data ?? false;
                              //       return Visibility(
                              //         visible: !emailVerified,
                              //         child: ElevatedButton(
                              //           onPressed: () async{
                              //             if (!emailVerified) {
                              //               await sendEmailVerification();
                              //               logout;
                              //             } else {
                              //               print('Email already verified');
                              //             }
                              //           }, child: Text('Verify'),
                              //         )
                              //       );
                              //     }
                              //   }
                              //   )
                        //     ],
                        //   ),
                        // ),
                        // Container(
                        //   child: Stack(
                        //     children: [
                        //       IconButton(
                        //         onPressed: () async {
                        //           int noticeLength = allNotice != null ? allNotice!['noticeList'].length : 0;
                    
                        //           await FirebaseFirestore.instance
                        //               .collection('Notice')
                        //               .doc(widget.email['username'])
                        //               .update({'length': noticeLength});
                    
                        //           Navigator.push(
                        //             context,
                        //             MaterialPageRoute(builder: (context) => NoticeSreen(username: widget.email)),
                        //           );
                        //         },
                        //         icon: Icon(Icons.notifications),
                        //       ),
                        //       Positioned(
                        //         right: 0,
                        //         child: Container(
                        //           padding: EdgeInsets.all(4),
                        //           decoration: BoxDecoration(
                        //             color: Colors.red, // You can customize the color as you like
                        //             shape: BoxShape.circle,
                        //           ),
                        //           child: Text(
                        //             allNotice != null ? allNotice!['noticeList'].length.toString() : '0',
                        //             style: TextStyle(color: Colors.white, fontSize: 12),
                        //           ),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // )
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 30,
                    left: 30,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))
                        ),
                        padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 15))
                      ),
                      onPressed: logout, 
                      child: const Text('Log Out')
                    ),
                  ),
                  Positioned(
                    top: 50,
                    right: 20,
                    child: IconButton(
                      icon: const Icon(Icons.notifications, size: 30,),
                      color:  (allNotice != null) && (allNotice!['length'] != allNotice!['noticeList'].length) ? Colors.red : Color.fromRGBO(54, 91, 109, 1.0),
                      onPressed: () async{
                        if (allNotice!['noticeList'].isEmpty == false) {
                          print('in notice if ---------');
                          await FirebaseFirestore.instance.collection('Notice').doc(widget.email['username']).update({'length':allNotice!['noticeList'].length});
                        }
                        Navigator.push(context, MaterialPageRoute(builder: (context) => NoticeSreen(username: widget.email)));
                        if (mounted){
                          setState(() {
                            _init();
                          });
                        }
                      },
                    )
                  ),
                ],
              )
            )
          ),
    );
  }
}
