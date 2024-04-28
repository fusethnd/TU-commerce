import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:tu_commerce/function/Firebase.dart';
import 'package:tu_commerce/screen/addProduct.dart';
import 'package:tu_commerce/screen/checkout.dart';
import 'package:tu_commerce/screen/editProfile.dart';
import 'package:tu_commerce/screen/historySeller.dart';
import 'package:tu_commerce/screen/inboxScreen.dart';
import 'package:tu_commerce/screen/noticeSeller.dart';
import 'package:tu_commerce/screen/profileScreen.dart';
import 'package:tu_commerce/screen/sellerHome.dart';
import 'package:tu_commerce/screen/stockscreen.dart';
import 'package:tu_commerce/screen/toship.dart';
import 'package:tu_commerce/screen/walletscreen.dart';

class Navigation extends StatefulWidget {
  final Map<String, dynamic> username;
  final Map<String, dynamic>? product;
  final int temp;

  Navigation({Key? key, required this.username, this.temp = 2, this.product})
      : super(key: key);
  // const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  late int _selectedIndex;

  late List<Widget> _widgetOptions;
  Map<String, dynamic>? allNotice;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initialState();
    _selectedIndex = widget.temp;
    widget.username['shoppingMode'] = false;
    _widgetOptions = <Widget>[
      StockScreen(
        email: widget.username,
      ), // Define your screens here
      WalletScreen(username: widget.username,),
      SellerHome(username: widget.username),
      InboxScreen(
        username: widget.username,
      ),
      NoticeSeller(username: widget.username,),
      AddProduct(username: widget.username),
      HistorySeller(username: widget.username),
      ToShipScreen(username: widget.username),
      CheckOut(
        username: widget.username,
        product: widget.product,
      ),
    ];
  }
  Future<void> _initialState() async {
    Map<String, dynamic>? tempMap = (await FirebaseFirestore.instance
        .collection('Notice')
        // ignore: prefer_interpolation_to_compose_strings
        .doc("seller"+widget.username['username'])
        .get())
        .data();
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

  }
  @override
  Widget build(BuildContext context) {
    _initialState();
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 430;

    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: GNav(
        color: Colors.white,
        backgroundColor: Color.fromRGBO(32, 157, 214, 1),
        activeColor: const Color.fromRGBO(54, 91, 109, 1.0),
        iconSize: isSmallScreen ? 20 : 30,
        selectedIndex: _selectedIndex,
        onTabChange: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        tabs: [
          const GButton(
            icon: Icons.inventory,
            // text: 'Stock',
          ),
          const GButton(
            icon: Icons.wallet,
            // text: 'Wallet',
          ),
          GButton(
            icon: Icons.home,
            iconSize: isSmallScreen ? 35 : 50,
            // text: 'Home',
          ),
          const GButton(
            icon: Icons.email,
            // text: 'Inbox',
          ),
          GButton(
            icon: Icons.notifications,
            iconColor:  (allNotice != null) && (allNotice!['length'] != allNotice!['noticeList'].length) 
             ? Colors.red 
             : Colors.white,
             onPressed: () async{
              if (allNotice!['noticeList'].isEmpty == false){

                await FirebaseFirestore.instance.collection('Notice').doc("seller"+widget.username['username']).update({'length':allNotice!['noticeList'].length});
              }
             },
             
            // text: 'account',
          ),
        ],
      ),
    );
  }
}
