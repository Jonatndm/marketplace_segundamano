import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenCageService {
  static const String _apiKey = '6d29cdef69b945389d69ad7151dd29a9';
  static const String _baseUrl = 'https://api.opencagedata.com/geocode/v1/json';

  // Método para obtener la dirección a partir de las coordenadas
  static Future<String> getAddressFromCoordinates(
    double lat,
    double lng,
  ) async {
    final url = '$_baseUrl?q=$lat+$lng&key=$_apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'].isNotEmpty) {
        // Obtén la dirección formateada
        return data['results'][0]['formatted'];
      }
    }
    return 'Ubicación no disponible';
  }
}
