extension IntExtension on int{
  /// Returns int as String adding enough '0' char to the left
  /// to satisfy [length] value
  String left0({length:2}){
    return (this<10^length ? "${"0"*(length-1)}${this}"  : "$this");
  }

  bool isEmpty(){
    return this == 0;
  }
}
