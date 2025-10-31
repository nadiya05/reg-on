import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:reg_on/Layouts/BaseLayouts1.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InformasiKTP extends StatefulWidget {
  const InformasiKTP({super.key});

  @override
  State<InformasiKTP> createState() => _InformasiKTPState();
}

class _InformasiKTPState extends State<InformasiKTP> {
  List<dynamic> informasi = [];

  @override
  void initState() {
    super.initState();
    fetchInformasi();
  }

  /// fungsi ambil token dari SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // pastikan key sama dengan waktu login
  }

  Future<void> fetchInformasi() async {
    final token = await getToken();

    if (token == null) {
      print("Token tidak ditemukan, silakan login ulang");
      return;
    }

    final response = await http.get(
      Uri.parse("http://10.0.2.2:8000/api/informasi"),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        informasi = data['data'];
      });
    } else {
      print("Gagal fetch data: ${response.body}");
    }
  }

  Widget buildCard(String title, String jenisDokumen, List<String> deskripsiList) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 50),
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Jenis Dokumen: $jenisDokumen",
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          for (int i = 0; i < deskripsiList.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text("${i + 1}. ${deskripsiList[i]}"),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayouts1(
      title: "Informasi",
      child: informasi.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (var item in informasi)
                  buildCard(
                    item['jenis_pengajuan'] ?? "-",
                    item['jenis_dokumen'] ?? "-",
                    item['deskripsi'] is String
                        ? (item['deskripsi'] as String)
                            .split("\n")
                            .where((e) => e.trim().isNotEmpty)
                            .toList()
                        : List<String>.from(item['deskripsi'] ?? []),
                  ),
              ],
            ),
    );
  }
}