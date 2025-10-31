import 'package:flutter/material.dart';
import 'package:reg_on/pages/akun/edit.dart';

class IndexPage extends StatelessWidget {
  final Map<String, dynamic> user;
  const IndexPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 119, 182, 1),
        iconTheme: const IconThemeData(color: Colors.white), 
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Akun Saya",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ), // jarak teks & logo
            Image.asset(
              "assets/images/logo.png",
              height: 95, // 👉 gedein disini (misal 40-50)
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Bagian biru + foto
            Container(
              color: const Color.fromRGBO(0, 119, 182, 1),
              padding: const EdgeInsets.only(top: 30, bottom: 20),
              width: double.infinity,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 65, // agak besar biar kayak di gambar
                    backgroundImage: user['foto'] != null && user['foto'].isNotEmpty
                        ? NetworkImage("http://10.0.2.2:8000/storage/${user['foto']}")
                        : const AssetImage("assets/images/profile.jpg") as ImageProvider,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user['name'] ?? "Nama belum diisi",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Card putih
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              height: 400, // 👉 biar lebih panjang ke bawah
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 2, // biar lebih melebar
                  offset: Offset(0, 0), // tengah → nyebar ke semua arah
                ),
              ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoText(user['nik'] ?? "NIK belum diisi"),
                  _buildInfoText(user['name'] ?? "Nama belum diisi"),
                  _buildInfoText(user['jenis_kelamin'] ?? "Jenis kelamin belum diisi"),
                  _buildInfoText(user['email'] ?? "Email belum diisi"),
                  _buildInfoText(user['no_telp'] ?? "No telepon belum diisi"),
                  const Spacer(), // biar tombol Edit selalu di bawah
                  const SizedBox(height: 40),
           SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfilePage(user: user), // ⬅️ class harus sama
        ),
      );
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color.fromRGBO(0, 119, 182, 1),
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    child: const Text(
      "Edit",
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
  ),
)

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  

  Widget _buildInfoText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );
  }
}
