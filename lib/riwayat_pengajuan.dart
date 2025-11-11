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
        setState(() {
          _riwayat = body['data'] ?? [];
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
    final nik = item['nik'] ?? '-';
    final nama = item['nama'] ?? '-';
    final status = item['status'] ?? 'Sedang diproses';
    final jenisDokumen = item['jenis_dokumen'] ?? '-';
    final jenisPengajuan = item['jenis_pengajuan'] ?? '-';
    final tanggal = item['tanggal_pengajuan'] ?? '-';
    final id = item['id'];

    void _openResume() {
      if (jenisDokumen == "KTP") {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ResumeKtpPage(id: id)));
      } else if (jenisDokumen == "KK") {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ResumeKkPage(id: id)));
      } else if (jenisDokumen == "KIA") {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ResumeKiaPage(id: id)));
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
          Text("NIK: $nik", style: const TextStyle(fontWeight: FontWeight.w600)),
          Text("Nama: $nama"),
          Text("Jenis Dokumen: $jenisDokumen"),
          Text("Jenis Pengajuan: $jenisPengajuan"),
          Text("Status: $status"),
          Text("Tanggal Pengajuan: $tanggal"),
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
