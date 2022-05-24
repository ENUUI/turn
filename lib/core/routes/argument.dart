class Arguments {
  Arguments(this.route, {this.data, this.params});

  final String route;
  final Object? data;
  final Map<String, Object>? params;
}
