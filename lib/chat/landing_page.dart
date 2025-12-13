import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LandingPageChat extends StatelessWidget {
  const LandingPageChat({super.key});

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
  Future<Map<String, dynamic>?> fetchChatProfiles(String token) async {
    final response = await http.get(
      Uri.parse("http://10.0.2.2:8000/api/chat/profile"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0077B6),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // UI Dekorasi
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

            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Image.asset("assets/images/logo.png", height: 100),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Maskot
                Flexible(
                  flex: 4,
                  child: Image.asset(
                    'assets/images/minloh.png',
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 10),

                // Kartu Bawah
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

                        // BUTTON CHAT
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0077B6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
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

                              final data = await fetchChatProfiles(token);

                              if (data == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Gagal memuat profil Chat'),
                                  ),
                                );
                                return;
                              }

                              // Panggil API startChat untuk mengirim sapaan penduduk (jika memang belum pernah chat)
                              try {
                                final startRes = await http.post(
                                  Uri.parse("http://10.0.2.2:8000/api/chat/start"),
                                  headers: {
                                    "Authorization": "Bearer $token",
                                    "Accept": "application/json",
                                  },
                                );

                                // Tidak perlu force-handle responsnya — jika sudah pernah chat, backend akan return 200 tanpa membuat chat baru.
                                print("startChat status: ${startRes.statusCode}");
                              } catch (e) {
                                print("startChat error: $e");
                                // tetap lanjut ke chat page meskipun gagal, agar user tetap bisa chat
                              }

                              Navigator.pushNamed(
                                context,
                                '/chatRoom',
                                arguments: {
                                  'userId': data['user_id'],
                                  'token': token,
                                  'userAvatarUrl': data['avatar'],
                                  'adminAvatarUrl': data['admin_avatar'],
                                  'userName': data['name'],
                                  'adminName': data['admin_name'],
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
