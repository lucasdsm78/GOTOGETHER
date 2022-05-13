import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_together/models/location.dart' as Gt;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomMap extends StatefulWidget {
  const CustomMap({Key? key, required this.pos, this.onMark}) : super(key: key);
  final LatLng? pos;
  final Function? onMark;

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
    if(widget.pos != null){
      _addMarker(widget.pos!);
    }

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
        zoomControlsEnabled: true,
        onMapCreated: (controller) => _mapController = controller,
        initialCameraPosition: _initialCameraPosition,
        markers: {
          if(_origin != null) _origin!,
        },
        onTap: _addMarker,
    );
  }

  //region helpers
  /// This will get the first element of the [list] that isn't empty.
  /// if nothing is find, we return null.
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

  /// This will get the first element of the [list] that isn't empty.
  /// + it will try to find the more complete address get from google maps.
  ///
  /// if nothing is find, we return null.
  getFirstFilledAndComplete(List<dynamic> list, {dynamic defaultVal}){
    dynamic val = "";
    for(int i=0; i< list.length; i++){
      if(list[i] != null){
        if( (list[i] is String && list[i] !="")
            || (list[i] is List && list[i].isNotEmpty)){
          val = _getMoreComplete(val, list[i]);
          //break;
        }
      }
    }
    return val ?? defaultVal;
  }
  //endregion

  /// This is supposed to get the the element with much information,
  /// or merge them if they don't have common word
  _getMoreComplete(String search, String subject){
    RegExp regExpSearch = RegExp(
      r"" + search + "",
      caseSensitive: false,
      multiLine: false,
    );
    RegExp regExpSearchSplit = RegExp(
      r"" + search.split(" ").join("|") + "",
      caseSensitive: false,
      multiLine: false,
    );
    RegExp regExpSubject = RegExp(
      r"" + subject + "",
      caseSensitive: false,
      multiLine: false,
    );
    //regExpSubject.firstMatch("");
    return regExpSearch.hasMatch(subject) ? subject 
        : (regExpSubject.hasMatch(search) || regExpSearchSplit.hasMatch(subject) ? search : search + " " + subject) ;
  }

  /// try to add a marker on the place [pos] provided.
  /// the data provided by google maps are not always the same.
  ///
  /// sometime, the address don't include the street number, So there need
  /// to filter the data we will store in DB
  _addMarker(LatLng pos) async {
    Placemark placemark = await _getAddress(pos);
    log(placemark.toString());

    Gt.Location loc = Gt.Location(
        address: getFirstFilledAndComplete([placemark.street, placemark.name, placemark.thoroughfare], defaultVal: "") as String,
        city: getFirstFilled([placemark.locality], defaultVal: "") as String,
        country: getFirstFilled([placemark.country], defaultVal: "") as String,
        lat:pos.latitude, lon: pos.longitude);
    if(widget.onMark != null){
      widget.onMark!(loc);
    }

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
