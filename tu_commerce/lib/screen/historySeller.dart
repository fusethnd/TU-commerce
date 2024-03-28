import 'package:flutter/material.dart';

class HistorySeller extends StatefulWidget {
  const HistorySeller({super.key});

  @override
  State<HistorySeller> createState() => _HistorySellerState();
}

class _HistorySellerState extends State<HistorySeller> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("History"),),
    );
  }
}