import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'ticketconfirmationScreen.dart';

class EventDescriptionScreen extends StatefulWidget {
  final Map<String, dynamic> event;

  const EventDescriptionScreen({required this.event, super.key});

  @override
  _EventDescriptionScreenState createState() => _EventDescriptionScreenState();
}

class _EventDescriptionScreenState extends State<EventDescriptionScreen> {
  int availableTicketsCount = 0;
  double ticketPrice = 0.0; // Precio del boleto

  @override
  void initState() {
    super.initState();
    _getTicketInformation(); // Obtiene información de los boletos disponibles y precio
  }

  Future<void> _getTicketInformation() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://reggonback-8awa0rdv.b4a.run/ticket-events/${widget.event['event_id']}',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          // Aquí ajustamos el parsing según los datos del backend
          availableTicketsCount = data['data'][0]
              ['available_tickets']; // Cantidad de boletos disponibles
          ticketPrice =
              data['data'][0]['ticket_price'] ?? 0.0; // Precio del boleto
        });
      } else {
        setState(() {
          availableTicketsCount = 0;
          ticketPrice = 0.0;
        });
      }
    } catch (e) {
      print('Error al obtener la información de boletos: $e');
      setState(() {
        availableTicketsCount = 0;
        ticketPrice = 0.0;
      });
    }
  }

  void _addToMyTickets(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tickets = prefs.getStringList('myTickets') ?? [];

    var uuid = Uuid();
    String ticketCode = uuid.v4();

    Map<String, dynamic> newTicket = {
      'ticket_code': ticketCode,
      'event_id': widget.event['event_id'],
      'event_name': widget.event['event_name'],
      'event_date': widget.event['event_date'],
      'location': widget.event['location'],
      'event_image': widget.event['event_image'],
      'ticket_price': ticketPrice, // Precio del boleto
      'available_tickets':
          availableTicketsCount // Cantidad de boletos disponibles
    };

    tickets.add(jsonEncode(newTicket));
    await prefs.setStringList('myTickets', tickets);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text("${widget.event['event_name']} añadido a Mis Boletos 🎟️"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketConfirmationScreen(
          event: widget.event, // Pasando todos los detalles del evento
          availableTicketsCount: availableTicketsCount, // Cantidad de boletos
          ticketPrice: ticketPrice, // Precio del boleto
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.event['event_name'] ?? 'Evento sin nombre',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                ),
              ),
              background: Image.network(
                widget.event['event_image'] ??
                    'https://via.placeholder.com/400',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/default_event.png',
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(Icons.calendar_today,
                      "Fecha: ${widget.event['event_date'] ?? 'Fecha no disponible'}"),
                  SizedBox(height: 12),
                  _buildInfoRow(Icons.location_on,
                      "Ubicación: ${widget.event['location'] ?? 'Ubicación no disponible'}"),
                  SizedBox(height: 20),
                  _buildChips(),
                  SizedBox(height: 20),
                  if (widget.event['workgroup_name'] != null) ...[
                    Text(
                      "Organizado por: ${widget.event['workgroup_name']}",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                  ],
                  Text(
                    "Descripción",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.event['event_description'] ??
                          'No hay descripción disponible',
                      style: TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ),
                  SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => _addToMyTickets(context),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color(0xFFEB6D1E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.confirmation_number,
                                color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              "Añadir a Mis Boletos",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn().scale(),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFFEB6D1E)),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ).animate().fadeIn().slideX();
  }

  Widget _buildChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Chip(
          label: Text(
            widget.event['is_online'] == true
                ? "Evento en línea"
                : "Evento presencial",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor:
              widget.event['is_online'] == true ? Colors.blue : Colors.green,
        ),
        Chip(
          label: Text(
            "Categoría: ${widget.event['category_name'] ?? 'Desconocida'}",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Color(0xFFEB6D1E),
        ),
      ],
    ).animate().fadeIn().slideY();
  }
}
