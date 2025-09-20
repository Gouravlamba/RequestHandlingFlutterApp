import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'constants.dart';

typedef SocketCallback = void Function(dynamic data);

class SocketService {
  final String baseUrl;
  IO.Socket? _socket;

  SocketService({this.baseUrl = AppConstants.baseUrl});

  void connect({
    SocketCallback? onRequestCreated,
    SocketCallback? onRequestUpdated,
    SocketCallback? onRequestReassigned,
  }) {
    _socket ??= IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) => print('Socket connected: ${_socket!.id}'));

    if (onRequestCreated != null) _socket!.on('request_created', onRequestCreated);
    if (onRequestUpdated != null) _socket!.on('request_updated', onRequestUpdated);
    if (onRequestReassigned != null) _socket!.on('request_reassigned', onRequestReassigned);

    _socket!.onDisconnect((_) => print('Socket disconnected'));
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }
}
