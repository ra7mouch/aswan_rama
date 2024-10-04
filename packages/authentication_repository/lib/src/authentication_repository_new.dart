import 'package:aswan_api/esports.dart';
import 'package:cache/cache.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'models/models.dart';

/// this is useful for DI principle : dependency inversion
abstract interface class IAuthenticationRepository {
  static const userCacheKey = '__user_cache_key__';
  User get currentUser;
  Stream<User> authStream();
  Future<Result<User, CustomFailure>> login({Params? params});
  Future<Result<bool, CustomFailure>> logout();
  Future<Result<User, CustomFailure>> register({Params? params});
  Future<Result<User, CustomFailure>> getUser({Params? params});
  Future<Result<User, CustomFailure>> updateUser({Params? params});
  Future<Result<bool, CustomFailure>> deleteUser({Params? params});
  Future<Result<bool, CustomFailure>> upgradeAccount({Params? params});
}

abstract interface class INetworkChecker {
  Future<bool> get isConnected;
}

class AuthServerRepository implements IAuthenticationRepository {
  final INetworkChecker networkChecker;
  final CacheClient _cache;
  Dio? _client;

  AuthServerRepository(
      {required CacheClient client, required this.networkChecker})
      : _cache = client;

  Dio get client {
    if (_client == null) {
      _client = AswanApi().apiHttpClient;
    }
    return _client!;
  }

  @override
  Future<Result<bool, CustomFailure>> logout() {
    // TODO: implement logout
    throw UnimplementedError();
  }

  /// we need an endpoint to check whether we have a user in our
  /// db having the same google account email or not
  Future<Result<User, CustomFailure>> getUserByEmail(
      {required String email, required String googleAuthCode}) async {
    try {
      if (await networkChecker.isConnected) {
        /// todo :: check endpoint
        final res = await client.post('/check-email', data: {
          'email-exist': email,
          'google-token': googleAuthCode,
        });
        return Result.success(User.fromJson(json: res.data));
      }
      return Result.failure(
          NetworkFailure(message: 'we lost connection', code: 500));
    } on DioException catch (err) {
      return Result.failure(
          ServerFailure(message: err.response!.statusMessage.toString()));
    } catch (e) {
      return Result.failure(ServerFailure(message: 'Server Error'));
    }
  }

  @override
  Future<Result<bool, CustomFailure>> deleteUser({Params? params}) async {
    if (params is! UserIdParams) {
      return Result.failure(
          ParamsFailure(message: 'UserIdParams error', code: 500));
    }
    try {
      if (await networkChecker.isConnected) {
        /// todo : correct endpoint
        final res = await client.delete(
          '/delete_account/${params.userId}',
        );
        return Result.success(true);
      }
      return Result.failure(
          NetworkFailure(message: 'we lost connection', code: 500));
    } on DioException catch (err) {
      return Result.failure(
          ServerFailure(message: err.response!.statusMessage.toString()));
    } catch (e) {
      return Result.failure(ServerFailure(message: 'Server Error'));
    }
  }

  @override
  Future<Result<User, CustomFailure>> getUser({Params? params}) async {
    if (params is! UserIdParams) {
      return Result.failure(
          ParamsFailure(message: 'UserIdParams error', code: 500));
    }
    try {
      if (await networkChecker.isConnected) {
        /// todo : correct endpoint
        final res = await client.get(
          '/user/${params.userId}',
        );
        return Result.success(User.fromJson(json: res.data));
      }
      return Result.failure(
          NetworkFailure(message: 'we lost connection', code: 500));
    } on DioException catch (err) {
      return Result.failure(
          ServerFailure(message: err.response!.statusMessage.toString()));
    } catch (e) {
      return Result.failure(ServerFailure(message: 'Server Error'));
    }
  }

  @override
  Future<Result<User, CustomFailure>> login({Params? params}) async {
    try {
      if (await networkChecker.isConnected) {
        if (params is LoginWithMailAndPassParams) {
          final res = await client.post('/login-with-mail-and-pass', data: {
            'email': params.email,
            'password': params.password,
          });
          return Result.success(User.fromJson(json: res.data));
        } else if (params is LoginWithPhoneAndPassParams) {
          final res = await client.post('/login-with-phone-and-pass', data: {
            'phone_number': params.phoneNumber,
            'password': params.password,
          });
          return Result.success(User.fromJson(json: res.data));
        }
      }
      return Result.failure(
          NetworkFailure(message: 'we lost connection', code: 500));
    } on DioException catch (err) {
      return Result.failure(
          ServerFailure(message: err.response!.statusMessage.toString()));
    } catch (e) {
      return Result.failure(ServerFailure(message: 'Server Error'));
    }
  }

  @override
  Future<Result<User, CustomFailure>> register({Params? params}) {
    // TODO: implement register
    throw UnimplementedError();
  }

  @override
  Future<Result<User, CustomFailure>> updateUser({Params? params}) {
    // TODO: implement updateUser
    throw UnimplementedError();
  }

  @override
  Future<Result<bool, CustomFailure>> upgradeAccount({Params? params}) {
    // TODO: implement upgradeAccount
    throw UnimplementedError();
  }

  /// how do we get a stream from the backend that notifies us whenever user session
  /// expires?
  /// the answer is SSE server Side Event
  /// the backend must provide us with an endpoint that returns a stream
  /// the stream will return an object or an exception whenever the session changes
  @override
  Stream<User> authStream() {
    /// on this case we have created a custom stream on the in memory cache
    /// service, whenever a value is added to the user key it will yield an element
    /// in this stream we will convert it either to a User or a User.empty
    /// we can as well user SSE if the backend allow it
    return _cache.cacheStream.asyncMap((element) async {
      if (element is! User) {
        return User.empty;
      }
      return element;
    });
  }

  @override
  User get currentUser =>
      _cache.read<User>(key: IAuthenticationRepository.userCacheKey) ??
      User.empty;
}

class AuthSocialSignInRepository implements IAuthenticationRepository {
  final AuthServerRepository serverRepository;

  AuthSocialSignInRepository({required this.serverRepository});

  static final _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      // "https://mail.google.com/",
      // "https://www.googleapis.com/auth/contacts.readonly",
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/user.emails.read',
      // 'https://www.googleapis.com/auth/gmail.send',
      'https://www.googleapis.com/auth/user.phonenumbers.read',
      'https://www.googleapis.com/auth/userinfo.profile',
      'https://www.googleapis.com/auth/user.birthday.read',
      'https://www.googleapis.com/auth/user.addresses.read', /////**************************
    ],

    /// you should get Server client ID from Google Cloud Console
    /// ask the Google cloud Console maintainer to get you this
    serverClientId: 'YOUR_SERVER_CLIENT_ID_HERE_RAHMA',
  );

  static Future<GoogleSignInAccount?> signIn() async {
    if (await _googleSignIn.isSignedIn()) {
      return _googleSignIn.currentUser;
    }
    return await _googleSignIn.signIn();
  }

  User get currentUser =>
      serverRepository._cache
          .read<User>(key: IAuthenticationRepository.userCacheKey) ??
      User.empty;
  @override
  Future<Result<bool, CustomFailure>> deleteUser({Params? params}) {
    // TODO: implement deleteUser
    throw UnimplementedError();
  }

  @override
  Future<Result<User, CustomFailure>> getUser({Params? params}) {
    // TODO: implement getUser
    throw UnimplementedError();
  }

  /// here once we login with Gmail we need to check weather we have a user
  /// in our db with the exact same email or not,
  /// for that we will call [AuthServerRepository.getUserByEmail],
  /// if we do not, then we will resolve with error + we should logout from google
  /// as well to avoid any weired behavior
  /// PS :: this google auth sign in does nt use firebase
  @override
  Future<Result<User, CustomFailure>> login({Params? params}) async {
    try {
      if (await serverRepository.networkChecker.isConnected) {
        if (await _googleSignIn.isSignedIn()) {
          await _googleSignIn.signOut();
        }
        final googleUser = await _googleSignIn.signIn();

        /// only use this when you want to use firebase
        //final GoogleSignInAuthentication? googleAuth =
        //  await googleUser?.authentication;

        if (googleUser == null) {
          return Result.failure(
              SdkFailure(message: 'could not login with gmail Error'));
        }

        /// check if we have a user in our db with the same Email
        final check = await serverRepository.getUserByEmail(

            /// [GoogleSignInAccount.serverAuthCode] is shortly lived, meaning the backend guys
            /// can use it to verify the authentication and generate a valid access token
            /// and return it to the app
            /// ps : this requires backend setup
            googleAuthCode: googleUser.serverAuthCode ?? '',
            email: googleUser.email);

        if (check.isSuccess()) {
          return check;
        } else {
          await _googleSignIn.signOut();
        }
        return Result.failure(
            ServerFailure(message: (check as ServerFailure).message));
      }
      return Result.failure(
          NetworkFailure(message: 'please check your network'));
    } catch (e) {
      return Result.failure(
          SdkFailure(message: 'could not login with gmail Error'));
    }
  }

  @override
  Future<Result<bool, CustomFailure>> logout() {
    // TODO: implement logout
    throw UnimplementedError();
  }

  @override
  Future<Result<User, CustomFailure>> register({Params? params}) {
    // TODO: implement register
    throw UnimplementedError();
  }

  @override
  Future<Result<User, CustomFailure>> updateUser({Params? params}) {
    // TODO: implement updateUser
    throw UnimplementedError();
  }

  @override
  Future<Result<bool, CustomFailure>> upgradeAccount({Params? params}) {
    // TODO: implement upgradeAccount
    throw UnimplementedError();
  }

  /// this auth stream from google will call [AuthServerRepository.getUserByEmail]
  /// and it will be triggered whenever the google user change!
  /// if the backend recognizes the email sent it will send us a new user with a
  /// valid access token
  /// or else, it will resolve with 404 or sth
  /// when it does we should return [User.empty] because that will trigger the redirection
  /// in the [AppBlocObserver]
  @override
  Stream<User> authStream() {
    return _googleSignIn.onCurrentUserChanged.asyncMap((account) async {
      if (account?.serverAuthCode != null) {
        final res = await serverRepository.getUserByEmail(
            email: account?.email ?? '',
            googleAuthCode: account?.serverAuthCode ?? '');
        return res.fold((onSuccess) => onSuccess, (onFailure) => User.empty);
      }
      return User.empty;
    });
  }
}
