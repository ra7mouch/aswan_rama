import 'package:aswan/app/app.dart';
import 'package:aswan/presentation/home/view/home_page.dart';
import 'package:aswan/presentation/login/view/login_page.dart';
import 'package:flutter/widgets.dart';

List<Page<dynamic>> onGenerateAppViewPages(
  AppStatus state,
  List<Page<dynamic>> pages,
) {
  switch (state) {
    case AppStatus.authenticated:
      return [HomePage.page()];
    case AppStatus.unauthenticated:
      return [LoginPage.page()];
  }
}
