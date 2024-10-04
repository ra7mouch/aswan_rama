import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:result_dart/result_dart.dart';

class AswanApi {
  final apiHttpClient = Dio()
    ..interceptors.add(LogInterceptor(responseBody: true))
    ..options.baseUrl = 'http://mas.phyliatech.com/api/'
    ..options.connectTimeout =
        const Duration(seconds: 5) // Adjust based on your needs
    ..options.receiveTimeout =
        const Duration(seconds: 5) // Adjust based on your needs
    ..options.headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    };

  Future<Result<bool, Exception>> chekVersion() async {
    try {
      var response = await apiHttpClient.request(
        'http://mas.phyliatech.com/api/checktw',
        options: Options(
          method: 'POST',
        ),
        data: FormData.fromMap({'version': '2.3'}),
      );

      if (response.statusCode == 200) {
        print(json.encode(response.data));
        return const Result.success(true);
      } else {
        print(response.statusMessage);
        return Result.failure(Exception());
      }
    } catch (e, s) {
      print(s);
      return Result.failure(Exception(e));
    }
  }
}
