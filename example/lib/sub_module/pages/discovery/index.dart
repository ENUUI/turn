
import 'package:flutter/material.dart';

class Discovery extends StatefulWidget {
  const Discovery({Key? key}) : super(key: key);

  @override
  State<Discovery> createState() => _DiscoveryState();
}

class _DiscoveryState extends State<Discovery> {
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
        title: const Text('SubModule Discovery Page'),
      ),
    );
  }
}
