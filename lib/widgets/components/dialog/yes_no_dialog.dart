import 'package:flutter/material.dart';
import 'package:go_together/widgets/components/buttons/confirmation_button.dart';

/// this is a yes no dialog.
/// there you could define the modal [title], some content with [children],
/// and an action for yes, and another for no response.
class YesNoDialog extends StatelessWidget {
  const YesNoDialog({Key? key, required this.title, this.children, this.trueFunction, this.falseFunction}) : super(key: key);
  final String title;
  final List<Widget>? children;
  final Function? trueFunction;
  final Function? falseFunction;

  @override
  Widget build(BuildContext context) {
    List<Widget> finalChildren = [];
    if(children!=null){
      finalChildren = [...children!];
    }
    finalChildren.add(Container(height: 10.0,));
    finalChildren.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _getConfirmButton(true, context),
            _getConfirmButton(false, context),
          ],
        )
    );

    return SimpleDialog(
      title: Text(title),
      contentPadding: EdgeInsets.all(20.0),
      children: finalChildren,
    );
  }

  _getConfirmButton(bool isYes, BuildContext context){
    if(isYes){
      if(trueFunction!=null){
        return ConfirmationButton(isYes, context, trueFunction: trueFunction,);
      }
    }
    else{
      if(falseFunction!=null) {
        return ConfirmationButton(
          isYes, context, falseFunction: falseFunction,);
      }
    }
    return ConfirmationButton(isYes, context);
  }
}
