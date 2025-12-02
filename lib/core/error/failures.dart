import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  @override
  List<Object> get props => [];
}

// Lỗi do Cache (Local DB)
class CacheFailure extends Failure {}

// Lỗi do Server
class ServerFailure extends Failure {}
