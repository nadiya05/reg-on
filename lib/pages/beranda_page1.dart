import 'package:flutter/material.dart';

class BerandaPage1 extends StatefulWidget {
  const BerandaPage1({super.key});

  @override
  State<BerandaPage1> createState() => _BerandaPage1State();
}

class _BerandaPage1State extends State<BerandaPage1> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _newsItems = [
    {
      "title": "Kecamatan Lohbener",
      "date": "15 September 2025",
      "image": "assets/images/bundaran mangga.jpeg"
    },
    {
      "title": "Berita Kedua",
      "date": "16 September 2025",
      "image": "assets/images/bundaran mangga.jpeg"
    },
    {
      "title": "Berita Ketiga",
      "date": "17 September 2025",
      "image": "assets/images/bundaran mangga.jpeg"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Custom Drawer (sidebar)
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.7,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profil user
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage("assets/images/profile.jpg"),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Ikanurjannah",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "lihat akun",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Menu
              Expanded(
                child: ListView(
                  children: const [
                    ListTile(
                      leading: Icon(Icons.headset_mic),
                      title: Text("Layanan Pengguna"),
                    ),
                    ListTile(
                      leading: Icon(Icons.history),
                      title: Text("Riwayat Pengajuan"),
                    ),
                    ListTile(
                      leading: Icon(Icons.notifications),
                      title: Text("Notifikasi"),
                    ),
                    ListTile(
                      leading: Icon(Icons.article),
                      title: Text("Berita"),
                    ),
                    ListTile(
                      leading: Icon(Icons.phone),
                      title: Text("Hubungi Admin"),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Logout
              ListTile(
                leading: Icon(Icons.logout, color: Colors.grey),
                title: Text("Keluar"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),

      body: Stack(
        children: [
          // Background biru
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 320,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(0, 119, 182, 1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
            ),
          ),

          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 120),

                  // Carousel
                  _buildCarousel(),

                  const SizedBox(height: 24),

                  // Sambutan
                  const Text(
                    "Selamat Datang Penduduk Lohbener!\nsilahkan pilih kebutuhan dokumen anda",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 24),

                  // Tombol menu
                  Column(
                    children: [
                      _menuButton(context, "Pengajuan KTP", "pengajuan_ktp.png"),
                      const SizedBox(height: 16),
                      _menuButton(context, "Pengajuan KIA", "pengajuan_kia.png",
                          imageRight: true),
                      const SizedBox(height: 16),
                      _menuButton(context, "Pengajuan KK", "pengajuan_kk.png"),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Header menu + logo
          Positioned(
            top: 15,
            left: 0,
            right: -60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tombol menu (buka drawer)
                Builder(
                  builder: (context) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: IconButton(
                        icon: const Icon(Icons.menu,
                            size: 40, color: Colors.white),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      ),
                    );
                  },
                ),
                // Logo kanan
                Padding(
                  padding: const EdgeInsets.only(right: 25),
                  child: Image.asset(
                    "assets/images/logo.png",
                    height: 120,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          bottom: BorderSide(
            color: Color.fromRGBO(0, 119, 182, 1),
            width: 2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _newsItems.length,
            itemBuilder: (context, index) {
              final item = _newsItems[index];
              return _carouselItem(
                item["title"]!,
                item["date"]!,
                item["image"]!,
              );
            },
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _newsItems.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 12 : 8,
                  height: _currentPage == index ? 12 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? const Color.fromRGBO(0, 119, 182, 1)
                        : Colors.grey,
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

  Widget _carouselItem(String title, String date, String image) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.6),
              Colors.transparent,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 20, 12, 70),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(0, 119, 182, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: () {},
                child: const Text(
                  "Baca",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuButton(BuildContext context, String text, String imageName,
      {bool imageRight = false}) {
    return SizedBox(
      width: double.infinity,
      height: 150,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(0, 119, 182, 1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 3,
          padding: EdgeInsets.zero,
        ),
        onPressed: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: imageRight
              ? [
                  Expanded(
                    child: Center(
                      child: Text(
                        text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Image.asset(
                      "assets/images/$imageName",
                      width: 90,
                      height: 90,
                      fit: BoxFit.contain,
                    ),
                  ),
                ]
              : [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Image.asset(
                      "assets/images/$imageName",
                      width: 90,
                      height: 90,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
        ),
      ),
    );
  }
}
