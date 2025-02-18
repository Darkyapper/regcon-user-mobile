import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

class TicketQRScreen extends StatefulWidget {
  final String ticketCode;
  const TicketQRScreen({Key? key, required this.ticketCode}) : super(key: key);

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
      final url = Uri.parse('https://tuapi.com/tickets/${widget.ticketCode}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = response.body;
        final qrUrl =
            'https://api.qrserver.com/v1/create-qr-code/?data=$ticketCode&size=200x200';

        setState(() {
          ticketImageUrl = qrUrl;
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
                      _buildShareButton(),
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

  Widget _buildShareButton() {
    return ElevatedButton.icon(
      icon: Icon(Icons.share),
      label: Text('Compartir Ticket'),
      onPressed: () {
        Share.share('Tu ticket: $ticketCode');
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Color(0xFFE67E22),
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
