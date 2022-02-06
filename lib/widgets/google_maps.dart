import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  static String tag = "google_map";
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  //static const LatLng _initialCameraPosition = LatLng(49.035617,2.060325 );
  final CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(49.035617,2.060325 ),
    zoom: 11.0,
    );
  Marker? _origin;
  Marker? _destination;
  final double zoom = 11.0;

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  late GoogleMapController _mapController;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Widget _originButton(){
    if(_origin != null){
      return TextButton(
          onPressed: () => _mapController.animateCamera(
              CameraUpdate.newCameraPosition(
                  CameraPosition(
                      target: _origin!.position,
                      zoom: 14.5,
                      tilt: 50
                  )
              )
          ),
          style: TextButton.styleFrom(
              primary: Colors.green,
              textStyle: const TextStyle(
                  fontWeight: FontWeight.w600
              )
          ),
          child: Text("Origin")
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text('Maps'),
          actions: [
            _originButton()
          ],
          backgroundColor: Colors.green[700],
        ),
        body: GoogleMap(
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          onMapCreated: (controller) => _mapController = controller,
          initialCameraPosition: _initialCameraPosition,
          markers: {
            if(_origin != null) _origin!,
            if(_destination !=null) _destination!,
          },
          onLongPress: _addMarker,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.black,
        onPressed: (){
          _mapController.animateCamera(CameraUpdate.newCameraPosition(_initialCameraPosition));
        },
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }

  _addMarker(LatLng pos){
    if(_origin == null || (_origin != null && _destination != null)){
      //case no origin or both exist
      setState(() {
        _origin = Marker(
          markerId: const MarkerId("origin"),
          infoWindow: InfoWindow(title: "Origin ${pos.latitude} ${pos.longitude}"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          position: pos,

        );
        _destination = null; //reset destination
      });
    }
    else{
      //case origin defined, but not destination
      setState(() {
        _destination = Marker(
          markerId: const MarkerId("destination"),
          infoWindow: const InfoWindow(title: "Your Destination"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          position: pos,

        );
      });
    }
  }
}