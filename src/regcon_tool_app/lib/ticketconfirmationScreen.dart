import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'ticketManager.dart';

class TicketConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> event;
  final int availableTicketsCount;
  final double ticketPrice;
  final String ticketName;
  final String ticketDescription;

  const TicketConfirmationScreen({
    required this.event,
    required this.availableTicketsCount,
    required this.ticketPrice,
    required this.ticketName,
    required this.ticketDescription,
    super.key,
  });

  @override
  _TicketConfirmationScreenState createState() =>
      _TicketConfirmationScreenState();
}

class _TicketConfirmationScreenState extends State<TicketConfirmationScreen> {
  int ticketCount = 1;
  double get totalPrice => widget.ticketPrice * ticketCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEventInfo(),
                  SizedBox(height: 24),
                  _buildTicketDetails(),
                  SizedBox(height: 24),
                  _buildTicketCounter(),
                  SizedBox(height: 24),
                  _buildPriceSummary(),
                  SizedBox(height: 32),
                  _buildConfirmButton(),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 220.0,
      floating: false,
      pinned: true,
      backgroundColor: Color(0xFFEB6D1E),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          "Confirmar Boletos",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3.0,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.event['event_image'] ?? 'https://via.placeholder.com/400',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/default_event.png',
                  fit: BoxFit.cover,
                );
              },
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 60,
              left: 16,
              right: 16,
              child: Text(
                widget.event['event_name'],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventInfo() {
    String formattedDate = "No disponible";
    try {
      final date = DateTime.parse(widget.event['event_date']);
      formattedDate = DateFormat('EEEE d MMMM, y', 'es').format(date);
    } catch (e) {
      formattedDate = widget.event['event_date'] ?? "No disponible";
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Información del Evento",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEB6D1E),
              ),
            ),
            Divider(),
            SizedBox(height: 8),
            _buildInfoRow(
              Icons.calendar_today,
              "Fecha",
              formattedDate,
            ),
            SizedBox(height: 12),
            _buildInfoRow(
              Icons.location_on,
              "Ubicación",
              widget.event['location'] ?? "No disponible",
            ),
            SizedBox(height: 12),
            _buildInfoRow(
              Icons.category,
              "Categoría",
              widget.event['category_name'] ?? "No disponible",
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0, duration: 500.ms);
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTicketDetails() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Detalles del Boleto",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEB6D1E),
              ),
            ),
            Divider(),
            SizedBox(height: 8),
            _buildInfoRow(
              Icons.confirmation_number,
              "Tipo de Boleto",
              widget.ticketName,
            ),
            SizedBox(height: 12),
            _buildInfoRow(
              Icons.description,
              "Descripción",
              widget.ticketDescription,
            ),
            SizedBox(height: 12),
            _buildInfoRow(
              Icons.inventory,
              "Disponibles",
              "${widget.availableTicketsCount} boletos",
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0, duration: 500.ms);
  }

  Widget _buildTicketCounter() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Cantidad de Boletos",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEB6D1E),
              ),
            ),
            Divider(),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCounterButton(
                  Icons.remove,
                  () {
                    if (ticketCount > 1) {
                      setState(() {
                        ticketCount--;
                      });
                    }
                  },
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$ticketCount',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildCounterButton(
                  Icons.add,
                  () {
                    if (ticketCount < widget.availableTicketsCount) {
                      setState(() {
                        ticketCount++;
                      });
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0, duration: 500.ms);
  }

  Widget _buildCounterButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: Color(0xFFEB6D1E),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(12),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildPriceSummary() {
    final formatter = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Resumen de Compra",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEB6D1E),
              ),
            ),
            Divider(),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Precio por boleto:",
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  formatter.format(widget.ticketPrice),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Cantidad:",
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  "$ticketCount",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  formatter.format(totalPrice),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEB6D1E),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0, duration: 500.ms);
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _confirmTicket,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFEB6D1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 24),
            SizedBox(width: 8),
            Text(
              "Confirmar Compra",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().scale(delay: 300.ms);
  }

  void _confirmTicket() async {
    if (ticketCount < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Por favor, seleccione al menos un boleto"),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEB6D1E)),
          ),
        );
      },
    );

    // Llamada para reservar boletos
    final ticketManager = TicketManager();
    try {
      final ticketCodes = await ticketManager.reserveTickets(
        widget.event['category_id'],
        ticketCount,
      );

      // Dismiss loading indicator
      Navigator.pop(context);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> tickets = prefs.getStringList('myTickets') ?? [];

      for (String ticketCode in ticketCodes) {
        Map<String, dynamic> newTicket = {
          'ticket_code': ticketCode,
          'event_id': widget.event['event_id'],
          'event_name': widget.event['event_name'],
          'ticket_count': ticketCount,
          'event_date': widget.event['event_date'],
          'event_image': widget.event['event_image'],
          'price': widget.ticketPrice,
        };

        tickets.add(jsonEncode(newTicket));
      }

      await prefs.setStringList('myTickets', tickets);

      // Show success dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 8),
                Text("¡Compra Exitosa!"),
              ],
            ),
            content: Text(
              "Tus boletos han sido añadidos a 'Mis Boletos'. ¡Disfruta del evento!",
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text(
                  "Aceptar",
                  style: TextStyle(color: Color(0xFFEB6D1E), fontSize: 16),
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Dismiss loading indicator
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al confirmar los boletos: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}
