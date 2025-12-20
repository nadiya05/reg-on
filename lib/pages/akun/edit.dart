import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> user;
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nikController;
  late TextEditingController nameController;
  late TextEditingController genderController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  File? _image;

  @override
  void initState() {
    super.initState();
    nikController = TextEditingController(text: widget.user['nik']);
    nameController = TextEditingController(text: widget.user['name']);
    genderController =
        TextEditingController(text: widget.user['jenis_kelamin']);
    emailController = TextEditingController(text: widget.user['email']);
    phoneController = TextEditingController(text: widget.user['no_telp']);
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Token tidak ditemukan, silakan login ulang")),
      );
      return;
    }

    var uri =
        Uri.parse("http://10.0.2.2:8000/api/users/${widget.user['id']}");

    var request = http.MultipartRequest("POST", uri);
    request.fields['_method'] = 'PUT';

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    request.fields['nik'] = nikController.text;
    request.fields['name'] = nameController.text;
    request.fields['jenis_kelamin'] = genderController.text;
    request.fields['email'] = emailController.text;
    request.fields['no_telp'] = phoneController.text;

    if (_image != null) {
      request.files.add(
        await http.MultipartFile.fromPath('foto', _image!.path),
      );
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil berhasil diperbarui!")),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("Gagal update profil (${response.statusCode})")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Profil",
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromRGBO(0, 119, 182, 1),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header + foto
            Container(
              color: const Color.fromRGBO(0, 119, 182, 1),
              padding: const EdgeInsets.symmetric(vertical: 20),
              width: double.infinity,
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 65,
                        backgroundImage: _image != null
                            ? FileImage(_image!)
                            : (widget.user['foto'] != null
                                ? NetworkImage(
                                    "http://10.0.2.2:8000/storage/${widget.user['foto']}")
                                : const AssetImage(
                                        "assets/images/profile.jpg")
                                    as ImageProvider),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _pickImage,
                          child: const CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.camera_alt,
                                color: Colors.blue),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.user['name'] ?? "Nama belum diisi",
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Form
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 2)),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField("NIK", nikController),
                    _buildTextField("Nama", nameController),
                    _buildTextField("Jenis Kelamin", genderController),
                    _buildTextField("Email", emailController),
                    _buildTextField("No Telepon", phoneController),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromRGBO(0, 119, 182, 1),
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Simpan",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: const Icon(Icons.edit, color: Colors.grey),
          enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue)),
        ),
      ),
    );
  }
}
