import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_together/models/location.dart';
import 'package:go_together/widgets/components/maps/map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../custom_text.dart';

/// this is a dialog that contain a google map.
/// define the location to see a marker on the map, else there isn't any marker
class MapDialog extends StatefulWidget {
  const MapDialog({Key? key, this.location}) : super(key: key);
  final Location? location;

  @override
  _MapDialogState createState() => _MapDialogState();
}

class _MapDialogState extends State<MapDialog> {
  LatLng? pos ;
  late Location? location = widget.location;

  @override
  void initState() {
    super.initState();
    if(location == null){
      _updatePos(LatLng(49.035617, 2.060325));
    }
    else{
      _updatePos(LatLng(location!.lat, location!.lon));
    }
  }

  _updatePos(LatLng newPos){
    setState(() {
      pos = newPos;
    });
  }
  _updateLocation(Location newLocation){
    setState(() {
      location = newLocation;
    });
  }
  _getPosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    setState(() {
      pos = LatLng(position.latitude,  position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.6;
    double height = MediaQuery.of(context).size.height * 0.6;

    return SimpleDialog(
      title: CustomText("Sélectionner un lieu", textAlign: TextAlign.center,),
      contentPadding: EdgeInsets.all(5.0),
      children: [
        Container(
            height: height,
            width: width,
            child: CustomMap(pos:pos, onMark:_updateLocation)
        ),
        TextButton(
          onPressed: (){
            Navigator.pop(context, location); // quit dialog and return a value
          },
          child: Text("Confirmer"))
      ],
    );
  }
}
