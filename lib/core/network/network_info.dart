import 'package:internet_connection_checker/internet_connection_checker.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker connectionChecker;

  NetworkInfoImpl(this.connectionChecker);

  // VER NOTA ABAJO;
  @override
  Future<bool> get isConnected => connectionChecker.hasConnection;
}

/**
 * LA LLAMADA A NETWORKINFO.ISCONNECTED ES «REENVIADA» A
 * INTERNETCONNECTIONCHECKER.HASCONNECTION
 */
