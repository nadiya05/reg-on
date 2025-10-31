import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reg_on/Layouts/BaseLayouts2.dart';
import 'package:reg_on/pages/PengajuanKTP/resume_ktp.dart';
import 'package:reg_on/PengajuanKK/resume_kk.dart';
import 'package:reg_on/PengajuanKIA/resume_kia.dart';

class RiwayatPengajuanPage extends StatefulWidget {
  const RiwayatPengajuanPage({super.key});

  @override
  State<RiwayatPengajuanPage> createState() => _RiwayatPengajuanPageState();
}

class _RiwayatPengajuanPageState extends State<RiwayatPengajuanPage> {
  bool _isLoading = true;
  List<dynamic> _riwayat = [];

  @override
  void initState() {
    super.initState();
    fetchRiwayat();
  }

  Future<void> fetchRiwayat() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }

    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/status_pengajuan_all'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'] ?? [];

        setState(() {
          _riwayat = data;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat riwayat (${response.statusCode})')),
        );
      }
    } catch (e) {
      print("❌ Error: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Gagal memuat data: $e")));
      setState(() => _isLoading = false);
    }
  }

  Widget _buildItem(dynamic item) {
    final tanggal = item['tanggal_pengajuan'] ?? '-';
    final status = item['status'] ?? 'Sedang diproses';
    final jenis = (item['jenis_pengajuan'] ?? '').toUpperCase(); // contoh: KTP / KK / KIA
    final detailJenis = item['jenis_detail'] ?? '-'; // contoh: Pemula, Penggantian, Baru

    // Tentukan halaman resume berdasar jenis dokumen
    void _openResume() {
      final id = item['id'];
      if (jenis == "KTP") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ResumeKtpPage(id: id)),
        );
      } else if (jenis == "KK") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ResumeKkPage(id: id)),
        );
      } else if (jenis == "KIA") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ResumeKiaPage(id: id)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Resume tidak tersedia untuk jenis ini")),
        );
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "[$tanggal] Pengajuan $jenis - $detailJenis",
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            "Status: $status",
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _openResume,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0077B6),
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Lihat Resume",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayouts2(
      title: "Riwayat Pengajuan",
      showBack: true,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _riwayat.isEmpty
              ? const Center(child: Text("Belum ada pengajuan"))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _riwayat.length,
                  itemBuilder: (context, index) => _buildItem(_riwayat[index]),
                ),
    );
  }
}
