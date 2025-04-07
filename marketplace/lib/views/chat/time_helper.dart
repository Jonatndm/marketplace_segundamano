import 'package:intl/intl.dart';

String formatearTiempoTranscurrido(DateTime fechaMensaje) {
  final ahora = DateTime.now();
  final diferencia = ahora.difference(fechaMensaje);

  if (diferencia.inMinutes < 60) {
    return 'hace ${diferencia.inMinutes} minutos';
  } else if (diferencia.inHours < 24) {
    return 'hace ${diferencia.inHours} horas';
  } else if (diferencia.inDays == 1) {
    return 'ayer';
  } else {
    return DateFormat('d MMM. yyyy', 'es_ES').format(fechaMensaje);
  }
}
