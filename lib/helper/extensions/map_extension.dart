extension MapExtension on Map{
  /// Returns the first value contained by the map corresponding
  /// to the [keys] provided that isn't null.
  ///
  /// if none exist, return null
  getFromMapFirstNotNull(List<String> keys){
    dynamic res = null;
    for (int i=0; i<keys.length ;i++){
      if(this.containsKey(keys[i])){
        if(this[keys[i]] != null){
          res = this[keys[i]];
          break;
        }
      }
    }
    return res;
  }
}