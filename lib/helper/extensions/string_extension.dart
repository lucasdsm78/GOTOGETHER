extension StringExtension on String {
  /// Returns the String with uppercase on first letter
  String capitalize() {
    return this.isNotEmpty ? "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}" : "";
  }

  /// Returns the String translate from camel case to normal case
  /// By that we only mean to separate each word before an Upper cased letter,
  /// it won't lower case each word
  String camelCaseToNormalCase() {
    return this.split(RegExp(r"(?=[A-Z])")).join(" ");
  }
  /// Returns the string translate from snake case to normal case.
  /// By that we only mean to replace underscore '_' by a space ' '
  String snakeCaseToNormalCase() {
    return this.replaceAll("_", " ");
    //return this.replaceAll(RegExp(r"(?=[_])"), " ");
  }

  /// Returns the String after the dot '.' in normal case.
  ///
  /// Was think for enum purpose.
  String enumValueToNormalCase(){
    return this.split('.').last.camelCaseToNormalCase();
  }

  /* this can't work because isEmpty is a var existing for String, that can't
  be overwritten. we then can't try to simplify the isEmpty usage in dynamic var context
  /// Returns true if the string doesn't contain char.
  ///
  /// It should be useful in case of dynamic var that are strings
  bool isEmpty(){
    return this == "";
  }*/
}