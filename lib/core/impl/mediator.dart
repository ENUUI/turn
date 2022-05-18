import 'package:turn/core/interfaces/project.dart';

class DefaultProject extends Project {
  DefaultProject._();

  static final DefaultProject I = DefaultProject._();

  factory DefaultProject() {
    return I;
  }
}
