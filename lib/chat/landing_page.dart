import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LandingPageChat extends StatelessWidget {
  const LandingPageChat({super.key});

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0077B6),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 🔵 Lingkaran dekorasi kiri atas
            Positioned(
              top: -100,
              left: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.lightBlue[200],
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // 🔵 Lingkaran dekorasi kanan atas
            Positioned(
              top: 20,
              right: -100,
              child: Container(
                width: 250,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.lightBlue[300],
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // 🔹 Konten utama
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Header + logo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Image.asset(
                        "assets/images/logo.png",
                        height: 100,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Gambar bot
                Flexible(
                  flex: 4,
                  child: Image.asset(
                    'assets/images/minloh.png',
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 10),

                // Kartu bawah
                Expanded(
                  flex: 5,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 25),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Hello Penduduk!",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0077B6),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Apakah ada yang ingin dibantu?\nJika ada, mari berbicara dengan MinLoh.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 25),

                        // 🔹 Tombol chat
                        SizedBox(
                          width: 200,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0077B6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 3,
                            ),
                            onPressed: () async {
                              final token = await getToken();

                              if (token == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Token tidak ditemukan, silakan login ulang'),
                                  ),
                                );
                                return;
                              }

                              // Panggil chat start
                              await http.post(
                                Uri.parse("http://10.0.2.2:8000/api/chat/start"),
                                headers: {
                                  'Authorization': "Bearer $token",
                                  'Accept': 'application/json',
                                },
                              );

                              Navigator.pushNamed(
                                context,
                                '/chatRoom',
                                arguments: {
                                  'userId': 1,
                                  'token': token,
                                  'userAvatarUrl': "http://10.0.2.2:8000/storage/foto_user.jpg",
                                  'adminAvatarUrl': "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
                                },
                              );
                            },

                            child: const Text(
                              "Ketuk untuk ngobrol",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
