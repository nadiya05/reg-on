import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reg_on/PengajuanKIA/beranda_pengajuan_kia.dart';
import 'package:reg_on/PengajuanKK/informasi_kk.dart';
import 'package:reg_on/pages/PengajuanKTP/form_kehilangan.dart';
import 'package:reg_on/pages/PengajuanKTP/form_pemula.dart';
import 'package:reg_on/pages/PengajuanKTP/form_rusak_ubah_status.dart';
import 'package:reg_on/pages/PengajuanKTP/status_pengajuan_ktp.dart';
import 'package:reg_on/PengajuanKIA/status_pengajuan_kia.dart';

// Landing pages
import 'pages/landing_page1.dart';
import 'pages/landing_page2.dart';
import 'pages/landing_page3.dart';

// Auth
import 'pages/masuk_page.dart';
import 'pages/daftar_page.dart'; 

// Beranda & Akun
import 'pages/beranda_page1.dart'; 
import 'pages/akun/index.dart'; 
import 'pages/akun/edit.dart'; 

// Pengajuan KTP
import 'pages/PengajuanKTP/beranda_pengajuan_ktp.dart';
import 'pages/PengajuanKTP/informasi_ktp.dart';
import 'pages/PengajuanKTP/pengajuan_ktp.dart';
import 'pages/PengajuanKTP/form_pemula.dart';
import 'pages/PengajuanKTP/form_kehilangan.dart';
import 'pages/PengajuanKTP/form_rusak_ubah_status.dart';
import 'pages/PengajuanKTP/status_pengajuan_ktp.dart';

// KIA
import 'PengajuanKIA/beranda_pengajuan_kia.dart';
import 'PengajuanKIA/informasi_kia.dart';
import 'PengajuanKIA/form_pemula.dart';

// KK
import 'PengajuanKK/beranda_pengajuan_kk.dart';
import 'PengajuanKK/informasi_kk.dart';
import 'PengajuanKK/form_pemula.dart';
import 'PengajuanKK/form_ubah_status.dart';
import 'PengajuanKK/pengajuan_kk.dart';
import 'PengajuanKK/status_pengajuan_kk.dart';

// Resume
import 'package:reg_on/pages/PengajuanKTP/resume_ktp.dart';
import 'package:reg_on/PengajuanKK/resume_kk.dart';
import 'package:reg_on/PengajuanKIA/resume_kia.dart';

// berita
import 'berita/beranda_berita.dart';
import 'berita/detail_berita.dart';

// riwayat pengajuan
import 'riwayat_pengajuan.dart';

//notifikasi
import 'notifikasi/notifikasi_page.dart';

//chat
import 'chat/landing_page.dart';
import 'pages/ChatPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reg-On',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const LandingScreen(),
      routes: {
        '/masuk': (context) => const MasukPage(),
        '/daftar': (context) => const DaftarPage(), 
        '/pengajuanKTP': (context) => const BerandaPengajuanKTP(),
        '/informasiKTP': (context) => const InformasiKTP(),
        '/pengajuan_ktp': (context) => const PengajuanBeranda(),
        '/pengajuan_ktp/pemula': (context) => const FormPemula(),
        '/pengajuan_ktp/kehilangan': (context) => const FormKehilangan(),
        '/pengajuan_ktp/rusak': (context) => const FormRusakUbahStatus(),
        '/status_pengajuan_ktp': (context) => const StatusKtpPage(),
        '/pengajuanKIA': (context) => const BerandaPengajuanKIA(),
        '/informasiKIA': (context) => const InformasiKIA(),
        '/pengajuan-kia/pemula': (context) => const FormKIA(),
        '/status_pengajuan_kia': (context) => const StatusPengajuanKiaPage(),
        '/pengajuan-kk': (context) => const PengajuanKKBeranda(),
        '/pengajuanKK': (context) => const BerandaPengajuanKK(),
        '/informasiKK': (context) => const InformasiKK(),
        '/pengajuan-kk/pemula': (context) => const FormPemulaKK(),
        '/pengajuan-kk/ubah-status': (context) => const FormUbahStatusKK(),
        '/status_pengajuan_kk': (context) => const StatusKkPage(),
        '/status_pengajuan_all': (context) => const RiwayatPengajuanPage(),
        '/notifikasi': (context) => const NotifikasiPage(),
        '/landing_page': (context) => const LandingPageChat(),
        '/chatRoom': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

        return ChatPage(
        userId: args['userId'],
        token: args['token'],
        userAvatarUrl: args['userAvatarUrl'],
        adminAvatarUrl: args['adminAvatarUrl'],
        userName: args['userName'] ?? 'User',
        adminName: args['adminName'] ?? 'Admin',
      );

      },
        // 🔹 Tambahan route berita
        '/berita': (context) => const BerandaBerita(),
      },

      // 🔹 Route dinamis (resume & detail berita)
      onGenerateRoute: (settings) {
        if (settings.name == '/resume') {
          final args = settings.arguments;

          if (args is Map<String, dynamic>) {
            final String jenis = args['jenis']?.toLowerCase() ?? '';
            final int id = args['id'] ?? 0;

            switch (jenis) {
              case 'ktp':
                return MaterialPageRoute(
                  builder: (context) => ResumeKtpPage(id: id),
                );
              case 'kk':
                return MaterialPageRoute(
                  builder: (context) => ResumeKkPage(id: id),
                );
              case 'kia':
                return MaterialPageRoute(
                  builder: (context) => ResumeKiaPage(id: id),
                );
              default:
                return _errorPage('Jenis resume tidak dikenali');
            }
          } else {
            return _errorPage('Data pengajuan tidak valid');
          }
        }

        // 🔹 Detail berita (pakai argumen id)
        if (settings.name == '/detail_berita') {
          final id = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => DetailBerita(id: id),
          );
        }

        // fallback route
        return _errorPage('Halaman tidak ditemukan');
      },
    );
  }

  // 🔹 Helper error page
  static MaterialPageRoute _errorPage(String msg) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        body: Center(child: Text(msg)),
      ),
    );
  }
}

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 🔹 Swipe
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              children: const [
                LandingPage1(),
                LandingPage2(),
                LandingPage3(),
              ],
            ),
          ),

          // 🔹 Indikator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Container(
                margin: const EdgeInsets.all(4),
                width: _currentIndex == index ? 12 : 8,
                height: _currentIndex == index ? 12 : 8,
                decoration: BoxDecoration(
                  color: _currentIndex == index
                      ? const Color(0xFF0077B6)
                      : Colors.grey,
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          // 🔹 Tombol
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: const Color(0xFF0077B6),
              ),
              onPressed: () {
                if (_currentIndex == 2) {
                  Navigator.pushReplacementNamed(context, '/masuk');
                } else {
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: Text(
                _currentIndex == 2 ? "Mulai Sekarang" : "Ketuk untuk lanjut",
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}