import 'package:marketplace/core/services/opencage_service.dart';

class OpenCageRepository {
  // Método para obtener la dirección a partir de las coordenadas
  Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      return await OpenCageService.getAddressFromCoordinates(lat, lng);
    } catch (error) {
      throw Exception('Error al obtener la dirección: $error');
    }
  }
}