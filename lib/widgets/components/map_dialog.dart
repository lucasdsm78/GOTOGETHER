import 'package:flutter/material.dart';
import 'package:go_together/widgets/components/Map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'custom_text.dart';

class MapDialog extends StatefulWidget {
  const MapDialog({Key? key}) : super(key: key);

  @override
  _MapDialogState createState() => _MapDialogState();
}

class _MapDialogState extends State<MapDialog> {
  LatLng? pos ;

  @override
  void initState() {
    super.initState();
  }

  _updatePos(LatLng newPos){
    setState(() {
      pos = newPos;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.6;
    double height = MediaQuery.of(context).size.height * 0.6;

    return SimpleDialog(
      title: CustomText("Select Location", textAlign: TextAlign.center,),
      contentPadding: EdgeInsets.all(5.0),
      children: [
        Container(
            height: height,
            width: width,
            child:CustomMap(pos:pos, onMark:_updatePos)
        ),
        TextButton(
          onPressed: (){
            Navigator.pop(context, pos);
          },
          child: Text("confirm location"))
      ],
    );
  }

}
