import 'package:equatable/equatable.dart';

import 'models.dart';

sealed class CustomFailure extends Equatable {
  final String message;
  final String? stackTrace;
  final int? code;

  CustomFailure({required this.message, this.stackTrace, this.code});
}

class ServerFailure extends CustomFailure {
  ServerFailure({required super.message, super.code, super.stackTrace});
  @override
  List<Object?> get props => [message, code];
}

class CacheFailure extends CustomFailure {
  CacheFailure({required super.message, super.code, super.stackTrace});
  @override
  List<Object?> get props => [message, code];
}

class NetworkFailure extends CustomFailure {
  NetworkFailure({required super.message, super.code, super.stackTrace});
  @override
  List<Object?> get props => [message, code];
}

class SdkFailure extends CustomFailure {
  SdkFailure({required super.message, super.code, super.stackTrace});
  @override
  List<Object?> get props => [message, code];
}

class ParamsFailure extends CustomFailure {
  ParamsFailure({required super.message, super.code, super.stackTrace});
  @override
  List<Object?> get props => [message, code];
}

sealed class Params {}

class LoginWithMailAndPassParams extends Params {
  final String email;
  final String password;
  LoginWithMailAndPassParams({required this.email, required this.password});
}

class LoginWithPhoneAndPassParams extends Params {
  final String phoneNumber;
  final String password;
  LoginWithPhoneAndPassParams(
      {required this.phoneNumber, required this.password});
}

class RegisterWithApiParams extends Params {
  final User user;
  RegisterWithApiParams({required this.user});
}

class UserIdParams extends Params {
  final String userId;
  UserIdParams({required this.userId});
}
