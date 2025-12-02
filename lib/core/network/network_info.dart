import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();

    // SỬA LẠI DÒNG NÀY:
    // Vì phiên bản hiện tại trả về 1 kết quả duy nhất, ta so sánh trực tiếp.
    return result != ConnectivityResult.none;
  }
}
