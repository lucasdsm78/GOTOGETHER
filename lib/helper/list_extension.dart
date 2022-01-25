extension ListExtension on List{
  removeFromArray(List<dynamic> removingList){
    this.removeWhere((element) => removingList.contains(element));
    return this;
  }
}