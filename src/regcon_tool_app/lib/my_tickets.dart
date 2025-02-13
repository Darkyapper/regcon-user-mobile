import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MyTicketsScreen extends StatefulWidget {
  @override
  _MyTicketsScreenState createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  List<Map<String, dynamic>> tickets = [];

  @override
  void initState() {
    super.initState();
    _loadMyTickets();
  }

  Future<void> _loadMyTickets() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedTickets = prefs.getStringList('myTickets');

    // Verifica que savedTickets no sea null y que tenga elementos
    if (savedTickets != null) {
      setState(() {
        tickets = savedTickets
            .map((e) => jsonDecode(e) as Map<String, dynamic>)
            .toList();
      });
    } else {
      // Si no hay tickets guardados, inicializa la lista vacía
      setState(() {
        tickets = [];
      });
    }
  }

  Future<void> _removeTicket(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      tickets.removeAt(index);
    });

    List<String> updatedTickets = tickets.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList('myTickets', updatedTickets);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Boleto eliminado"),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: tickets.isEmpty
          ? Center(
              child: Text(
                "No tienes boletos aún",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];

                return Dismissible(
                  key: Key(ticket['event_id']?.toString() ??
                      UniqueKey().toString()), // Evita error de null
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _removeTicket(index);
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    margin: EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        if (ticket['event_image'] !=
                            null) // Verifica si la imagen existe
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              ticket['event_image'],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return SizedBox(); // Si hay error, no muestra nada
                              },
                            ),
                          ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ticket['event_name'] ?? 'Evento desconocido',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                  "Fecha: ${ticket['event_date'] ?? 'No disponible'}"),
                              Text(
                                  "Ubicación: ${ticket['location'] ?? 'No disponible'}"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
