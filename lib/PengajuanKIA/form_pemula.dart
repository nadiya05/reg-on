import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import 'package:reg_on/Layouts/BaseLayouts2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

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
  bool _isLoading = false;

  static const Color primaryBlue = Color(0xFF0077B6);

  File? kkFile;
  File? aktaFile;
  File? suratNikahFile;
  File? ktpOrtuFile;
  File? passFotoFile;

  // =========================
  // PICK IMAGE
  // =========================
  Future<void> pickImage(String type) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final ext = path.extension(picked.path);
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_$type$ext';

    final savedFile =
        await File(picked.path).copy('${dir.path}/$fileName');

    setState(() {
      switch (type) {
        case 'kk':
          kkFile = savedFile;
          break;
        case 'akta':
          aktaFile = savedFile;
          break;
        case 'nikah':
          suratNikahFile = savedFile;
          break;
        case 'ktp_ortu':
          ktpOrtuFile = savedFile;
          break;
        case 'foto':
          passFotoFile = savedFile;
          break;
      }
    });
  }

  // =========================
  // ADD FILE
  // =========================
  Future<void> addFile(
    http.MultipartRequest request,
    String key,
    File? file,
  ) async {
    if (file == null) return;

    final bytes = await file.readAsBytes();
    request.files.add(
      http.MultipartFile.fromBytes(
        key,
        bytes,
        filename: path.basename(file.path),
        contentType: MediaType('image', 'jpeg'),
      ),
    );
  }

  // =========================
  // SUBMIT
  // =========================
  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (kkFile == null || aktaFile == null || ktpOrtuFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('KK, Akta Lahir, dan KTP Orang Tua wajib diunggah'),
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token tidak ditemukan')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.0.2.2:8000/api/pengajuan-kia'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields.addAll({
        'jenis_kia': 'Pemula',
        'nik': nikController.text,
        'nama': namaController.text,
        'tanggal_pengajuan': tanggalController.text,
      });

      await addFile(request, 'kk', kkFile);
      await addFile(request, 'akta_lahir', aktaFile);
      await addFile(request, 'surat_nikah', suratNikahFile);
      await addFile(request, 'ktp_ortu', ktpOrtuFile);
      await addFile(request, 'pass_foto', passFotoFile);

      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      final data = jsonDecode(respStr);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil submit')),
        );

        Navigator.pushNamed(
          context,
          '/resume',
          arguments: {
            'id': data['data']?['id'] ?? data['id'],
            'jenis': 'KIA',
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Gagal submit')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // =========================
  // UI HELPERS (SAMA KK)
  // =========================
  InputDecoration fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black87),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.black26),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: primaryBlue),
      ),
    );
  }

  Widget filePicker(String label, File? file, String type) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () => pickImage(type),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              label,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              file != null
                  ? path.basename(file.path)
                  : 'Belum ada file',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget submitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: _isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              'KIRIM',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
    );
  }

  // =========================
  // BUILD
  // =========================
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
            TextFormField(
              controller: tanggalController,
              readOnly: true,
              decoration: fieldDecoration('Tanggal Pengajuan'),
              onTap: () async {
                FocusScope.of(context).unfocus();
                final picked = await showDatePicker(
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
                  v!.isEmpty ? 'Tanggal wajib diisi' : null,
            ),
            const SizedBox(height: 20),
            filePicker('Upload Kartu Keluarga', kkFile, 'kk'),
            filePicker('Upload Akta Lahir', aktaFile, 'akta'),
            filePicker('Upload Surat Nikah', suratNikahFile, 'nikah'),
            filePicker('Upload KTP Orang Tua', ktpOrtuFile, 'ktp_ortu'),
            filePicker('Upload Pas Foto Anak', passFotoFile, 'foto'),
            const SizedBox(height: 30),
            submitButton(),
          ],
        ),
      ),
    );
  }
}
