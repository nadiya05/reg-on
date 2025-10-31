import 'package:flutter/material.dart';

class LandingPage3 extends StatelessWidget {
  const LandingPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [ // <- pastikan children: [] ada
            SizedBox(
              height: 160, // sesuaikan tinggi dengan logo
              child: Stack(
                children: [
                  // Konten kosong di belakang (bisa diisi nanti)
                  Container(),

                  // Logo di kanan atas, mirip halaman masuk
                  Positioned(
                    top: -10,
                    right: -55,
                    child: Image.asset(
                      "assets/images/logo.png",
                      height: 140,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Ilustrasi dalam kotak biru
            Expanded(
              child: Align(
                child: Container(
                  width: 331,
                  height: 331,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(0, 119, 182, 1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Image.asset(
                      "assets/images/landingpage.png",
                      height: 280,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Teks rata tengah
            const Center(
              child: Text(
                "Halo Penduduk Lohbener!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(0, 119, 182, 1),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                "Jika ingin melakukan administrasi melalui aplikasi kami silahkan daftar terlebih dahulu",
                style: TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
