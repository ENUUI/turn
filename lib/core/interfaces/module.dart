import 'package:turn/src/opts.dart';

abstract class Module {
  dynamic fetch(Options options);
}
