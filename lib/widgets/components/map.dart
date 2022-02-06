import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomMap extends StatefulWidget {
  const CustomMap({Key? key, required this.pos, required this.onMark}) : super(key: key);
  final LatLng? pos;
  final Function onMark;

  @override
  _CustomMapState createState() => _CustomMapState();
}

class _CustomMapState extends State<CustomMap> {
  final CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(49.035617,2.060325 ),
    zoom: 11.0,
  ); // use autorisation to initial position
  Marker? _origin;
  final double zoom = 11.0;

  late GoogleMapController _mapController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        onMapCreated: (controller) => _mapController = controller,
        initialCameraPosition: _initialCameraPosition,
        markers: {
          if(_origin != null) _origin!,
        },
        onLongPress: _addMarker,
    );
  }

  _addMarker(LatLng pos){
    widget.onMark(pos);
    setState(() {
      _origin = Marker(
        markerId: const MarkerId("origin"),
        infoWindow: InfoWindow(title: "Origin ${pos.latitude} ${pos.longitude}"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        position: pos,

      );
    });
  }
}
