import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'eventdescription.dart';
import 'my_tickets.dart';
import 'login.dart';
import 'profile_confg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<dynamic> _events = [];
  bool _isLoading = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'Todos';
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _fetchCategories(); // Fetch categories for filtering
    _scrollController.addListener(_scrollListener);
    _searchController
        .addListener(_onSearchChanged); // Listen for search changes
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Fetch the categories from the server for filtering
  Future<void> _fetchCategories() async {
    try {
      final url =
          Uri.parse("https://recgonback-8awa0rdv.b4a.run/event-categories");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        setState(() {
          _categories = decodedResponse['data'];
        });
      } else {
        throw Exception('Error al cargar las categorías');
      }
    } catch (e) {
      print('Error al obtener las categorías: $e');
    }
  }

  Future<void> _loadEvents() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse("https://recgonback-8awa0rdv.b4a.run/all-events");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        final List<dynamic> data = decodedResponse['data'];

        setState(() {
          _events.addAll(data);
          _isLoading = false;
          if (data.isEmpty) _hasMore = false;
        });
      } else {
        setState(() => _isLoading = false);
        throw Exception('Error al cargar los eventos');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print(e);
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadEvents();
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  List<dynamic> _getFilteredEvents() {
    // Filters events by category and search text
    return _events.where((event) {
      final matchesFilter = _selectedFilter == 'Todos' ||
          event['category_name'] == _selectedFilter;
      final matchesSearch = _searchController.text.isEmpty ||
          event['event_name']
              .toLowerCase()
              .contains(_searchController.text.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

  void _onSearchChanged() {
    setState(() {}); // Trigger a rebuild when the search text changes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Color(0xFFEB6D1E),
      title: Image.asset('assets/logo.png', height: 40),
      actions: [
        IconButton(
          icon: Icon(Icons.logout, color: Colors.white),
          onPressed: _logout,
        ),
      ],
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildEventListPage();
      case 1:
        return MyTicketsScreen();
      case 2:
        return ProfileConfigurationScreen();
      default:
        return Center(child: Text('Selecciona una opción'));
    }
  }

  Widget _buildEventListPage() {
    return Column(
      children: [
        _buildSearchBar(),
        _buildFilterBar(),
        Expanded(child: _buildEventList()),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar eventos...',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(Icons.search, color: Color(0xFFEB6D1E)),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildFilterChip('Todos'),
          for (var category in _categories) _buildFilterChip(category['name']),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: _selectedFilter == label,
        onSelected: (bool selected) {
          setState(() {
            _selectedFilter = selected ? label : 'Todos';
          });
        },
        backgroundColor: Colors.grey[200],
        selectedColor: Color(0xFFEB6D1E),
        labelStyle: TextStyle(
          color: _selectedFilter == label ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildEventList() {
    final filteredEvents = _getFilteredEvents();
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(16),
      itemCount: filteredEvents.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == filteredEvents.length) {
          return Center(child: CircularProgressIndicator());
        }
        final event = filteredEvents[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(dynamic event) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDescriptionScreen(event: event),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                event['event_image'],
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['event_name'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  _buildInfoRow(
                      Icons.calendar_today, _formatDate(event['event_date'])),
                  SizedBox(height: 4),
                  _buildInfoRow(Icons.location_on, event['location']),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        label: Text(event['category_name']),
                        backgroundColor: Color(0xFFEB6D1E).withOpacity(0.2),
                        labelStyle: TextStyle(color: Color(0xFFEB6D1E)),
                      ),
                      Chip(
                        label: Text(event['workgroup_name']),
                        backgroundColor: Colors.blue.withOpacity(0.2),
                        labelStyle: TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    event['event_description'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return DateFormat('d MMMM, y').format(date);
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number), label: 'Mis boletos'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
      ],
    );
  }
}
