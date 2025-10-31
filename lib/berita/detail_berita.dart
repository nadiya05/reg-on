import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DetailBerita extends StatefulWidget {
  final int id;

  const DetailBerita({super.key, required this.id});

  @override
  State<DetailBerita> createState() => _DetailBeritaState();
}

class _DetailBeritaState extends State<DetailBerita> {
  Map<String, dynamic>? berita;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchDetailBerita();
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchDetailBerita() async {
    setState(() => loading = true);
    try {
      final token = await getToken();
      final res = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/berita/${widget.id}'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body);
        setState(() {
          berita = jsonData['data'];
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E6BA8),
      body: SafeArea(
        child: loading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : berita == null
                ? const Center(
                    child: Text(
                      "Berita tidak ditemukan",
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : Column(
                    children: [
                      // 🔹 HEADER GELombang sama kayak BerandaBerita
                      Stack(
                        children: [
                          ClipPath(
                            clipper: WaveClipper(),
                            child: Container(
                              width: double.infinity,
                              height: 190,
                              color: Colors.white,
                            ),
                          ),
                          Positioned(
                            top: 16,
                            left: 0,
                            right: 0,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back, size: 28),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  Transform.translate(
                                    offset: const Offset(25, -70),
                                    child: Image.asset(
                                      "assets/images/logo.png",
                                      width: 190,
                                      height: 190,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 40,
                            bottom: 50,
                            child: Text(
                              "Detail Berita",
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // 🔹 ISI DETAIL BERITA
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 🖼️ FOTO BERITA
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  berita!['foto'] ??
                                      "https://via.placeholder.com/400x200.png?text=No+Image",
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 16),

                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 🗓️ Tanggal
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today,
                                            size: 18, color: Colors.black54),
                                        const SizedBox(width: 6),
                                        Text(
                                          berita!['tanggal'] ?? '-',
                                          style: GoogleFonts.poppins(
                                            color: Colors.black54,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),

                                    // 📢 Judul
                                    Text(
                                      berita!['judul'] ?? '-',
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF023E8A),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 17,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // 📜 Isi konten
                                    Text(
                                      berita!['konten'] ?? '-',
                                      textAlign: TextAlign.justify,
                                      style: GoogleFonts.poppins(
                                        color: Colors.black87,
                                        fontSize: 14,
                                        height: 1.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

// 🔹 CLIPPER GELombang (sama kayak BerandaBerita)
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 40);
    var secondControlPoint = Offset(3 * size.width / 4, size.height - 80);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
