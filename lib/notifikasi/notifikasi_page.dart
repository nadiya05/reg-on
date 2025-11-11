import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reg_on/Layouts/BaseLayouts2.dart';

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  List<dynamic> _notifikasi = [];
  bool _loading = true;
  String? _token;

  Future<void> getNotifikasi() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    setState(() => _token = token);

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Token tidak ditemukan")),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/notifikasi'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        setState(() {
          _notifikasi = data['data'];
          _loading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Gagal memuat notifikasi')),
        );
      }
    } catch (e) {
      print("❌ Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengambil notifikasi: $e")),
      );
    }
  }

  Future<void> tandaiDibaca(int id) async {
    if (_token == null) return;
    try {
      await http.put(
        Uri.parse('http://10.0.2.2:8000/api/notifikasi/$id/baca'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $_token",
        },
      );
      getNotifikasi(); // refresh
    } catch (e) {
      print("❌ Gagal tandai dibaca: $e");
    }
  }

  Future<void> hapusNotifikasi(int id) async {
    if (_token == null) return;
    try {
      await http.delete(
        Uri.parse('http://10.0.2.2:8000/api/notifikasi/$id'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $_token",
        },
      );
      getNotifikasi();
    } catch (e) {
      print("❌ Gagal hapus notifikasi: $e");
    }
  }

  // 🌟 popup detail notifikasi
  void showDetailDialog(Map<String, dynamic> n) async {
    await tandaiDibaca(n['id']); // ubah status ke "dibaca" dulu

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          n['judul'] ?? 'Detail Notifikasi',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Jenis Dokumen: ${n['tipe_pengajuan'] ?? '-'}"),
            const SizedBox(height: 4),
            Text("Nama Pengaju: ${n['nama_pengajuan'] ?? '-'}"),
            const SizedBox(height: 12),
            Text(
              n['pesan'] ?? '-',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Text(
              "Tanggal: ${n['tanggal'] ?? '-'}",
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getNotifikasi();
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayouts2(
      title: 'Notifikasi',
      showBack: true,
      child: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _notifikasi.isEmpty
                ? const Center(child: Text("Belum ada notifikasi"))
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _notifikasi.map((n) {
                          final tanggal = n['tanggal']?.toString() ??
                              n['created_at']?.toString().substring(0, 10) ??
                              '-';
                          final jenis = n['tipe_pengajuan'] ?? '-';
                          final nama = n['nama_pengajuan'] ?? '-';
                          final status = n['status'] ?? 'belum dibaca';

                          Color badgeColor;
                          switch (jenis.toLowerCase()) {
                            case 'ktp':
                              badgeColor = Colors.blue;
                              break;
                            case 'kk':
                              badgeColor = Colors.green;
                              break;
                            case 'kia':
                              badgeColor = Colors.orange;
                              break;
                            default:
                              badgeColor = Colors.grey;
                          }

                          return GestureDetector(
                            onTap: () => showDetailDialog(n), // 👈 popup muncul di sini
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: status == 'dibaca'
                                    ? Colors.grey.shade100
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          n['judul'] ?? '',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: status == 'dibaca'
                                                ? Colors.grey
                                                : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: badgeColor.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            jenis.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: badgeColor,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          "Nama Pengaju: $nama",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          n['pesan'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Tanggal: $tanggal",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => hapusNotifikasi(n['id']),
                                    icon: const Icon(Icons.delete, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
      ),
    );
  }
}
