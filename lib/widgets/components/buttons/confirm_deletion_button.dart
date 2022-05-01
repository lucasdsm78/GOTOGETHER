import 'package:flutter/material.dart';

// This button is used to close a dialog after clicking on it.
// If a function corresponding to the confirm boolean exist, we execute it
class ConfirmDeletionButton extends ElevatedButton{
  ConfirmDeletionButton(bool confirm, BuildContext context, {Key? key, trueFunction, falseFunction}) : super(key: key,
    onPressed: (){
      Navigator.pop(context);
      if(confirm && trueFunction is Function){
        trueFunction();
      }
      else if(!confirm && falseFunction is Function){
        falseFunction();
      }
    },
    child: Text(confirm ? "Yes" : "No"),
  );
}
