import 'package:turn/turn.dart';
import 'page1.dart';
import 'page3.dart';

class ActionOne extends Target {
  @override
  String get targeName => "page1";

  @override
  Widget task(String action, Map<String, dynamic> params) {
    switch (action) {
      case "page1/page_one":
        return PageOne(
          params: params,
        );
      case "page1/page_three":
        return PageThree(
          params: params,
        );
      default:
        break;
    }
  }
}
