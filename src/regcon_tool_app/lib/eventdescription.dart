import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EventDescriptionScreen extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventDescriptionScreen({required this.event, super.key});

  Future<void> _addToMyTickets(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tickets = prefs.getStringList('myTickets') ?? [];

    List<Map<String, dynamic>> ticketList =
        tickets.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();

    bool alreadyExists =
        ticketList.any((ticket) => ticket['event_id'] == event['event_id']);

    if (!alreadyExists) {
      tickets.add(jsonEncode(event));
      await prefs.setStringList('myTickets', tickets);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${event['event_name']} añadido a Mis Boletos 🎟️"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Este boleto ya está en tu lista 🎟️"),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFEB6D1E),
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 40,
              width: 40,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                event['event_name'] ?? 'Evento sin nombre',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis, // Evita desbordamiento
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen del evento con validación
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  event['event_image'] ?? 'https://via.placeholder.com/400',
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/default_event.png',
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              SizedBox(height: 20),

              // Fecha del evento
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.grey[700]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Fecha: ${event['event_date'] ?? 'Fecha no disponible'}",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis, // Evita desbordamiento
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),

              // Ubicación del evento
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.grey[700]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Ubicación: ${event['location'] ?? 'Ubicación no disponible'}",
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      overflow: TextOverflow.ellipsis, // Evita desbordamiento
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Categoría y si es online o presencial
              Row(
                children: [
                  Chip(
                    label: Text(
                      event['is_online'] == true
                          ? "Evento en línea"
                          : "Evento presencial",
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor:
                        event['is_online'] == true ? Colors.blue : Colors.green,
                  ),
                  SizedBox(width: 10),
                  Chip(
                    label: Text(
                      "Categoría: ${event['category_name'] ?? 'Desconocida'}",
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.orange,
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Nombre del grupo de trabajo (si aplica)
              if (event['workgroup_name'] != null) ...[
                Text(
                  "Organizado por: ${event['workgroup_name']}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
              ],

              // Descripción del evento
              Text(
                "Descripción",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),

              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  event['event_description'] ?? 'No hay descripción disponible',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 30),

              // Botón "Añadir a Mis Boletos"
              Center(
                child: GestureDetector(
                  onTap: () => _addToMyTickets(context),
                  child: Container(
                    width: 250,
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        colors: [Color(0xFFFF7E00), Color(0xFFEB6D1E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(2, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.confirmation_number, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          "Añadir a Mis Boletos",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
