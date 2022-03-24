import 'package:example/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:turn/turn.dart';
import 'page1.dart';
import 'page3.dart';

class ActionOne extends Target {
  @override
  response(BuildContext? context, Options options) {
    switch (options.path) {
      case '/':
        return Home();
      case "/page1/page_one":
        print(options.express);
        return PageOne(
          params: options.express?.extraQuery,
        );
      case "/page1/page_three":
        return PageThree(
          params: options.express?.extraQuery,
        );
      case "/page1/page_data":
        return {"message": "this is not a widget!"};
      default:
        break;
    }
  }
}
