import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileConfigurationScreen extends StatefulWidget {
  const ProfileConfigurationScreen({Key? key}) : super(key: key);

  @override
  _ProfileConfigurationScreenState createState() =>
      _ProfileConfigurationScreenState();
}

class _ProfileConfigurationScreenState
    extends State<ProfileConfigurationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  DateTime? _birthDate;
  String? _profileImagePath;
  String _password = '';
  String _confirmPassword = '';
  bool _changePassword = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImagePath = image.path;
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Here you would typically save the profile data to a database or shared preferences
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Perfil actualizado con éxito'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configuración de Perfil",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFFEB6D1E),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNameField(),
                    SizedBox(height: 24),
                    _buildEmailField(),
                    SizedBox(height: 24),
                    _buildBirthDateField(),
                    SizedBox(height: 24),
                    _buildPasswordChangeOption(),
                    SizedBox(height: 32),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Color(0xFFEB6D1E),
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: _profileImagePath != null
                  ? FileImage(File(_profileImagePath!))
                  : AssetImage('assets/default_profile.png') as ImageProvider,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 20,
                child: IconButton(
                  icon: Icon(Icons.camera_alt, color: Color(0xFFEB6D1E)),
                  onPressed: _pickImage,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: -0.2, end: 0, duration: 500.ms);
  }

  Widget _buildNameField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Nombre',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: Icon(Icons.person, color: Color(0xFFEB6D1E)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese su nombre';
        }
        return null;
      },
      onSaved: (value) {
        _name = value!;
      },
    ).animate().fadeIn().slideX(begin: -0.2, end: 0, duration: 500.ms);
  }

  Widget _buildEmailField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Correo Electrónico',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: Icon(Icons.email, color: Color(0xFFEB6D1E)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese su correo electrónico';
        }
        if (!value.contains('@')) {
          return 'Por favor ingrese un correo electrónico válido';
        }
        return null;
      },
      onSaved: (value) {
        _email = value!;
      },
    ).animate().fadeIn().slideX(begin: 0.2, end: 0, duration: 500.ms);
  }

  Widget _buildBirthDateField() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'Fecha de Nacimiento',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: Icon(Icons.cake, color: Color(0xFFEB6D1E)),
          ),
          controller: TextEditingController(
            text: _birthDate != null
                ? DateFormat('dd/MM/yyyy').format(_birthDate!)
                : '',
          ),
        ),
      ),
    ).animate().fadeIn().slideX(begin: -0.2, end: 0, duration: 500.ms);
  }

  Widget _buildPasswordChangeOption() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _changePassword,
              onChanged: (value) {
                setState(() {
                  _changePassword = value!;
                });
              },
              activeColor: Color(0xFFEB6D1E),
            ),
            Text('Cambiar contraseña', style: TextStyle(fontSize: 16)),
          ],
        ),
        if (_changePassword) ...[
          SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Nueva Contraseña',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: Icon(Icons.lock, color: Color(0xFFEB6D1E)),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese una nueva contraseña';
              }
              if (value.length < 8) {
                return 'La contraseña debe tener al menos 8 caracteres';
              }
              return null;
            },
            onSaved: (value) {
              _password = value!;
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Confirmar Nueva Contraseña',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: Icon(Icons.lock_outline, color: Color(0xFFEB6D1E)),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor confirme su nueva contraseña';
              }
              if (value != _password) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
            onSaved: (value) {
              _confirmPassword = value!;
            },
          ),
        ],
      ],
    ).animate().fadeIn().slideY(begin: 0.2, end: 0, duration: 500.ms);
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveProfile,
      child: Text("Guardar Perfil", style: TextStyle(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFEB6D1E),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ).animate().fadeIn().scale(delay: 300.ms);
  }
}
