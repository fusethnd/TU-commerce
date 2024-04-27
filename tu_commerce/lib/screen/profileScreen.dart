import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
    if (mounted){
      if (tempMap != null) {
        setState(() {
          allNotice = tempMap;
          notReadNotice = tempMap!['noticeList'].length - tempMap['length'];
        });

      }else{
        setState(() {
          allNotice = null;
          notReadNotice = 0;
        });
      }
    }



  }


  @override
  Widget build(BuildContext context) {
    _init();
    return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
        ),
        body: RefreshIndicator(
            onRefresh: _refreshData,
            child: ListView(
              children: [
                Container(
                  height: 500,
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: [
                          ProfilePicture(user: widget.email),
                          Column(
                            children: <Widget>[
                              Text(
                                '${widget.email['fname']} ${widget.email['lname']}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0),
                              ),
                              Text(
                                '@${widget.email['username']}',
                                style: TextStyle(fontSize: 18.0),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Column(
                            children: <Widget>[
                              Text("MY CREDIT"),
                              Text('${widget.email['username']}'),
                              // Text("${widget.credit}")
                            ],
                          ),
                          Spacer(),
                          // Add button before but it's lost
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(context,
                                  MaterialPageRoute(builder: (context) {
                                return NavigationCustomer(
                                  email: widget.email['email'],
                                  temp: 0,
                                );
                              }), (Route<dynamic> route) => false);
                            },
                            child: const Text('MY WALLET'),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                //-------------- จบ container แรก -------------------
                Container(
                  // ทำตัวลิ้ง ไป stock กับอื่นแต่ตอนนี้ลิ้งมั่วนะ
                  decoration: BoxDecoration(color: Color(0xFFF2F1EC)),
                  child: Row(
                    children: [
                      Text(
                        'MENU',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18.0),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NavigationCustomer(
                                        email: widget.email['email'],
                                        temp: 9,
                                      ),
                                    ),
                                    (Route<dynamic> route) => false);
                              },
                              child: const Text('TO SHIP'),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NavigationCustomer(
                                        email: widget.email['email'],
                                        temp: 10,
                                      ),
                                    ),
                                    (Route<dynamic> route) => false);
                              },
                              child: const Text('HISTORY'),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {

                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          Navigation(username: widget.email),
                                    ),
                                    (Route<dynamic> route) => false);
                              },
                              child: const Text('Seller MODE'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // จบ---- container 3 ปุ่ม-----------

                Container(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text('MY ACCOUNT')),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NavigationCustomer(
                                      email: widget.email['email'],
                                      temp: 5,
                                    ),
                                  ));
                            },
                            child: const Text('Edit Profile'),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: Text('Username')),
                          Text(widget.email['username']),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: Text('Email-Address')),
                          Text(widget.email['email']),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: Text('Phone Number')),
                          Text(widget.email['phone']),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: Text('Name')),
                          Text(
                              '${widget.email['fname']} ${widget.email['lname']}'),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    children: [
                      ElevatedButton(onPressed: logout, child: Text('log out')),
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
                    ],
                  ),
                ),
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
            )));
  }
}
