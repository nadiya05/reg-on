import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DaftarPage extends StatefulWidget {
  const DaftarPage({super.key});

  @override
  State<DaftarPage> createState() => _DaftarPageState();
}

class _DaftarPageState extends State<DaftarPage> {
  // Controller input
  final nikController = TextEditingController();
  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final noTelpController = TextEditingController();
  final jenisKelaminController = TextEditingController();

  Future<void> register() async {
    // Validasi simple
    if (nikController.text.isEmpty ||
        namaController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        noTelpController.text.isEmpty ||
        jenisKelaminController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua field harus diisi!")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/api/register"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json", // ganti ke form-data kalau perlu
        },
        body: jsonEncode({
          "nik": nikController.text,
          "name": namaController.text,
          "email": emailController.text,
          "password": passwordController.text,
          "no_telp": noTelpController.text,
          "jenis_kelamin": jenisKelaminController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Berhasil daftar: ${data['message'] ?? 'OK'}")),
        );
        Navigator.pushReplacementNamed(context, '/masuk');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Gagal daftar: ${data['message'] ?? response.body}",
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Bagian atas biru
            Container(
              width: double.infinity,
              height: 250,
              decoration: const BoxDecoration(
                color: Color(0xFF0077B6),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 20,
                    right: -30,
                    child: Image.asset(
                      "assets/images/logo.png",
                      height: 120,
                    ),
                  ),
                  Positioned(
                    bottom: -90,
                    left: -20,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          "assets/images/bundaran mangga.jpeg",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 120),

            const Text(
              "Daftar",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 30),

Padding(
  padding: const EdgeInsets.symmetric(horizontal: 24),
  child: Column(
    children: [
      _buildTextField("NIK", controller: nikController),
      const SizedBox(height: 12),
      _buildTextField("Nama Lengkap", controller: namaController),
      const SizedBox(height: 12),
      _buildTextField("Email", controller: emailController),
      const SizedBox(height: 12),
      _buildTextField("Sandi",
          obscure: true, controller: passwordController),
      const SizedBox(height: 12),
      _buildTextField("No Telepon", controller: noTelpController),
      const SizedBox(height: 12),

      // 🔽 Dropdown Jenis Kelamin
      DropdownButtonFormField<String>(
        decoration: InputDecoration(
          hintText: "Jenis Kelamin",
          contentPadding: const EdgeInsets.symmetric(
              vertical: 14, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        value: jenisKelaminController.text.isEmpty
            ? null
            : jenisKelaminController.text,
        items: const [
          DropdownMenuItem(
            value: "Wanita",
            child: Text("Wanita"),
          ),
          DropdownMenuItem(
            value: "Pria",
            child: Text("Pria"),
          ),
        ],
        onChanged: (value) {
          setState(() {
            jenisKelaminController.text = value ?? "";
          });
        },
      ),

      const SizedBox(height: 30),

      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: register,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0077B6),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            "Daftar",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),


                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Sudah punya akun? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/masuk');
                        },
                        child: const Text(
                          "Masuk",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint,
      {bool obscure = false, TextEditingController? controller}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}
