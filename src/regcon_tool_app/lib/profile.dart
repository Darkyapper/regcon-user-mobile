import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'shared_prefs.dart'; 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> userProfile = {};
  List<dynamic> favoriteEvents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Cargar el perfil del usuario y sus eventos favoritos
  Future<void> _loadUserProfile() async {
    final userId = await SharedPrefs.getUserId(); // Obtener el ID del usuario
    if (userId == null) {
      print('No se encontró el ID de usuario');
      return;
    }

    try {
      final response = await Dio().get(
        'https://recgonback-8awa0rdv.b4a.run/users/$userId/profile',
      );
      if (response.statusCode == 200) {
        setState(() {
          userProfile = response.data['user'];
          favoriteEvents = response.data['favorite_events'];
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error al cargar el perfil del usuario: $e');
      setState(() => isLoading = false);
    }
  }

  // Eliminar un evento de la lista de favoritos
  Future<void> _removeFavoriteEvent(String eventId) async {
    final userId = await SharedPrefs.getUserId();
    if (userId == null) {
      print('No se encontró el ID de usuario');
      return;
    }

    try {
      final response = await Dio().delete(
        'https://recgonback-8awa0rdv.b4a.run/users/$userId/favorites/$eventId',
      );

      if (response.statusCode == 200) {
        // Actualizar la lista de eventos favoritos en el estado
        setState(() {
          favoriteEvents.removeWhere((event) => event['id'] == eventId);
        });
        print('Evento eliminado de favoritos');
      } else {
        print('Error al eliminar el evento de favoritos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al eliminar el evento de favoritos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
        backgroundColor: const Color(0xFFFF7F50),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF7F50)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información del Usuario',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nombre: ${userProfile['name']}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Email: ${userProfile['email']}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Eventos Favoritos',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                  ),
                  const SizedBox(height: 16),
                  favoriteEvents.isEmpty
                      ? const Text('No tienes eventos favoritos.')
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: favoriteEvents.length,
                          itemBuilder: (context, index) {
                            final event = favoriteEvents[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: ListTile(
                                title: Text(event['name']),
                                subtitle: Text(event['date']),
                                trailing: IconButton(
                                  icon: const Icon(Icons.favorite, color: Colors.red),
                                  onPressed: () {
                                    // Llamar a la función para eliminar el evento de favoritos
                                    _removeFavoriteEvent(event['id']);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}