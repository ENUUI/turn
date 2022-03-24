import 'package:flutter/material.dart';

import 'turn_page.dart';
import 'package:turn/turn.dart';

class AccountQuery extends Express {
  AccountQuery(this.desc);

  final String desc;
}

class AccountPage extends TurnPage {
  AccountPage(AccountQuery query) : super(query: query);

  @override
  void onTap(BuildContext context) {
    Turn.popUntil(context, Navigator.defaultRouteName);
  }

  @override
  String get title => 'ACCOUNT';
}
