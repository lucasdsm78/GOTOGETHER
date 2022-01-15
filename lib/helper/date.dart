
String getMysqlDate(DateTime date){
  return "${date.year}-${date.month}-${date.day}";
}

String getMysqlDatetime(DateTime date){
  return getMysqlDate(date) + " ${date.hour}:${date.minute}";
}
