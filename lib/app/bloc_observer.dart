// ignore_for_file: avoid_print
import 'package:aswan/app/app.dart';
import 'package:aswan/presentation/home/home.dart';
import 'package:aswan/presentation/login/login.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

class AppBlocObserver extends BlocObserver {
  final Navigator navigator;
  final GlobalKey<NavigatorState> navigationKey;
  const AppBlocObserver({required this.navigator, required this.navigationKey});

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    print(event);
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    print(error);
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    if (bloc is AppBloc) {
      /// if we are to use this function we need to use the router and replace the whole
      /// navigation stack,
      /// however i don't want to do that in runtime that is why i believe it is safer
      /// to use navigation keys
      final redirect =
          onGenerateAppViewPages(change.nextState, navigator.pages);
      final navigatorState = navigationKey.currentState;
      if (navigatorState == null) return;

      if ((change.nextState as AppState).status == AppStatus.authenticated) {
        navigatorState.pushAndRemoveUntil(HomePage.route(), (route) => true);
      } else {
        navigatorState.pushAndRemoveUntil(LoginPage.route(), (route) => true);
      }
    }

    super.onChange(bloc, change);
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    print(transition);
  }
}
