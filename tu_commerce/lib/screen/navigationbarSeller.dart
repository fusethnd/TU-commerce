import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:tu_commerce/screen/inboxScreen.dart';
import 'package:tu_commerce/screen/profileScreen.dart';
import 'package:tu_commerce/screen/sellerHome.dart';
import 'package:tu_commerce/screen/stockscreen.dart';
import 'package:tu_commerce/screen/walletscreen.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 2;  

  
  static final List<Widget> _widgetOptions = <Widget>[
    const StockScreen(), // Define your screens here
    const WalletScreen(),
    const SellerHome(),
    const InboxScreen(),
    const Profile(),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: GNav(
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
            icon: Icons.account_box,
            // text: 'account',
          ),
          
        ],
      ),
    );
  }
}