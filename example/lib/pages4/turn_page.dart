import 'package:flutter/material.dart';
import 'package:turn/turn.dart';

abstract class TurnPage<T extends Express> extends StatelessWidget {
  const TurnPage({Key key, this.query}) : super(key: key);
  final T query;

  String get title => 'Turn Page';

  void onTap(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        children: [
          Text(query.toString()),
          Row(
            // mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => onTap(context),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  alignment: Alignment.center,
                  height: 44,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Color(0xFFEEEEEE),
                    border: Border.all(
                      width: 0.5,
                      color: const Color(0xFFffaE6E),
                    ),
                  ),
                  child: Text('NEXT'),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
