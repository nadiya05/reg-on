import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:reg_on/Layouts/BaseLayouts1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reg_on/PengajuanKK/resume_kk.dart';

class StatusKkPage extends StatefulWidget {
  const StatusKkPage({super.key});

  @override
  State<StatusKkPage> createState() => _StatusKkPageState();
}

class _StatusKkPageState extends State<StatusKkPage> with RouteAware {
  List<dynamic> statusList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStatusData();
  }

  /// 🔹 Ambil token dari SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// 🔹 Ambil user_id dari SharedPreferences
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final dynamic userId = prefs.get('user_id');
    if (userId is int) return userId;
    if (userId is String) return int.tryParse(userId);
    return null;
  }

  /// 🔹 Fetch data status pengajuan KK dari Laravel API
  Future<void> fetchStatusData() async {
    final token = await getToken();
    final userId = await getUserId();

    if (token == null || userId == null) {
      debugPrint("⚠️ Token atau user_id tidak ditemukan, silakan login ulang.");
      setState(() => isLoading = false);
      return;
    }

    // Tambahkan query timestamp agar tidak cache
    final url = Uri.parse('http://10.0.2.2:8000/api/status_pengajuan_kk?t=${DateTime.now().millisecondsSinceEpoch}');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Cache-Control': 'no-cache',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          statusList = data is List ? data : (data['data'] ?? []);
          isLoading = false;
        });
      } else {
        debugPrint('❌ Gagal memuat data: ${response.body}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint('❌ Error fetch status KK: $e');
      setState(() => isLoading = false);
    }
  }

  /// 🔹 Warna status
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.amber;
    }
  }

  /// 🔹 Label status
  String getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return 'Selesai';
      case 'ditolak':
        return 'Ditolak';
      default:
        return 'Sedang Diproses';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ModalRoute.of(context)?.addScopedWillPopCallback(() async {
      await fetchStatusData();
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayouts1(
      title: 'Status KK',
      child: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : statusList.isEmpty
              ? const Center(
                  child: Text(
                    "Belum ada pengajuan KK.",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                )
              : Column(
                  children: statusList.map((item) {
                    final status = item['status'] ?? 'sedang diproses';
                    final statusColor = getStatusColor(status);
                    final statusLabel = getStatusLabel(status);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          )
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🔹 Kiri: info pengajuan
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['nik'] ?? '-',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                                Text(item['nama'] ?? '-',
                                    overflow: TextOverflow.ellipsis),
                                Text("Pengajuan ${item['jenis_kk'] ?? '-'}",
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    statusLabel,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 10),

                          // 🔹 Kanan: tombol resume
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0077B6),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              final int id = item['id'];
                              final String jenis = item['jenis_kk'] ?? 'KK';
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ResumeKkPage(id: id),
                                ),
                              );
                              await fetchStatusData();
                            },
                            child: const Text('Resume'),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
    );
  }
}
