import 'package:flutter/material.dart';

class LandingPage1 extends StatelessWidget {
  const LandingPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Bungkus Stack dengan SizedBox supaya punya tinggi
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

            // ilustrasi kotak tetap di tengah
            Expanded(
              child: Center(
                child: Container(
                  width: 331,
                  height: 331,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(0, 119, 182, 1),
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

            // teks rata tengah
            const Text(
              "Hello Penduduk!",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(0, 119, 182, 1),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              "Selamat datang di website kami, pelayanan dokumen kecamatan Lohbener!!",
              style: TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
