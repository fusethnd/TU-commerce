import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:tu_commerce/screen/customerHome.dart';
import 'package:tu_commerce/screen/favorite.dart';
import 'package:tu_commerce/screen/inboxScreen.dart';
import 'package:tu_commerce/screen/profileScreen.dart';
import 'package:tu_commerce/screen/sellerHome.dart';
import 'package:tu_commerce/screen/stockscreen.dart';
import 'package:tu_commerce/screen/walletscreen.dart';

class NavigationCustomer extends StatefulWidget {
  const NavigationCustomer ({super.key});

  @override
  State<NavigationCustomer> createState() => _NavigationState();
}

class _NavigationState extends State<NavigationCustomer> {
  int _selectedIndex = 2;


  static final List<Widget> _widgetOptions = <Widget>[
    const WalletScreen(),
    const Favorite(),
    const CustomerHome(),
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
            icon: Icons.favorite,
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