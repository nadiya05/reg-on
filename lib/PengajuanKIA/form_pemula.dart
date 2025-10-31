import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import 'package:reg_on/Layouts/BaseLayouts2.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormKIA extends StatefulWidget {
  const FormKIA({super.key});

  @override
  State<FormKIA> createState() => _FormKIAState();
}

class _FormKIAState extends State<FormKIA> {
  final _formKey = GlobalKey<FormState>();
  final nikController = TextEditingController();
  final namaController = TextEditingController();
  final tanggalController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? kkFile;
  File? aktaFile;
  File? suratNikahFile;
  File? ktpOrtuFile;
  File? passFotoFile;
  bool _isLoading = false;

  Future<void> pickImage(String type) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        switch (type) {
          case 'kk':
            kkFile = File(pickedFile.path);
            break;
          case 'akta':
            aktaFile = File(pickedFile.path);
            break;
          case 'nikah':
            suratNikahFile = File(pickedFile.path);
            break;
          case 'ktp_ortu':
            ktpOrtuFile = File(pickedFile.path);
            break;
          case 'foto':
            passFotoFile = File(pickedFile.path);
            break;
        }
      });
    }
  }

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (kkFile == null || aktaFile == null || ktpOrtuFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('KK, Akta Lahir, dan KTP Orang Tua wajib diunggah')),
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
        Uri.parse('http://10.0.2.2:8000/api/pengajuan-kia'),
      );

      request.fields.addAll({
        'jenis_kia': 'Pemula',
        'nik': nikController.text,
        'nama': namaController.text,
        'tanggal_pengajuan': tanggalController.text,
      });

      // Upload file
      Future<void> addFile(String key, File? file) async {
        if (file != null) {
          request.files.add(await http.MultipartFile.fromPath(
            key,
            file.path,
            contentType: MediaType('image', 'jpeg'),
          ));
        }
      }

      await addFile('kk', kkFile);
      await addFile('akta_lahir', aktaFile);
      await addFile('surat_nikah', suratNikahFile);
      await addFile('ktp_ortu', ktpOrtuFile);
      await addFile('pass_foto', passFotoFile);

      request.headers.addAll({
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      });

      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      print('📩 Response: $respStr');

      final responseData = jsonDecode(respStr);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final int? pengajuanId =
            responseData['data']?['id'] ?? responseData['id'];

        if (pengajuanId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal mendapatkan ID pengajuan')),
          );
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Berhasil mengajukan KIA')),
        );

        Navigator.pushNamed(
          context,
          '/resume',
          arguments: {'id': pengajuanId, 'jenis': 'KIA'},
        );
      } else {
        final errorMsg = responseData['message'] ?? 'Gagal submit data';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ $errorMsg')),
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
      labelStyle: const TextStyle(color: Colors.black87),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.black26),
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
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
            style: const TextStyle(color: Colors.black87),
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
          : const Text('KIRIM', style: TextStyle(fontSize: 16, color: Colors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayouts2(
      title: 'Form Pengajuan KIA (Pemula)',
      showBack: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: nikController,
              decoration: fieldDecoration('NIK Anak'),
              validator: (v) => v!.isEmpty ? 'NIK wajib diisi' : null,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: namaController,
              decoration: fieldDecoration('Nama Anak'),
              validator: (v) => v!.isEmpty ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 15),

            // 🗓️ Input Tanggal Pengajuan
            TextFormField(
              controller: tanggalController,
              readOnly: true,
              decoration: fieldDecoration('Tanggal Pengajuan'),
              onTap: () async {
                FocusScope.of(context).unfocus();
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  tanggalController.text =
                      picked.toIso8601String().split('T')[0];
                }
              },
              validator: (v) =>
                  v!.isEmpty ? 'Tanggal Pengajuan wajib diisi' : null,
            ),

            const SizedBox(height: 20),
            filePicker('Upload Kartu Keluarga (KK)', kkFile, 'kk'),
            const SizedBox(height: 10),
            filePicker('Upload Akta Lahir', aktaFile, 'akta'),
            const SizedBox(height: 10),
            filePicker('Upload Surat Nikah (Opsional)', suratNikahFile, 'nikah'),
            const SizedBox(height: 10),
            filePicker('Upload KTP Orang Tua', ktpOrtuFile, 'ktp_ortu'),
            const SizedBox(height: 10),
            filePicker('Upload Pas Foto Anak', passFotoFile, 'foto'),
            const SizedBox(height: 30),
            submitButton(),
          ],
        ),
      ),
    );
  }
}
