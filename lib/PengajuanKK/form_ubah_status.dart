import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reg_on/Layouts/BaseLayouts2.dart';
import 'package:reg_on/PengajuanKK/resume_kk.dart';

class FormUbahStatusKK extends StatefulWidget {
  const FormUbahStatusKK({super.key});

  @override
  State<FormUbahStatusKK> createState() => _FormUbahStatusKKState();
}

class _FormUbahStatusKKState extends State<FormUbahStatusKK> {
  final _formKey = GlobalKey<FormState>();
  final nikController = TextEditingController();
  final namaController = TextEditingController();
  final tanggalController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? kkAsliFile;
  File? suratNikahFile;
  File? suratKematianFile;
  File? suratPindahFile;

  bool _isLoading = false;

  Future<void> pickImage(String type) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        switch (type) {
          case 'kk_asli':
            kkAsliFile = File(pickedFile.path);
            break;
          case 'nikah':
            suratNikahFile = File(pickedFile.path);
            break;
          case 'kematian':
            suratKematianFile = File(pickedFile.path);
            break;
          case 'pindah':
            suratPindahFile = File(pickedFile.path);
            break;
        }
      });
    }
  }

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (kkAsliFile == null ||
        suratNikahFile == null ||
        suratKematianFile == null ||
        suratPindahFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua dokumen wajib diunggah')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token tidak ditemukan, silakan login dulu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.0.2.2:8000/api/pengajuan-kk/ubah-status'),
      );

      request.fields.addAll({
        'jenis_kk': 'Ubah Status',
        'nik': nikController.text,
        'nama': namaController.text,
        'tanggal_pengajuan': tanggalController.text,
      });

      // Upload dokumen wajib
      request.files.add(await http.MultipartFile.fromPath(
        'kk_asli',
        kkAsliFile!.path,
        contentType: MediaType('image', 'jpeg'),
      ));
      request.files.add(await http.MultipartFile.fromPath(
        'surat_nikah',
        suratNikahFile!.path,
        contentType: MediaType('image', 'jpeg'),
      ));
      request.files.add(await http.MultipartFile.fromPath(
        'surat_kematian',
        suratKematianFile!.path,
        contentType: MediaType('image', 'jpeg'),
      ));
      request.files.add(await http.MultipartFile.fromPath(
        'surat_keterangan_pindah',
        suratPindahFile!.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      request.headers.addAll({
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      });

      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      print('Response: $respStr');

      final responseData = jsonDecode(respStr);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final int? pengajuanId = responseData['data']?['id'];

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil submit pengajuan KK Ubah Status')),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResumeKkPage(
              id: pengajuanId!,
            ),
          ),
        );
      } else {
        final errorMsg = responseData['message'] ?? 'Gagal submit data';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    } catch (e) {
      print('❌ Error submitForm: $e');
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
            file != null ? path.basename(file.path) : 'Belum ada file',
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: _isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text('KIRIM', style: TextStyle(fontSize: 16, color: Colors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayouts2(
      title: 'Form KK Ubah Status',
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
              decoration: fieldDecoration('Nama Lengkap'),
              validator: (v) => v!.isEmpty ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: tanggalController,
              decoration: fieldDecoration('Tanggal Pengajuan'),
              readOnly: true,
              onTap: () async {
                FocusScope.of(context).unfocus();
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
              validator: (v) => v!.isEmpty ? 'Tanggal wajib diisi' : null,
            ),
            const SizedBox(height: 20),
            filePicker('Upload KK Asli', kkAsliFile, 'kk_asli'),
            const SizedBox(height: 10),
            filePicker('Upload Surat Nikah', suratNikahFile, 'nikah'),
            const SizedBox(height: 10),
            filePicker('Upload Surat Kematian', suratKematianFile, 'kematian'),
            const SizedBox(height: 10),
            filePicker('Upload Surat Keterangan Pindah', suratPindahFile, 'pindah'),
            const SizedBox(height: 30),
            submitButton(),
          ],
        ),
      ),
    );
  }
}
