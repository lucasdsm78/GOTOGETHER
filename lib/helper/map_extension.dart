import 'dart:developer';

extension MapExtension on Map{
  getFromMapFirstNotNull(List<String> keys){
    dynamic res = null;
    keys.forEach((element) {
      if(this.containsKey(element)){
        if(this[element] != null){
          res = this[element];
        }
      }
    });
    return res;
  }
}