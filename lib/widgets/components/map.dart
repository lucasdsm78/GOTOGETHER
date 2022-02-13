import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_together/models/location.dart' as Gt;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomMap extends StatefulWidget {
  const CustomMap({Key? key, required this.pos, required this.onMark}) : super(key: key);
  final LatLng? pos;
  final Function onMark;

  @override
  _CustomMapState createState() => _CustomMapState();
}

class _CustomMapState extends State<CustomMap> {
  late CameraPosition _initialCameraPosition; // use autorisation to initial position
  Marker? _origin;
  final double zoom = 11.0;
  late GoogleMapController _mapController;

  @override
  void initState() {
    super.initState();
    _initialCameraPosition = CameraPosition(
      target: (widget.pos != null ? widget.pos! : const LatLng(49.035617, 2.060325)),
      zoom: 11.0,
    );

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

  getFirstFilled(List<dynamic> list, {dynamic defaultVal}){
    dynamic val;
    for(int i=0; i< list.length; i++){
      if(list[i] != null){
        if( (list[i] is String && list[i] !="")
            || (list[i] is List && list[i].isNotEmpty)){
          val = list[i];
          break;
        }
      }
    }
    return val ?? defaultVal;
  }

  _addMarker(LatLng pos) async {
    Placemark placemark = await _getAddress(pos);
    log(placemark.toString());

    Gt.Location loc = Gt.Location(
        address: getFirstFilled([placemark.name, placemark.street, placemark.thoroughfare], defaultVal: "") as String,
        city: getFirstFilled([placemark.locality], defaultVal: "") as String,
        country: getFirstFilled([placemark.country], defaultVal: "") as String,
        lat:pos.latitude, lon: pos.longitude);
    widget.onMark(loc);

    setState(() {
      _origin = Marker(
        markerId: const MarkerId("origin"),
        infoWindow: InfoWindow(title: "${placemark.country} ${placemark.locality} ${placemark.name}"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        position: pos,
      );
    });
  }

  _getAddress(LatLng pos) async {
    List<Placemark> placemark = await placemarkFromCoordinates(pos.latitude, pos.longitude);
    return placemark[0];
    //country, locality = city, adress = name or street or thoroughfare
  }
}
