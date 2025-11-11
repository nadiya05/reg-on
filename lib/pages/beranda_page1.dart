import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:reg_on/notifikasi/notifikasi_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reg_on/PengajuanKIA/beranda_pengajuan_kia.dart';
import 'package:reg_on/PengajuanKK/beranda_pengajuan_kk.dart';
import 'package:reg_on/pages/akun/index.dart';
import 'package:reg_on/pages/pengajuanKTP/beranda_pengajuan_ktp.dart';
import 'package:reg_on/berita/beranda_berita.dart';
import 'package:reg_on/berita/detail_berita.dart';
import 'package:reg_on/riwayat_pengajuan.dart';
import 'package:url_launcher/url_launcher.dart';


class BerandaPage1 extends StatefulWidget {
  final Map<String, dynamic> user;

  const BerandaPage1({super.key, required this.user});

  @override
  State<BerandaPage1> createState() => _BerandaPage1State();
}

class _BerandaPage1State extends State<BerandaPage1> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  List<dynamic> _newsItems = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchRandomBerita();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchRandomBerita() async {
    try {
      final token = await getToken();
      final res = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/berita'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final beritaList = (data['data'] ?? data['berita'] ?? []) as List;

        beritaList.shuffle(Random());
        final randomThree = beritaList.take(3).toList();

        setState(() {
          _newsItems = randomThree;
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      print('Error ambil berita: $e');
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          // 🔹 Background biru atas
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 320,
              decoration: const BoxDecoration(
                color: Color(0xFF0077B6),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
            ),
          ),

          // 🔹 Konten utama
          Positioned.fill(
            top: 120,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  _buildCarousel(),
                  const SizedBox(height: 24),
                  Text(
                  "Selamat Datang, ${widget.user['name'] ?? 'Penduduk Lohbener'}!\nSilakan pilih kebutuhan dokumen anda",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                  const SizedBox(height: 24),
                  _buildMenuButtons(context),
                ],
              ),
            ),
          ),

          // 🔹 Header logo dan tombol drawer
          Positioned(
            top: -25,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, size: 40, color: Colors.white),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                // ⬇️ Logo dengan posisi rapi tanpa padding negatif
                Transform.translate(
                  offset: const Offset(23, 0), // geser dikit ke kanan dan naik tipis
                  child: Image.asset(
                    "assets/images/logo.png",
                    width: 190,
                    height: 190,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Drawer user
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      width: MediaQuery.of(context).size.width * 0.7,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: widget.user['foto'] != null
                        ? NetworkImage("http://10.0.2.2:8000/storage/${widget.user['foto']}")
                        : const AssetImage("assets/images/profile.jpg") as ImageProvider,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.user['name'] ?? 'Pengguna',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(widget.user['nik'] ?? 'NIK tidak ada',
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => IndexPage(user: widget.user)));
                    },
                    child: const Text(
                      "Lihat Akun",
                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: [
                  const ListTile(leading: Icon(Icons.headset_mic), title: Text("Layanan Pengguna")),
                  ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text("Riwayat Pengajuan"),
                  onTap: () {
                    Navigator.pop(context); // tutup drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RiwayatPengajuanPage(),
                      ),
                    );
                  },
                ),
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text("Notifikasi"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => const NotifikasiPage()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.article),
                    title: const Text("Berita"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => const BerandaBerita()));
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Keluar"),
              onTap: () => Navigator.pushReplacementNamed(context, '/masuk'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarousel() {
    if (loading) {
      return const SizedBox(
        height: 250,
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_newsItems.isEmpty) {
      return const SizedBox(
        height: 250,
        child: Center(
            child: Text("Belum ada berita",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500))),
      );
    }

    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          bottom: BorderSide(color: Color(0xFF0077B6), width: 2),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 3))
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _newsItems.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final berita = _newsItems[index];
              final fotoUrl =
                  berita['foto'] ?? "https://via.placeholder.com/400x200.png?text=No+Image";
              return _carouselItem(
                  berita['judul'] ?? '-', berita['tanggal'] ?? '-', fotoUrl, berita['id']);
            },
          ),
          Positioned(
            bottom: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _newsItems.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 12 : 8,
                  height: _currentPage == i ? 12 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? const Color(0xFF0077B6)
                        : Colors.grey.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Item di carousel
  Widget _carouselItem(String title, String date, String image, int id) {
    return GestureDetector(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => DetailBerita(id: id))),
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withOpacity(0.6), Colors.transparent],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(12, 20, 12, 70),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(date,
                        style:
                            const TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0077B6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => DetailBerita(id: id)));
                },
                child: const Text("Baca", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Tombol menu pengajuan
  Widget _buildMenuButtons(BuildContext context) {
    return Column(
      children: [
        _menuButton("Pengajuan KTP", "pengajuan_ktp.png",
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const BerandaPengajuanKTP()))),
        const SizedBox(height: 16),
        _menuButton("Pengajuan KIA", "pengajuan_kia.png",
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const BerandaPengajuanKIA()))),
        const SizedBox(height: 16),
        _menuButton("Pengajuan KK", "pengajuan_kk.png",
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const BerandaPengajuanKK()))),
      ],
    );
  }

  Widget _menuButton(String text, String imageName, {VoidCallback? onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 150,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0077B6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 3,
          padding: EdgeInsets.zero,
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child:
                  Image.asset("assets/images/$imageName", width: 90, height: 90, fit: BoxFit.contain),
            ),
            Expanded(
              child: Center(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
