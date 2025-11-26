import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:reg_on/Layouts/BaseLayouts1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reg_on/pages/PengajuanKTP/resume_ktp.dart';

class StatusKtpPage extends StatefulWidget {
  const StatusKtpPage({super.key});

  @override
  State<StatusKtpPage> createState() => _StatusKtpPageState();
}

class _StatusKtpPageState extends State<StatusKtpPage> with RouteAware {
  List<dynamic> statusList = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchStatusData();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final dynamic userId = prefs.get('user_id');
    if (userId is int) return userId;
    if (userId is String) return int.tryParse(userId);
    return null;
  }

  /// 🔍 Fungsi fetch dengan optional parameter search
  Future<void> fetchStatusData({String? searchQuery}) async {
    final token = await getToken();
    final userId = await getUserId();

    if (token == null || userId == null) {
      debugPrint("⚠️ Token atau user_id tidak ditemukan, silakan login ulang.");
      setState(() => isLoading = false);
      return;
    }

    // ✅ PERBAIKAN: gunakan ? untuk query pertama, bukan &
    final baseUrl = 'http://10.0.2.2:8000/api/status_pengajuan_ktp';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final url = Uri.parse(
      searchQuery != null && searchQuery.isNotEmpty
          ? '$baseUrl?search=$searchQuery&t=$timestamp'
          : '$baseUrl?t=$timestamp',
    );

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
      debugPrint('❌ Error fetch status: $e');
      setState(() => isLoading = false);
    }
  }

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
      title: 'Status',
      child: SingleChildScrollView(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // 🔍 Kolom pencarian
      Padding(
        padding: const EdgeInsets.all(12.0),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Cari NIK, nama, atau status...",
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) async {
            await fetchStatusData(searchQuery: value);
          },
        ),
      ),

      // 🔹 Konten utama
      if (isLoading)
        const Center(
          child: CircularProgressIndicator(color: Colors.white),
        )
      else if (statusList.isEmpty)
        const Center(
          child: Text(
            "Belum ada pengajuan.",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        )
      else
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: statusList.length,
          itemBuilder: (context, index) {
            final item = statusList[index];
            final status = item['status'] ?? 'sedang diproses';
            final statusColor = getStatusColor(status);
            final statusLabel = getStatusLabel(status);
            final String? keterangan = item['keterangan'];

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
                  // 🔹 Info pengajuan
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
                        Text(item['nama'] ?? '-', overflow: TextOverflow.ellipsis),
                        Text(
                          "Pengajuan ${item['jenis_ktp'] ?? '-'}",
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),

                        // 🔹 Status (klik kalau Ditolak)
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            if (status.toLowerCase() == 'ditolak') {
                              await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    title: const Text(
                                      'Pengajuan Ditolak',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    content: Text(
                                      keterangan?.isNotEmpty == true
                                          ? keterangan!
                                          : 'Pengajuan Anda ditolak oleh admin tanpa keterangan.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context),
                                        child: const Text('Tutup'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          child: Container(
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
                        ),

                        if (status.toLowerCase() == 'ditolak' &&
                            keterangan != null &&
                            keterangan.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            "Keterangan: $keterangan",
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  // 🔹 Tombol Resume
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
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResumeKtpPage(id: id),
                        ),
                      );
                      await fetchStatusData();
                    },
                    child: const Text('Resume'),
                  ),
                ],
              ),
            );
          },
        ),
    ],
  ),
),
    );
  }
}
