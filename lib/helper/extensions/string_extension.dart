extension StringExtension on String {
  /// Returns the String with uppercase on first letter
  String capitalize() {
    return this.isNotEmpty ? "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}" : "";
  }

  /// Returns the String translate from camel case to normal case
  String camelCaseToNormalCase() {
    return this.split(RegExp(r"(?=[A-Z])")).join(" ");
  }

  /// Returns the String after the dot '.' in normal case.
  ///
  /// Was think for enum purpose.
  String enumValueToNormalCase(){
    return this.split('.').last.camelCaseToNormalCase();
  }

  bool isEmpty(){
    return this == "";
  }
}