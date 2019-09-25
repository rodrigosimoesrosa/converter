import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class LifecycleEventHandler extends WidgetsBindingObserver {
  LifecycleEventHandler({this.inactiveCallBack, this.pausedCallback,
    this.suspendingCallBack, this.resumeCallBack});

  final AsyncCallback inactiveCallBack;
  final AsyncCallback pausedCallback;
  final AsyncCallback suspendingCallBack;
  final AsyncCallback resumeCallBack;

  @override
  Future<Null> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        if (inactiveCallBack == null) {
          return;
        }

        await inactiveCallBack();
        break;

      case AppLifecycleState.paused:
        if (pausedCallback == null) {
          return;
        }

        await pausedCallback();
        break;

      case AppLifecycleState.suspending:
        if (suspendingCallBack == null) {
          return;
        }

        await suspendingCallBack();
        break;

      case AppLifecycleState.resumed:
        if (resumeCallBack == null) {
          return;
        }

        await resumeCallBack();
        break;
    }
  }
}
