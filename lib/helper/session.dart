
class Session{
  var sessionData = {};

  static final Session _instance = Session._internal();
  factory Session() {
    return _instance;
  }
  Session._internal();

  setData(key, val){
    sessionData[key]=val ;
  }

  getData(key, {defaultVal:null}){
    if(sessionData.containsKey(key)){
      return sessionData[key] ;
    }
    return defaultVal;
  }
}
