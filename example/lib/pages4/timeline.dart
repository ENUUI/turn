import 'package:example/pages4/discovery.dart';
import 'package:example/pages4/turn_page.dart';
import 'package:flutter/material.dart';
import 'package:turn/turn.dart';

class TimelineQuery extends Express {
  TimelineQuery(this.desc);

  final String desc;

  @override
  String toString() {
    return '''${super.toString()}
    desc: $desc
    ''';
  }
}

class TimelinePage extends TurnPage {
  TimelinePage(TimelineQuery query) : super(query: query);

  @override
  void onTap(BuildContext context) {
    Turn.to(context, '/page4/discovery?msg=messagefromquery',
        express: DiscoveryQuery('这是从上一个页面传入的参数'),
        params: {'message': '这是通过Map传递参数'});
  }

  @override
  String get title => 'HOME';
}
