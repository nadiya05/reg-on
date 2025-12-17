import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:reg_on/Layouts/BaseLayouts1.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InformasiKK extends StatefulWidget {
  const InformasiKK({super.key});

  @override
  State<InformasiKK> createState() => _InformasiKKState();
}

class _InformasiKKState extends State<InformasiKK> {
  List<dynamic> informasi = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchInformasi();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchInformasi() async {
  final token = await getToken();
  if (token == null) {
    setState(() => isLoading = false);
    return;
  }

  try {
    final response = await http.get(
      Uri.parse("http://10.0.2.2:8000/api/informasi_kk"),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      setState(() {
        informasi = data['data'] ?? [];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  } catch (e) {
    setState(() => isLoading = false);
  }
}
String formatJenisPengajuan(String value) {
  return value
      .split('_')
      .map((word) {
        if (word.toLowerCase() == 'kk') {
          return 'KK';
        }
        return word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : word;
      })
      .join(' ');
}

  Widget buildCard(
      String title, String jenisDokumen, List<String> deskripsiList) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 50, left: 15, right: 15),
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
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
      title: "Informasi KK",
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : informasi.isEmpty
              ? const Center(
                  child: Text("Tidak ada informasi untuk pengajuan KK."),
                )
              : ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  children: [
                    for (var item in informasi)
                      buildCard(
                        formatJenisPengajuan(item['jenis_pengajuan'] ?? "-"),
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
