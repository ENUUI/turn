import 'package:flutter/material.dart';

class SubIndex extends StatefulWidget {
  const SubIndex({Key? key}) : super(key: key);

  @override
  State<SubIndex> createState() => _SubIndexState();
}

class _SubIndexState extends State<SubIndex> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute != null) {
      print(modalRoute.settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SubModule Page'),
      ),
    );
  }
}
