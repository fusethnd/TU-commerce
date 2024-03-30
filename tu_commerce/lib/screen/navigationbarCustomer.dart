import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:tu_commerce/function/Firebase.dart';
import 'package:tu_commerce/screen/customerHome.dart';
import 'package:tu_commerce/screen/editProfile.dart';
import 'package:tu_commerce/screen/favorite.dart';
import 'package:tu_commerce/screen/inboxScreen.dart';
import 'package:tu_commerce/screen/profileScreen.dart';
import 'package:tu_commerce/screen/sellerHome.dart';
import 'package:tu_commerce/screen/stockscreen.dart';
import 'package:tu_commerce/screen/walletscreen.dart';

class NavigationCustomer extends StatefulWidget {
  final String email;
  final int temp;

  NavigationCustomer({Key? key, required this.email,this.temp=2}) : super(key: key);
  // const NavigationCustomer ({super.key});

  @override
  State<NavigationCustomer> createState() => _NavigationState();
}

class _NavigationState extends State<NavigationCustomer> {
  int _selectedIndex = 2;

  List<Widget> _widgetOptions  = <Widget>[
    Container(), // Add default values here or any other appropriate Widget
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
  if (user != null) {
    setState(() {
      userData = user;
      _widgetOptions = <Widget>[
        const WalletScreen(),
        const Favorite(),
        const CustomerHome(),
        const InboxScreen(),
        Profile(email: user),
        EditProfile(user: user),
      ];
      print('---------------');
      print(userData);
    });
  }else{
    print('its null');
  }
}

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