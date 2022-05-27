class Arguments {
  Arguments(this.route, {this.data, this.params});

  final String route;
  final Object? data;
  final Map<String, Object>? params;

  @override
  String toString() {
    return 'Arguments(route: "$route", data: $data, params: $params)';
  }
}
