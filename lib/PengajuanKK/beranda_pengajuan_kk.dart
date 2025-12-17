import 'package:flutter/material.dart';

class BerandaPengajuanKK extends StatelessWidget {
  const BerandaPengajuanKK({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(0, 119, 182, 1),
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 HEADER (back + logo kanan + gambar utama)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Tombol Back
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Image.asset(
                            "assets/images/logo.png",
                            height: 100,
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Gambar utama agak dikeatasin
                  SizedBox(
                    height: 200,
                    child: Image.asset(
                      "assets/images/beranda_KTP.png", // ubah ke gambar versi KK
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 KONTEN PUTIH dengan tulisan & menu
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(120),
                    topRight: Radius.circular(0),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      "Layanan dokumen KK",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Informasi → kiri
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 220,
                        child: _menuButton(
                          context,
                          "Informasi",
                          onTap: () {
                            Navigator.pushNamed(context, '/informasiKK');
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Pengajuan KK → kanan
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 220,
                        child: _menuButton(
                          context,
                          "Pengajuan\nKK",
                          onTap: () {
                            Navigator.pushNamed(context, '/form-pengajuan-kk');
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Status → kiri
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 220,
                        child: _menuButton(
                          context,
                          "Status",
                          onTap: () {
                            Navigator.pushNamed(context, '/status_pengajuan_kk');
                          },
                        ),
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

  // 🔹 MENU BUTTON COMPONENT
  Widget _menuButton(BuildContext context, String text,
      {VoidCallback? onTap}) {
    return SizedBox(
      height: 120,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(0, 119, 182, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 3,
          padding: const EdgeInsets.all(16),
        ),
        onPressed: onTap,
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
