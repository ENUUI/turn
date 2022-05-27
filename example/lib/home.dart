import 'package:example/routes/route.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MaterialButton(
              onPressed: () {
                // AppRoute.I.push(
                //   context,
                //   'discovery',
                //   data: {'key2': 'value2'},
                //   package: 'main',
                // ).catchError((err, s) {
                //   print(err);
                //   print(s);
                // });
                /// OR
                // AppRoute.I.main.push(
                //   context,
                //   'discovery',
                //   data: {'key2': 'value2'},
                // ).catchError((err, s) {
                //   print(err);
                //   print(s);
                // });
                /// OR
                AppRoute.I.sub.push(
                  context,
                  'discovery',
                  package: 'main',
                  data: {'key2': 'value2'},
                ).catchError((err, s) {
                  print(err);
                  print(s);
                });
              },
              child: Text('Push To `discovery'),
            ),
            MaterialButton(
              onPressed: () {
                AppRoute.I.push(
                  context,
                  'me/255',
                  data: {'key3': 'value3'},
                ).catchError((err, s) {
                  print(err);
                  print(s);
                });
              },
              child: Text('Push To `me/:id'),
            ),
            MaterialButton(
              onPressed: () {
                AppRoute.I
                    .push(context, 'discovery',
                        data: {'key4': 'value4'}, package: 'sub')
                    .catchError((err, s) {
                  print(err);
                  print(s);
                });
              },
              child: Text('Push To Sub `discovery`'),
            ),
            MaterialButton(
              onPressed: () {
                AppRoute.I.push(
                  context,
                  'sub/page',
                  data: {'key1': 'value1'},
                ).catchError((err, s) {
                  print(err);
                  print(s);
                });
              },
              child: Text('Push To `sub/page'),
            ),
          ],
        ),
      ),
    );
  }
}
