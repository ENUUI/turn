class Arguments {
  Arguments(this.route, {this.data, this.params});

  final String route;
  final Object? data;
  final Map<String, dynamic>? params;

  @override
  String toString() {
    return 'Arguments(route: "$route", data: $data, params: $params)';
  }
}

extension ArgumentsData on Arguments {
  Map<String, dynamic>? commitDataAsMap() {
    final data = this.data, params = this.params;
    if (data is! Map<String, dynamic>) return params;
    if (params == null) return data;
    return Map.of(data)..addAll(params);
  }
}
