extension ListExtension on List{
  /// Returns all elements in the list that are not in the [removingList]
  removeFromArray(List<dynamic> removingList){
    this.removeWhere((element) => removingList.contains(element));
    return this;
  }
}