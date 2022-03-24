import 'package:example/pages4/account.dart';
import 'package:example/pages4/discovery.dart';
import 'package:example/pages4/timeline.dart';
import 'package:flutter/material.dart';
import 'package:turn/turn.dart';

class Target4 extends Target {
  @override
  dynamic response(BuildContext? context, Options options) {
    switch (options.path) {
      case '/page4/timeline':
        return TimelinePage(options.express as TimelineQuery?);
      case '/page4/account':
        return AccountPage(options.express as AccountQuery?);
      case '/page4/discovery':
        return DiscoveryPage(options.express as DiscoveryQuery?);
    }
  }
}
