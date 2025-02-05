import 'package:flutter/material.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({Key? key}) : super(key: key);

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final List<Map<String, dynamic>> interests = [
    {'label': 'Música', 'icon': Icons.music_note, 'selected': false},
    {'label': 'Comida', 'icon': Icons.restaurant, 'selected': false},
    {'label': 'Trabajo', 'icon': Icons.work, 'selected': false},
    {'label': 'Arte', 'icon': Icons.palette, 'selected': false},
    {'label': 'Tecnología', 'icon': Icons.computer, 'selected': false},
    {'label': 'Hobbies', 'icon': Icons.sports_esports, 'selected': false},
    {'label': 'Educación', 'icon': Icons.school, 'selected': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background decorative circles
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
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Close button
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Title
                  const Text(
                    '¡Escoge tus intereses!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Subtitle
                  const Text(
                    '¡Esto nos ayudará a encontrar los eventos adecuados para ti!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Interests grid
                  Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    children: interests.map((interest) {
                      return FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              interest['icon'],
                              size: 18,
                              color: interest['selected']
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              interest['label'],
                              style: TextStyle(
                                color: interest['selected']
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ],
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
                          horizontal: 12,
                          vertical: 8,
                        ),
                      );
                    }).toList(),
                  ),
                  const Spacer(),
                  // Next button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle next button press
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7F50),
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
