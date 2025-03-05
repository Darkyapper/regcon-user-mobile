import 'dart:convert';
import 'package:http/http.dart' as http;

class TicketManager {
  // Método para reservar boletos
  Future<List<String>> reserveTickets(int categoryId, int ticketCount) async {
    try {
      final url = Uri.parse('https://recgonback-8awa0rdv.b4a.run/tickets');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'category_id': categoryId, // Asegúrate de que se pase correctamente
          'ticket_count': ticketCount,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['message'] == 'Success' && data['data'] != null) {
          List<String> ticketCodes = [];
          for (var ticket in data['data']) {
            ticketCodes.add(ticket['code']); // Obtiene el código de cada ticket
          }
          return ticketCodes; // Devuelve los códigos de los boletos
        } else {
          throw Exception('No se pudo obtener los boletos');
        }
      } else {
        throw Exception('Error al contactar al servidor');
      }
    } catch (e) {
      print('Error al reservar los boletos: $e');
      throw Exception('Error al reservar los boletos');
    }
  }
}
