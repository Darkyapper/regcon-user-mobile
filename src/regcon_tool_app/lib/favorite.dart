import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:regcon_tool_app/shared_prefs.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({Key? key}) : super(key: key);

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  List<Map<String, dynamic>> interests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInterests(); // Cargar las categorías de eventos
  }

  // Cargar categorías de eventos desde el servidor
  Future<void> _loadInterests() async {
    try {
      final response = await Dio()
          .get('https://recgonback-8awa0rdv.b4a.run/event-categories');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        setState(() {
          interests = data.map((category) {
            return {'label': category['name'], 'selected': false};
          }).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error al cargar intereses: $e');
      setState(() => isLoading = false);
    }
  }

  // Guardar preferencias del usuario en el servidor
  Future<void> _saveUserPreferences() async {
    final userId = await SharedPrefs.getUserId(); // Obtener el ID del usuario
    if (userId == null) {
      print('No se encontró el ID de usuario');
      return;
    }

    List<String> selectedLabels = interests
        .where((i) => i['selected'] == true)
        .map((i) => i['label'] as String)
        .toList();

    try {
      await Dio().put(
        'https://recgonback-8awa0rdv.b4a.run/users/$userId/preferences',
        data: {
          'event_preferences': {
            'selected_categories': selectedLabels,
          },
          'email_notifications': 'true',
        },
      );
      print('Preferencias guardadas correctamente');
      Navigator.pushReplacementNamed(context, '/home'); // Redirigir a Home
    } catch (e) {
      print('Error al guardar preferencias: $e');
    }
  }

  // Omitir las preferencias y redirigir al home
  void _skipPreferences() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFB088),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFB088),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    '¡Escoge tus intereses!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '¡Esto nos ayudará a encontrar los eventos adecuados para ti!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.black87,
                        ),
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFFFF7F50)))
                        : SingleChildScrollView(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 12,
                              children: interests.map((interest) {
                                return FilterChip(
                                  label: Text(
                                    interest['label'],
                                    style: TextStyle(
                                      color: interest['selected']
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  selected: interest['selected'],
                                  onSelected: (bool selected) {
                                    setState(() {
                                      interest['selected'] = selected;
                                    });
                                  },
                                  backgroundColor: Colors.grey[200],
                                  selectedColor: const Color(0xFFFF7F50),
                                  checkmarkColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                );
                              }).toList(),
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _skipPreferences,
                        child: const Text(
                          'Omitir',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _saveUserPreferences,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7F50),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Siguiente',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
