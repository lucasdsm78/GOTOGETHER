import 'package:flutter/cupertino.dart';
import 'api.dart';

Widget getSnapshotErrWidget(AsyncSnapshot snapshot) {
  if (snapshot.error.runtimeType == ApiErr) {
    ApiErr err = snapshot.error as ApiErr;
    return Center(
        child: Text("${err.message}")
    );
  }
  return Text("${snapshot.error}");
}