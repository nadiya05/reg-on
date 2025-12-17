import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:reg_on/Layouts/BaseLayouts2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reg_on/PengajuanKK/resume_kk.dart';

class FormPengajuanKK extends StatefulWidget {
  const FormPengajuanKK({super.key});

  @override
  State<FormPengajuanKK> createState() => _FormPengajuanKKState();
}

class _FormPengajuanKKState extends State<FormPengajuanKK> {
  final _formKey = GlobalKey<FormState>();

  /// ===== CONTROLLER =====
  final nikController = TextEditingController();
  final namaController = TextEditingController();
  final tanggalController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  static const Color primaryBlue = Color(0xFF0077B6);

  String? selectedJenisKk;

  /// ===== FILE STORAGE =====
  final Map<String, File?> files = {
    'formulir_permohonan_kk': null,
    'ijazah': null,
    'surat_nikah': null,
    'akta_cerai': null,
    'surat_kematian': null,
    'akta_kelahiran': null,
    'surat_keterangan_pindah': null,
    'bukti_cek_darah': null,
  };

  /// ===== JENIS KK =====
  final List<Map<String, dynamic>> jenisKkOptions = [
  {
    'value': 'pendidikan',
    'label': 'Pendidikan',
    'fields': ['ijazah'],
  },
  {
    'value': 'status_perkawinan',
    'label': 'Status Perkawinan',
    'fields': ['surat_nikah'],
  },
  {
    'value': 'perceraian',
    'label': 'Perceraian',
    'fields': ['akta_cerai'],
  },
  {
    'value': 'kematian',
    'label': 'Kematian',
    'fields': ['surat_kematian'],
  },
  {
    'value': 'gol_darah',
    'label': 'Golongan Darah',
    'fields': ['bukti_cek_darah'],
  },
  {
    'value': 'penambahan_anggota',
    'label': 'Penambahan Anak / Anggota',
    'fields': ['akta_kelahiran'],
  },
  {
    'value': 'pindahan',
    'label': 'Pindahan',
    'fields': ['surat_keterangan_pindah'],
  },
  {
    'value': 'pisah_kk',
    'label': 'Pisah KK',
    'fields': [],
  },
];

  /// ===== FIELD WAJIB =====
  List<String> get requiredFields {
    final selected = jenisKkOptions.firstWhere(
      (e) => e['value'] == selectedJenisKk,
      orElse: () => {},
    );
    return List<String>.from(selected['fields'] ?? []);
  }

  /// ===== DECORATION (SAMA KAYAK PEMULA) =====
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

  /// ===== PICK IMAGE =====
  Future<void> pickImage(String key) async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked != null) {
      setState(() {
        files[key] = File(picked.path);
      });
    }
  }

  /// ===== DATE PICKER =====
  void pickDate() async {
    FocusScope.of(context).unfocus();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      tanggalController.text = picked.toIso8601String().split('T')[0];
    }
  }

  /// ===== SUBMIT =====
  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedJenisKk == null) {
      _toast('Pilih jenis pengajuan KK');
      return;
    }

    if (files['formulir_permohonan_kk'] == null) {
      _toast('Formulir KK wajib diupload');
      return;
    }

    for (final field in requiredFields) {
      if (files[field] == null) {
        _toast('Dokumen ${field.replaceAll('_', ' ')} wajib diupload');
        return;
      }
    }

    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.0.2.2:8000/api/form-pengajuan-kk'),
      );

      request.fields.addAll({
        'jenis_kk': selectedJenisKk!,
        'nik': nikController.text,
        'nama': namaController.text,
        'tanggal_pengajuan': tanggalController.text,
      });

      for (final entry in files.entries) {
        if (entry.value != null) {
          final bytes = await entry.value!.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              entry.key,
              bytes,
              filename: path.basename(entry.value!.path),
            ),
          );
        }
      }

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      final data = jsonDecode(respStr);

      if (response.statusCode == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResumeKkPage(id: data['data']['id']),
          ),
        );
      } else {
        _toast(data['message'] ?? 'Gagal submit');
      }
    } catch (e) {
      _toast('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  /// ===== FILE PICKER =====
  Widget filePicker(String label, String key) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () => pickImage(key),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(label,
                style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              files[key] != null
                  ? path.basename(files[key]!.path)
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
  @override
  Widget build(BuildContext context) {
    return BaseLayouts2(
      title: 'Pengajuan KK',
      showBack: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
            value: selectedJenisKk,
            isExpanded: true, 
            decoration: fieldDecoration('Jenis Pengajuan KK'),
            dropdownColor: Colors.white,
              items: jenisKkOptions
                  .map(
                    (e) => DropdownMenuItem<String>(
                      value: e['value'],
                      child: Text(
                        e['label'],
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => selectedJenisKk = v),
              validator: (v) => v == null ? 'Pilih jenis KK' : null,
            ),
            const SizedBox(height: 15),
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
              readOnly: true,
              decoration: fieldDecoration('Tanggal Pengajuan'),
              onTap: pickDate,
              validator: (v) =>
                  v!.isEmpty ? 'Tanggal wajib diisi' : null,
            ),
            const SizedBox(height: 20),
            filePicker('Formulir Permohonan KK', 'formulir_permohonan_kk'),
            for (final f in requiredFields)
              filePicker(f.replaceAll('_', ' ').toUpperCase(), f),
            const SizedBox(height: 30),
            submitButton(),
          ],
        ),
      ),
    );
  }
}
