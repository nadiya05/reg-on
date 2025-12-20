import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:reg_on/Layouts/BaseLayouts2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reg_on/pages/PengajuanKTP/resume_ktp.dart';

class FormKehilangan extends StatefulWidget {
  const FormKehilangan({super.key});

  @override
  State<FormKehilangan> createState() => _FormKehilanganState();
}

class _FormKehilanganState extends State<FormKehilangan> {
  final _formKey = GlobalKey<FormState>();
  final nikController = TextEditingController();
  final namaController = TextEditingController();
  final tanggalController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? kkFile;
  File? suratKehilanganFile;
  bool _isLoading = false;

  // ✅ COPY FILE KE DIRECTORY AMAN
  Future<File> _copyToLocal(File file) async {
    final dir = await getApplicationDocumentsDirectory();
    final newPath = path.join(dir.path, path.basename(file.path));
    return file.copy(newPath);
  }

  // ✅ PICK IMAGE (ANTI ERROR CACHE)
  Future<void> pickImage(String type) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final copiedFile = await _copyToLocal(File(picked.path));
      setState(() {
        if (type == 'kk') kkFile = copiedFile;
        if (type == 'surat') suratKehilanganFile = copiedFile;
      });
    }
  }

  // ✅ SUBMIT FORM (SAMA SEPERTI PEMULA)
  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (kkFile == null || suratKehilanganFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('KK dan Surat Kehilangan wajib diisi')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token tidak ditemukan, silakan login ulang')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.0.2.2:8000/api/pengajuan_ktp/kehilangan'),
      );

      request.fields.addAll({
        'jenis_ktp': 'Kehilangan',
        'nik': nikController.text,
        'nama': namaController.text,
        'tanggal_pengajuan': tanggalController.text,
      });

      request.files.add(
        await http.MultipartFile.fromPath('kk', kkFile!.path),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'surat_kehilangan',
          suratKehilanganFile!.path,
        ),
      );

      request.headers.addAll({
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      });

      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      final data = jsonDecode(respStr);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final int? pengajuanId =
            data['data']?['id'] ?? data['id'];

        if (pengajuanId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal mendapatkan ID pengajuan')),
          );
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil submit')),
        );

        // ✅ KE RESUME (SAMA DENGAN PEMULA)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResumeKtpPage(id: pengajuanId),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Gagal submit data')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  InputDecoration fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Color(0xFF0077B6)),
      ),
    );
  }

  Widget filePicker(String label, File? file, String type) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () => pickImage(type),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0077B6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(label, style: const TextStyle(color: Colors.white)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            file != null ? path.basename(file.path) : 'Belum ada',
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget submitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0077B6),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: _isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text('KIRIM', style: TextStyle(color: Colors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayouts2(
      title: 'Form KTP Kehilangan',
      showBack: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: nikController,
              decoration: fieldDecoration('NIK'),
              validator: (v) => v!.isEmpty ? 'NIK wajib diisi' : null,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: namaController,
              decoration: fieldDecoration('Nama'),
              validator: (v) => v!.isEmpty ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: tanggalController,
              decoration: fieldDecoration('Tanggal Pengajuan'),
              readOnly: true,
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  tanggalController.text =
                      picked.toIso8601String().split('T')[0];
                }
              },
              validator: (v) =>
                  v!.isEmpty ? 'Tanggal wajib diisi' : null,
            ),
            const SizedBox(height: 20),
            filePicker('Upload KK', kkFile, 'kk'),
            const SizedBox(height: 10),
            filePicker('Upload Surat Kehilangan', suratKehilanganFile, 'surat'),
            const SizedBox(height: 30),
            submitButton(),
          ],
        ),
      ),
    );
  }
}
