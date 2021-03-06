import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:magpie_log/ui/log_float_view.dart';

import 'file/data_analysis.dart';
import 'handler/statistics_handler.dart';
import 'model/analysis_model.dart';

//const bool isDebug = const bool.fromEnvironment("dart.vm.product");
const bool globalIsDebug = !const bool.fromEnvironment("dart.vm.product");
const bool globalIsPageLogOn = true;
const String globalClientId = "com.wuba.flutter.magpie_log";

typedef PageNameCallback = String Function(Route route);

class MagpieLog {
  // 工厂模式
  factory MagpieLog() => _getInstance();

  static MagpieLog get instance => _getInstance();
  static MagpieLog _instance;

  MagpieLog._internal() {
    // 初始化
  }

  bool isDebug = globalIsDebug;
  bool isPageLogOn = globalIsPageLogOn;
  List<Route<dynamic>> routeStack = List();

  PageNameCallback pageNameCallback;

  static bool _isInit = false;

  static MagpieLog _getInstance() {
    if (_instance == null) {
      _instance = new MagpieLog._internal();
    }
    return _instance;
  }

  init(BuildContext context, ReportMethod reportMethod,
      ReportChannel reportChannel,
      {int time,
      int count,
      AnalysisCallback callback,
      PageNameCallback pageNameCallback}) {
    // 暂时还没有更好的办法来处理某些只需要初始化一次的函数

    this.pageNameCallback = pageNameCallback;

    if (!_isInit) {
      MagpieDataAnalysis.initMagpieData(context); //初始化圈选数据
      MagpieStatisticsHandler.instance.initConfig(reportMethod, reportChannel,
          callback: callback,
          time: time != null ? time : 1 * 60 * 1000,
          count: count != null ? count : 3);
      _isInit = true;
    }
  }

  String getCurrentPath() {
    if (pageNameCallback != null) {
      return pageNameCallback(getCurrentRoute());
    }

    return getCurrentRoute() != null
        ? getCurrentRoute().settings.name
        : "not define";
  }

  BuildContext getCurrentContext() {
    Route route = getCurrentRoute();
    return route.navigator.context;
  }

  Route getCurrentRoute() {
    return MagpieLog.instance.routeStack.length > 0
        ? routeStack[MagpieLog.instance.routeStack.length - 1]
        : null;
  }

  ///actionListMap
  ///事件列表
  LinkedHashMap actionListMap = LinkedHashMap();

  addToActionList(String key, Route route) {
    actionListMap[key] = route;
    FloatEntry.singleton.refresh();
  }

  removeFromActionList(String key) {
    actionListMap.remove(key);
  }
}

abstract class LogState {
  int get logStatus => _logStatus;
  int _logStatus;

  Map<String, dynamic> toJson();
}

class LogAction {
  static LogAction setUp(actionName, index, actionParams) {
    return LogAction(actionName, index: index, actionParams: actionParams);
  }

  LogAction(this.actionName, {this.index = 0, this.actionParams});

  String actionName;
  int index; //用于列表页position
  Map actionParams; //action拓展参数
}
