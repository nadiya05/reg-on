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
  bool _isLoading = true;
  List<dynamic> _notifikasi = [];
  final TextEditingController _searchController = TextEditingController();
  String? _token;

  @override
  void initState() {
    super.initState();
    fetchNotifikasi();
  }

  Future<void> fetchNotifikasi({String? query}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    setState(() => _token = token);

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan login terlebih dahulu")),
      );
      return;
    }

    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // 🔍 URL dinamis kalau pakai search
    final url = query == null || query.isEmpty
        ? 'http://10.0.2.2:8000/api/notifikasi'
        : 'http://10.0.2.2:8000/api/notifikasi?search=$query';

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        setState(() {
          _notifikasi = body['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat notifikasi (${response.statusCode})')),
        );
      }
    } catch (e) {
      print("❌ Error: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Gagal memuat data: $e")));
      setState(() => _isLoading = false);
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
      fetchNotifikasi();
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
      fetchNotifikasi();
    } catch (e) {
      print("❌ Gagal hapus notifikasi: $e");
    }
  }

  void showDetailDialog(Map<String, dynamic> n) async {
    await tandaiDibaca(n['id']);
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

  Widget _buildItem(dynamic n) {
    final tanggal = n['tanggal'] ?? '-';
    final jenis = n['tipe_pengajuan'] ?? '-';
    final status = n['status'] ?? 'belum dibaca';
    final nama = n['nama_pengajuan'] ?? '-';

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
      onTap: () => showDetailDialog(n),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: status == 'dibaca' ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(12),
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
                      color: status == 'dibaca' ? Colors.grey : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  Text("Nama Pengaju: $nama"),
                  const SizedBox(height: 6),
                  Text(n['pesan'] ?? ''),
                  const SizedBox(height: 8),
                  Text(
                    "Tanggal: $tanggal",
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
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
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayouts2(
      title: "Notifikasi",
      showBack: true,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText:
                      "Cari berdasarkan judul, pesan, atau tipe dokumen...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) => fetchNotifikasi(query: value),
              ),
            ),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notifikasi.isEmpty
                    ? const Center(child: Text("Belum ada notifikasi"))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _notifikasi.length,
                        itemBuilder: (context, index) =>
                            _buildItem(_notifikasi[index]),
                      ),
          ],
        ),
      ),
    );
  }
}
