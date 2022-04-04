extension IntExtension on int{
  /// Returns int as String adding enough '0' char to the left
  /// to satisfy [length] value
  String left0({length=2}){
    return this.toString().padLeft(length, "0");
  }

  bool isEmpty(){
    return this == 0;
  }
}
