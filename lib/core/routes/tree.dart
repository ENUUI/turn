import 'package:flutter/material.dart';
import 'package:turn/core/interfaces/turn_ability.dart';

import 'transition_mode.dart';

enum QueryType {
  integer,
  float,
  string,
  bool,
}

enum TreeNodeType {
  component,
  parameter,
}

class TurnRoute {
  TurnRoute(
    this.route,
    this.builder, {
    this.transitionMode,
    this.queryTypeMap,
  });

  final String route;
  final NextPageBuilder builder;
  final TransitionMode? transitionMode;

  /// e.g.
  ///   *  xxx/:id/xxx?name=Mark&age=49
  ///   *  {
  ///   *    'id': QueryType.integer,
  ///   *    'name': QueryType.string,
  ///   *    'age': QueryType.integer,
  ///   *  }
  /// 如果 queryTypeMap 不为空，将类型进行类型转化。不在 queryTypeMap 中的参数默认为字符串。
  /// 如果key对应数组，则会尝试将数组中的每一个元素进行类型转化
  final Map<String, QueryType>? queryTypeMap;
}

class MatchResult {
  MatchResult(this.route, {this.params});

  final TurnRoute route;
  final Map<String, Object>? params;
}

class TreeNode {
  TreeNode(this.part, this.type);

  final String part;
  final TreeNodeType type;

  bool get isParameter => type == TreeNodeType.parameter;

  TreeNode? parent;

  final routes = <TurnRoute>[];
  final nodes = <TreeNode>[];
}

class RouteTree {
  final List<TreeNode> _nodes = <TreeNode>[];

  bool get hasDefaultRoute => _hasDefaultRoute;
  bool _hasDefaultRoute = false;

  void addRoute(TurnRoute route) {
    String path = route.route;
    if (path == Navigator.defaultRouteName) {
      if (_hasDefaultRoute) {
        throw 'Default route was already defined';
      }

      final node = TreeNode(path, TreeNodeType.component);
      node.routes.add(route);
      _nodes.add(node);

      _hasDefaultRoute = true;
      return;
    }

    if (path.startsWith('/')) {
      path = path.substring(1);
    }

    final components = path.split('/');
    TreeNode? parent;

    for (int i = 0; i < components.length; i++) {
      final component = components[i];
      TreeNode? node = _nodeForComponent(component, parent);

      if (node == null) {
        TreeNodeType type = _typeForComponent(component);
        node = TreeNode(component, type);
        node.parent = parent;

        if (parent == null) {
          _nodes.add(node);
        } else {
          parent.nodes.add(node);
        }
      }
      if (i == components.length - 1) {
        node.routes.add(route);
      }
    }
  }

  MatchResult? matchRoute(String path) {
    String usePath = path;

    if (usePath.startsWith('/')) {
      usePath = path.substring(1);
    }

    final List<String> components;
    if (path == Navigator.defaultRouteName) {
      components = ['/'];
    } else {
      components = usePath.split('/');
    }

    Map<TreeNode, TreeNodeMatch> nodeMatches = <TreeNode, TreeNodeMatch>{};
    List<TreeNode> nodesToCheck = _nodes;

    for (final checkComponent in components) {
      final currentMatches = <TreeNode, TreeNodeMatch>{};
      final nextNodes = <TreeNode>[];

      String pathPart = checkComponent;
      Map<String, List<String>>? queryMap;
      if (checkComponent.contains('?')) {
        final splitParam = checkComponent.split("?");
        pathPart = splitParam[0];
        queryMap = _parseQueryString(splitParam[1]);
      }

      for (final node in nodesToCheck) {
        final isMatch = (node.part == pathPart || node.isParameter);
        if (isMatch) {
          TreeNodeMatch? parentMatch = nodeMatches[node.parent];
          final match = TreeNodeMatch.fromMatch(parentMatch, node);
          if (node.isParameter) {
            final paramKey = node.part.substring(1);
            match.setParam(paramKey, pathPart);
          }
          if (queryMap != null) {
            match.params.addAll(queryMap);
          }
          currentMatches[node] = match;
          nextNodes.addAll(node.nodes);
        }
      }

      nodeMatches = currentMatches;
      nodesToCheck = nextNodes;

      if (currentMatches.values.isEmpty) {
        return null;
      }
    }

    final matches = nodeMatches.values.toList();

    if (matches.isNotEmpty) {
      final match = matches.first;
      final nodeToUse = match.node;
      final routes = nodeToUse.routes;

      if (routes.isNotEmpty) {
        final useRoute = routes[0];
        final routeMatch = MatchResult(
          useRoute,
          params: _castMap(match.params, useRoute.queryTypeMap),
        );
        return routeMatch;
      }
    }

    return null;
  }

  TreeNode? _nodeForComponent(String component, TreeNode? parent) {
    final List<TreeNode> nodes;
    if (parent != null) {
      nodes = parent.nodes;
    } else {
      nodes = _nodes;
    }

    for (final node in nodes) {
      if (node.part == component) {
        return node;
      }
    }
    return null;
  }

  TreeNodeType _typeForComponent(String component) {
    final TreeNodeType type;

    if (_isParameterComponent(component)) {
      type = TreeNodeType.parameter;
    } else {
      type = TreeNodeType.component;
    }
    return type;
  }

  bool _isParameterComponent(String component) {
    return component.startsWith(":");
  }

  Map<String, List<String>> _parseQueryString(String query) {
    final search = RegExp('([^&=]+)=?([^&]*)');
    final params = Map<String, List<String>>();

    if (query.startsWith('?')) query = query.substring(1);

    decode(String s) => Uri.decodeComponent(s.replaceAll('+', ' '));

    for (Match match in search.allMatches(query)) {
      final key = decode(match.group(1)!);
      final value = decode(match.group(2)!);

      if (params.containsKey(key)) {
        params[key]!.add(value);
      } else {
        params[key] = [value];
      }
    }

    return params;
  }

  Map<String, Object> _castMap(
    Map<String, List<String>> params,
    Map<String, QueryType>? typeMap,
  ) {
    params.removeWhere((key, value) => value.isEmpty);
    return params.map<String, Object>((key, values) => MapEntry(
          key,
          _parseKeyValue(key, values, typeMap?[key]),
        ));
  }

  Object _parseKeyValue(String key, List<String> values, QueryType? type) {
    final List result;
    switch (type) {
      case QueryType.integer:
        assert(() {
          values.map((e) => int.parse(e));
          return true;
        }());
        result = values.map((e) => int.tryParse(e) ?? 0).toList();
        break;
      case QueryType.float:
        assert(() {
          values.map((e) => double.parse(e));
          return true;
        }());
        result = values.map((e) => double.tryParse(e) ?? 0).toList();
        break;
      case QueryType.bool:
        result = values.map((e) {
          if (e == 'false' || e == '0' || e.isEmpty) {
            return false;
          } else {
            return true;
          }
        }).toList();
        break;
      case QueryType.string:
      default:
        result = values;
        break;
    }
    if (result.length > 1) return result;
    return result[0];
  }
}

class TreeNodeMatch {
  TreeNodeMatch(this.node);

  final TreeNode node;
  Map<String, List<String>> params = <String, List<String>>{};

  TreeNodeMatch.fromMatch(TreeNodeMatch? match, this.node) {
    params = <String, List<String>>{};
    if (match != null) {
      params.addAll(match.params);
    }
  }

  void setParam(String key, String value) {
    if (params.containsKey(key)) {
      final values = params[key]!;
      values.add(value);
    } else {
      params[key] = [value];
    }
  }
}