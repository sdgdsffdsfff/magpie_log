import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:magpie_log/ui/log_screen.dart';

abstract class WidgetLogState<T extends StatefulWidget> extends State {
  String getActionName();

  var logStatus;

  @override
  Widget build(BuildContext context) {
    if (logStatus == 1)
      return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red, width: 2.0),
          ),
          child: onBuild(context));
    else
      return onBuild(context);
  }

  Widget onBuild(BuildContext context);

  @override
  void setState(VoidCallback fn) {
    Map<String, dynamic> json = toJson();
    print("MyMiddleWare call:${json.toString()}");
    Navigator.of(context).push(MaterialPageRoute(
        settings: RouteSettings(name: "/LogScreen"),
        builder: (BuildContext context) {
          return LogScreen(
            data: json,
            actionName: getActionName(),
            func: fn,
            state: this,
          );
        }));
    //super.setState(fn);
  }

  setRealState(Function func) {
    super.setState(func);
  }

  @override
  void initState() {
    super.initState();
  }

  Map<String, dynamic> toJson();
}
