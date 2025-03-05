import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'ticketconfirmationScreen.dart';

class EventDescriptionScreen extends StatefulWidget {
  final Map<String, dynamic> event;

  const EventDescriptionScreen({required this.event, super.key});

  @override
  _EventDescriptionScreenState createState() => _EventDescriptionScreenState();
}

class _EventDescriptionScreenState extends State<EventDescriptionScreen> {
  int availableTicketsCount = 0;
  double ticketPrice = 0.0;
  String ticketName = '';
  String ticketDescription = '';
  bool isTicketAvailable = true;

  @override
  void initState() {
    super.initState();
    _getTicketInformation(); // Obtiene información de los boletos disponibles y precio
  }

  Future<void> _getTicketInformation() async {
    try {
      // Primero obtenemos el ticketcategory_id usando el event_id
      final ticketEventResponse = await http.get(
        Uri.parse(
          'https://recgonback-8awa0rdv.b4a.run/ticket-events/${widget.event['event_id']}',
        ),
      );

      if (ticketEventResponse.statusCode == 200) {
        final ticketEventData = json.decode(ticketEventResponse.body);

        // Verificar si tenemos datos
        if (ticketEventData['data'].isNotEmpty) {
          String ticketcategoryId =
              ticketEventData['data'][0]['ticketcategory_id'].toString();

          // Usamos el ticketcategory_id para obtener la información del boleto
          final ticketCategoryResponse = await http.get(
            Uri.parse(
              'https://recgonback-8awa0rdv.b4a.run/ticket-categories-with-counts/$ticketcategoryId',
            ),
          );

          if (ticketCategoryResponse.statusCode == 200) {
            final ticketCategoryData = json.decode(ticketCategoryResponse.body);

            setState(() {
              availableTicketsCount =
                  int.parse(ticketCategoryData['data']['ticket_count']);
              ticketPrice = double.parse(ticketCategoryData['data']['price']);
              ticketName = ticketCategoryData['data']['name'];
              ticketDescription = ticketCategoryData['data']['description'];
              isTicketAvailable = availableTicketsCount > 0;
            });
          }
        }
      }
    } catch (e) {
      print('Error al obtener la información de boletos: $e');
      setState(() {
        availableTicketsCount = 0;
        ticketPrice = 0.0;
        ticketName = 'Desconocido';
        ticketDescription = 'No disponible';
        isTicketAvailable = false;
      });
    }
  }

  void _navigateToTicketConfirmation(BuildContext context) async {
    // Navegar a TicketConfirmationScreen sin guardar automáticamente el boleto
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketConfirmationScreen(
          event: widget.event,
          availableTicketsCount: availableTicketsCount,
          ticketPrice: ticketPrice,
          ticketName: ticketName, // Pasamos el nombre del boleto
          ticketDescription: ticketDescription, // Descripción del boleto
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
                      onPressed: isTicketAvailable
                          ? () => _navigateToTicketConfirmation(context)
                          : null, // El botón está deshabilitado si no hay boletos disponibles
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
                              isTicketAvailable
                                  ? "Añadir a Mis Boletos"
                                  : "Boletos agotados",
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
