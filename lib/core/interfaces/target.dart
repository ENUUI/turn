import 'package:turn/src/opts.dart';

abstract class Target {
  dynamic task(String action, Options params);
}
