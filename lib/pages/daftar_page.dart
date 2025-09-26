import 'package:flutter/material.dart';

class DaftarPage extends StatelessWidget {
  const DaftarPage({super.key});

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
                  // Logo pojok kanan atas
                  Positioned(
                    top: 20,
                    right: -30,
                    child: Image.asset(
                      "assets/images/logo.png",
                      height: 120,
                    ),
                  ),

                  // Gambar setengah lingkaran di kiri bawah
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

            // Judul
            const Text(
              "Daftar",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 30),

            // Form Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                   _buildTextField("NIK"),
                  const SizedBox(height: 12),
                  _buildTextField("Nama Lengkap"),
                  const SizedBox(height: 12),
                  _buildTextField("Email"),
                  const SizedBox(height: 12),
                  _buildTextField("Sandi", obscure: true),
                  const SizedBox(height: 12),
                  _buildTextField("No Telepon"),
                  const SizedBox(height: 12),
                  _buildTextField("Jenis Kelamin"),
                  const SizedBox(height: 12),

                  const SizedBox(height: 30),

                  // Tombol Daftar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Akun berhasil dibuat!")),
                        );
                        Navigator.pushReplacementNamed(context, '/masuk');
                      },
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

                  // Link ke Masuk
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

  Widget _buildTextField(String hint, {bool obscure = false}) {
    return TextField(
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
