import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:tu_commerce/function/Firebase.dart';
import 'package:tu_commerce/screen/addProduct.dart';
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
  final int temp;

  Navigation({Key? key, required this.username, this.temp = 2})
      : super(key: key);
  // const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  late int _selectedIndex;

  late List<Widget> _widgetOptions;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
      const NoticeSeller(),
      AddProduct(username: widget.username),
      HistorySeller(username: widget.username),
      ToShipScreen(username: widget.username),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: GNav(
        color: Colors.white,
        backgroundColor: Color.fromRGBO(32, 157, 214, 1),
        selectedIndex: _selectedIndex,
        onTabChange: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        tabs: const [
          GButton(
            icon: Icons.inventory,
            // text: 'Stock',
          ),
          GButton(
            icon: Icons.wallet,
            // text: 'Wallet',
          ),
          GButton(
            icon: Icons.home,
            // text: 'Home',
          ),
          GButton(
            icon: Icons.inbox,
            // text: 'Inbox',
          ),
          GButton(
            icon: Icons.notifications,
            // text: 'account',
          ),
        ],
      ),
    );
  }
}
