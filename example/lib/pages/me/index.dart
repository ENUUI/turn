import 'package:flutter/material.dart';
import 'package:turn/turn.dart';

class MePage extends StatefulWidget {
  const MePage({Key? key}) : super(key: key);

  @override
  State<MePage> createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute != null) {
      print(modalRoute.settings);
      final id = (modalRoute.settings.arguments as Arguments?)?.params?['id'];
      print('id: $id is ${id.runtimeType}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Me'),
      ),
    );
  }
}
