import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const MapScreen({Key? key, required this.latitude, required this.longitude})
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

  void _onMapTapped(LatLng tappedPoint) {
    setState(() {
      _markerPosition = tappedPoint;
    });
  }
}
