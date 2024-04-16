import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  String? chatID;


  MapScreen({Key? key, required this.latitude, required this.longitude,this.chatID})
      : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  late LatLng _markerPosition;

  @override
  void initState() {
    super.initState();
    _markerPosition = LatLng(widget.latitude, widget.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.latitude, widget.longitude),
          zoom: 15,
        ),
        onMapCreated: (controller) {
          mapController = controller;
        },
        markers: {
          Marker(
            markerId: MarkerId('Marker'),
            position: _markerPosition,
            infoWindow: InfoWindow(
              title: 'Your Location',
            ),
          ),
        },
        onTap: _onMapTapped,
      ),
    );
  }

  void _onMapTapped(LatLng tappedPoint) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    QuerySnapshot snapshot = await firestore.collection('ChatRoom').doc(widget.chatID).collection('Message').where('latitude', isNull: false).get();
    snapshot.docs.forEach((doc) async {
      // Get the document ID
      String docId = doc.id;
      // Update the latitude field with the new value
      await firestore.collection('ChatRoom').doc(widget.chatID).collection('Message').doc(docId).update({'latitude': tappedPoint.latitude,'longitude':tappedPoint.longitude});
    });
    setState(() {
      _markerPosition = tappedPoint;
    });
  }
}
