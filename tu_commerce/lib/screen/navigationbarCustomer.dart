import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:tu_commerce/function/Firebase.dart';
import 'package:tu_commerce/screen/chat.dart';
import 'package:tu_commerce/screen/checkout.dart';
import 'package:tu_commerce/screen/customerHome.dart';
import 'package:tu_commerce/screen/editProfile.dart';
import 'package:tu_commerce/screen/favorite.dart';
import 'package:tu_commerce/screen/historyCustomer.dart';
import 'package:tu_commerce/screen/inboxScreen.dart';
import 'package:tu_commerce/screen/profileScreen.dart';
import 'package:tu_commerce/screen/sellerHome.dart';
import 'package:tu_commerce/screen/showCategory.dart';
import 'package:tu_commerce/screen/stockscreen.dart';
import 'package:tu_commerce/screen/toship.dart';
import 'package:tu_commerce/screen/walletscreen.dart';

class NavigationCustomer extends StatefulWidget {
  final String email;
  final int temp;
  final String category;
  final List<DocumentSnapshot>? allItem;
  final Map<String, dynamic>? product;
  final Map<String, dynamic>? order;
  String? chatName;

  NavigationCustomer(
      {Key? key,
      required this.email,
      this.temp = 2,
      this.category = '',
      this.allItem,
      this.product,
      this.order,
      this.chatName})
      : super(key: key);
  // const NavigationCustomer ({super.key});

  @override
  State<NavigationCustomer> createState() => _NavigationState();
}

class _NavigationState extends State<NavigationCustomer> {
  int _selectedIndex = 2;
  // ทุกครั้งที่อยากได้ new navbar ให้เข้ามาหน้านี้แล้วสร้าง  Container() เพิ่มอีกอัน ละอ่านต่อข้างล่าง
  List<Widget> _widgetOptions = <Widget>[
    Container(), // Add default values here or any other appropriate Widget
    Container(),
    Container(),
    Container(),
    Container(),
    Container(),
    Container(),
    Container(),
    Container(),
    Container(),
    Container(),
  ];
  late Map<String, dynamic> userData;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.temp;
    _initializeUserData();
  }

  void _initializeUserData() async {
    Map<String, dynamic>? user = await getUserByEmail(widget.email);
    // อ่านต่อตรงนี้ ก็เพิ่มclass ใหม่เวลาเรียกใช้ก็ให้ยิงมาที่นี่่พร้อมกับ temp ย้อนไปดูตัวแปรเริ่มต้นข้างบน
    if (user != null) {
      setState(() {
        userData = user;
        _widgetOptions = <Widget>[
          const WalletScreen(),
          Favorite(username: user),
          CustomerHome(
            username: user,
          ),
          InboxScreen(username: user),
          Profile(email: user),
          EditProfile(user: user),
          ShowCategory(
            category: widget.category,
            allItem: widget.allItem,
          ),
          CheckOut(
            username: user,
            product: widget.product,
          ),
          ChatScreen(
            username: user,
            order: widget.order,
            seller: widget.chatName,
          ),
          ToShipScreen(username: user),
          HistoryCustomer(username: user),
        ];
        print('---------------');
        print(userData);
      });
    } else {
      print('its null');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: GNav(
        color: Colors.white,
        backgroundColor: const Color.fromRGBO(65, 193, 186, 1.0),
        activeColor: const Color.fromRGBO(54, 91, 109, 1.0),
        iconSize: 30,
        selectedIndex: _selectedIndex,
        onTabChange: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        tabs: const [
          GButton(
            icon: Icons.wallet,
            // text: 'Stock',
          ),
          GButton(
            icon: Icons.favorite,
            // text: 'Wallet',
          ),
          GButton(
            icon: Icons.home_rounded,
            iconSize: 50,
            // text: 'Home',
          ),
          GButton(
            icon: Icons.email,
            // text: 'Inbox',
          ),
          GButton(
            icon: Icons.account_circle_rounded,
            // text: 'account',
          ),
        ],
      ),
    );
  }
}
