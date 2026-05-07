import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../models/user_model.dart';
import '../sources/auth_remote_source.dart';
import '../sources/auth_local_source.dart';

// Repository isolates the Bloc from knowing about sources (SOLID: OCP, DIP)
class AuthRepositoryImpl {
  final AuthRemoteSource _remote;
  final AuthLocalSource _local;

  AuthRepositoryImpl(this._remote, this._local);

  Future<Either<Failure, UserModel>> login(String email, String password) async {
    try {
      final data = await _remote.login(email, password);
      final token = data['token'] as String;
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      await _local.saveToken(token);
      await _local.saveUser(user);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  Future<Either<Failure, UserModel>> register(
      String name, String email, String password) async {
    try {
      final data = await _remote.register(name, email, password);
      final token = data['token'] as String;
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      await _local.saveToken(token);
      await _local.saveUser(user);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    }
  }

  Future<void> logout() => _local.clearToken();

  Future<UserModel?> getCachedUser() => _local.getUser();
}
