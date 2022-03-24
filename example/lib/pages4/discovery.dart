import 'package:example/pages4/account.dart';
import 'package:flutter/material.dart';

import 'turn_page.dart';
import 'package:turn/turn.dart';

class DiscoveryQuery extends Express {
  DiscoveryQuery(this.desc);

  final String desc;

  @override
  String toString() {
    return '''${super.toString()}
    desc: $desc
    ''';
  }
}

class DiscoveryPage extends TurnPage {
  DiscoveryPage(DiscoveryQuery query) : super(query: query);

  @override
  void onTap(BuildContext context) {
    Turn.to(
      context,
      '/page4/account?msg=message from discovery',
      express: AccountQuery('这是从DISCOVERY页面传入的参数'),
      params: {'message': '这是通过Map传递参数'},
      replace: true
    );
  }

  @override
  String get title => 'DISCOVERY';
}
