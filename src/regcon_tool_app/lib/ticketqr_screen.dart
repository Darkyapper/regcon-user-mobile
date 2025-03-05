import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TicketQRScreen extends StatefulWidget {
  final String ticketCode;
  final int ticketCategoryId; // Añadido ticketCategoryId

  const TicketQRScreen({
    Key? key,
    required this.ticketCode,
    required this.ticketCategoryId, // Asegúrate de que este parámetro esté aquí
  }) : super(key: key);

  @override
  _TicketQRScreenState createState() => _TicketQRScreenState();
}

class _TicketQRScreenState extends State<TicketQRScreen> {
  bool isLoading = true;
  String ticketImageUrl = "";
  String ticketCode = "";

  @override
  void initState() {
    super.initState();
    ticketCode = widget.ticketCode;
    _generateQRCode();
  }

  Future<void> _generateQRCode() async {
    try {
      final url = Uri.parse(
          'https://api.qrserver.com/v1/create-qr-code/?data=${widget.ticketCode}&size=200x200');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          ticketImageUrl = url.toString(); // Usamos la URL directamente
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al generar el QR")),
        );
      }
    } catch (e) {
      print('Error al generar el QR: $e');
      setState(() {
        isLoading = false;
      });
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
                'Tu Ticket',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFFE67E22)))
          : Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTicketCard(),
                      SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTicketCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFE67E22),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Ticket QR',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    ticketImageUrl,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 200,
                        height: 200,
                        color: Colors.grey[300],
                        child: Center(child: Text("Error al cargar QR")),
                      );
                    },
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'ID: $ticketCode',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 8),
                Text(
                  'Válido para un acceso',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
