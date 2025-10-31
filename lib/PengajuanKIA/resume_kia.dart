import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reg_on/Layouts/BaseLayouts2.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ResumeKiaPage extends StatefulWidget {
  final int id;
  const ResumeKiaPage({super.key, required this.id});

  @override
  State<ResumeKiaPage> createState() => _ResumeKiaPageState();
}

class _ResumeKiaPageState extends State<ResumeKiaPage> {
  Map<String, dynamic>? data;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchResume();
  }

  Future<void> fetchResume() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }

    try {
      final res = await http.get(
        Uri.parse("http://10.0.2.2:8000/api/pengajuan_kia/${widget.id}"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        setState(() {
          data = json['data'];
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      print("Error: $e");
      setState(() => loading = false);
    }
  }

  Widget _buildInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.poppins(color: Colors.black, fontSize: 15),
          children: [
            TextSpan(
              text: "$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  pw.Widget _pdfInfo(String label, String value, pw.Font font, pw.Font fontBold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.RichText(
        text: pw.TextSpan(
          style: pw.TextStyle(font: font, fontSize: 13),
          children: [
            pw.TextSpan(
              text: "$label: ",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: fontBold),
            ),
            pw.TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Future<void> generatePdf() async {
    if (data == null) return;

    final pdf = pw.Document();
    final font = await PdfGoogleFonts.poppinsRegular();
    final fontBold = await PdfGoogleFonts.poppinsBold();
    final logo = await imageFromAssetBundle('assets/images/logo.png');
    final primaryColor = PdfColor.fromInt(0xFF0077B6);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex("#F5FAFF"),
              border: pw.Border.all(color: primaryColor, width: 3),
              borderRadius: pw.BorderRadius.circular(20),
            ),
            padding: const pw.EdgeInsets.all(30),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "Resume Pendaftaran Antrean KIA",
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 22,
                        color: primaryColor,
                      ),
                    ),
                    pw.Container(
                      width: 60,
                      height: 60,
                      child: pw.Image(logo),
                    ),
                  ],
                ),
                pw.SizedBox(height: 25),
                _pdfInfo("Nomor Antrean", data?['nomor_antrean'] ?? '-', font, fontBold),
                _pdfInfo("NIK", data?['nik'] ?? '-', font, fontBold),
                _pdfInfo("Nama", data?['nama'] ?? '-', font, fontBold),
                _pdfInfo("Email", data?['email'] ?? '-', font, fontBold),
                _pdfInfo("No Telepon", data?['no_telp'] ?? '-', font, fontBold),
                _pdfInfo("Jenis KIA", data?['jenis_kia'] ?? '-', font, fontBold),
                _pdfInfo("Tanggal Pengajuan", data?['tanggal_pengajuan'] ?? '-', font, fontBold),
                pw.SizedBox(height: 25),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayouts2(
      title: "Resume KIA",
      showBack: true,
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : data == null
              ? const Center(child: Text("Data tidak ditemukan"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black26),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfo("Nomor Antrean", data?['nomor_antrean'] ?? '-'),
                            _buildInfo("NIK", data?['nik'] ?? '-'),
                            _buildInfo("Nama", data?['nama'] ?? '-'),
                            _buildInfo("Email", data?['email'] ?? '-'),
                            _buildInfo("Nomor Telepon", data?['no_telp'] ?? '-'),
                            _buildInfo("Jenis KIA", data?['jenis_kia'] ?? '-'),
                            _buildInfo("Tanggal Pengajuan", data?['tanggal_pengajuan'] ?? '-'),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      Center(
                        child: ElevatedButton(
                          onPressed: generatePdf,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0077B6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 40),
                          ),
                          child: Text(
                            "Cetak",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
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
