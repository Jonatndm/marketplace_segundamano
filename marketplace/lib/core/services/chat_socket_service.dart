import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket _socket;

  void connect(String token) {
    _socket = IO.io('http://localhost:5000', {
      'transports': ['websocket'],
      'autoConnect': false,
      'auth': {
        'token': token,
      }
    });

    _socket.connect();

    // Escuchar nuevos mensajes
    _socket.on('newMessage', (data) {
      // Aquí puedes actualizar la interfaz de usuario en tiempo real con el nuevo mensaje
    });

    // Escuchar si hay errores
    _socket.on('messageError', (error) {
    });

    // Escuchar la desconexión
    _socket.on('disconnect', (_) {
    });
  }

  void sendMessage(String chatId, String content) {
    _socket.emit('sendMessage', {
      'chatId': chatId,
      'content': content,
    });
  }

  void joinChat(String chatId) {
    _socket.emit('joinChat', chatId);
  }

  void disconnect() {
    _socket.disconnect();
  }
}
