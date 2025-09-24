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
          children: [
            // Header logo
            Image.asset(
              "assets/images/logo.png",
              height: 140,
            ),
            const SizedBox(height: 30),

            // Ilustrasi dalam kotak biru
            Expanded(
              child: Align(
                child: Container(
                  width: 331,
                  height: 331,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0077B6),
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
                "Hello Penduduk!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0077B6),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                "Jika ingin melakukan administrasi melalui website kami silahkan daftar terlebih dahulu",
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
