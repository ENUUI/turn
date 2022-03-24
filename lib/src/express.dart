abstract class Express {
  /// Do not set any data to [extraQuery]
  /// [extraQuery] will be covered when parsing [params] and [action]
  Map<String, dynamic>? extraQuery;

  @override
  String toString() {
    return '''
    Instance of $runtimeType
    extraQuery: $extraQuery
    ''';
  }
}
