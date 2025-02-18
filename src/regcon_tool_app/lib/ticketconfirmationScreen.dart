import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TicketConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> event;
  final int availableTicketsCount;
  final double ticketPrice;

  const TicketConfirmationScreen({
    required this.event,
    required this.availableTicketsCount,
    required this.ticketPrice,
    super.key,
  });

  @override
  _TicketConfirmationScreenState createState() =>
      _TicketConfirmationScreenState();
}

class _TicketConfirmationScreenState extends State<TicketConfirmationScreen> {
  int ticketCount = 1;
  String paymentMethod = 'Ninguno';

  @override
  void initState() {
    super.initState();
  }

  void _confirmTicket(BuildContext context) async {
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

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tickets = prefs.getStringList('myTickets') ?? [];

    Map<String, dynamic> ticket = {
      'event_id': widget.event['event_id'],
      'event_name': widget.event['event_name'],
      'ticket_count': ticketCount,
      'ticket_code': DateTime.now().millisecondsSinceEpoch.toString(),
      'event_date': widget.event['event_date'],
      'event_image': widget.event['event_image'],
      'location': widget.event['location'] ??
          'No disponible', // Asumí un campo location
      'price': widget.ticketPrice, // Precio del boleto
      'available_tickets':
          widget.availableTicketsCount // Cantidad de boletos disponibles
    };

    tickets.add(jsonEncode(ticket));
    await prefs.setStringList('myTickets', tickets);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("¡Boleto(s) añadido(s) a 'Mis Boletos'!"),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Confirmar boletos",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFFEB6D1E),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildEventHeader(),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEventInfo(),
                  SizedBox(height: 24),
                  _buildTicketCounter(),
                  SizedBox(height: 24),
                  _buildAvailableTickets(),
                  SizedBox(height: 32),
                  _buildConfirmButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventHeader() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
              widget.event['event_image'] ?? 'https://via.placeholder.com/400'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
          ),
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              widget.event['event_name'],
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    ).animate().fadeIn().slideY(begin: -0.2, end: 0, duration: 500.ms);
  }

  Widget _buildEventInfo() {
    final formattedDate = DateFormat('d MMMM, y')
        .format(DateTime.parse(widget.event['event_date']));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Fecha: $formattedDate",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        Text(
          "Precio: \$${widget.ticketPrice.toString()}",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ],
    ).animate().fadeIn().slideX(begin: -0.2, end: 0, duration: 500.ms);
  }

  Widget _buildTicketCounter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Cantidad de boletos: ",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Color(0xFFEB6D1E)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove, color: Color(0xFFEB6D1E)),
                onPressed: () {
                  if (ticketCount > 1) {
                    setState(() {
                      ticketCount--;
                    });
                  }
                },
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('$ticketCount',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              IconButton(
                icon: Icon(Icons.add, color: Color(0xFFEB6D1E)),
                onPressed: () {
                  setState(() {
                    ticketCount++;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn().slideX(begin: 0.2, end: 0, duration: 500.ms);
  }

  Widget _buildAvailableTickets() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Boletos disponibles:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          Text("${widget.availableTicketsCount}",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEB6D1E))),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0, duration: 500.ms);
  }

  Widget _buildConfirmButton() {
    return ElevatedButton(
      onPressed: () => _confirmTicket(context),
      child: Text("Confirmar Boleto(s)", style: TextStyle(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFEB6D1E),
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ).animate().fadeIn().scale(delay: 300.ms);
  }
}
