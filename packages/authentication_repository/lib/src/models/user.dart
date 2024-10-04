import 'package:equatable/equatable.dart';

/// {@template user}
/// User model
///
/// [User.empty] represents an unauthenticated user.
/// {@endtemplate}
class User extends Equatable {
  /// {@macro user}
  const User({
    required this.id,
    this.email,
    this.name,
    this.photo,
    this.accessToken,
    this.refreshToken,
  });

  /// The current user's email address.
  final String? email;

  /// The current user's id.
  final String id;

  /// The current user's name (display name).
  final String? name;

  /// Url for the current user's photo.
  final String? photo;

  final String? accessToken;

  final String? refreshToken;

  /// Empty user which represents an unauthenticated user.
  static const empty = User(id: '');

  @override
  List<Object?> get props => [email, id, name, photo];

  factory User.fromJson({required Map<String, dynamic> json}) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      photo: json['photo'],
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
    );
  }
}
