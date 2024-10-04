import 'package:flutter/material.dart';

class AppRouteObserver implements RouteObserver {
  @override
  bool debugObservingRoute(Route route) {
    // TODO: implement debugObservingRoute
    throw UnimplementedError();
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    // TODO: implement didPop
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    // TODO: implement didPush
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    // TODO: implement didRemove
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    // TODO: implement didReplace
  }

  @override
  void didStartUserGesture(Route route, Route? previousRoute) {
    // TODO: implement didStartUserGesture
  }

  @override
  void didStopUserGesture() {
    // TODO: implement didStopUserGesture
  }

  @override
  // TODO: implement navigator
  NavigatorState? get navigator => throw UnimplementedError();

  @override
  void subscribe(RouteAware routeAware, Route route) {
    // TODO: implement subscribe
  }

  @override
  void unsubscribe(RouteAware routeAware) {
    // TODO: implement unsubscribe
  }
}
