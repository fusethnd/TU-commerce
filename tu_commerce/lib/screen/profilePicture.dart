import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  final Map<String, dynamic> user;

  ProfilePicture({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    var img = Image.asset(
      'assets/images/ProfileDefault.png',
      fit: BoxFit.contain,
    );
    if (user['profilePicture'] != null) {
      img = Image.network(
        user['profilePicture'],
        fit: BoxFit.contain,
      );
    }
    return Container(
      height: 100,
      width: 100,
      child: img,
    );
  }
}
