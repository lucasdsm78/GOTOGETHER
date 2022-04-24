
isEmptyValue(dynamic val){
  if (val == null){
    return true;
  }
  if (val.runtimeType is int){
    return val == 0;
  }
  else if(val.runtimeType is String){
    return val == "";
  }
  else if(val.runtimeType is List){
    return val.isEmpty;
  }
  else if (val.runtimeType is Map){
    return val.isEmpty;
  }
  else if(val.runtimeType is bool){
    return val;
  }
  else{
    return false;
  }
}