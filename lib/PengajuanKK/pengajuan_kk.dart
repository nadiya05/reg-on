import 'package:flutter/material.dart';
import 'package:reg_on/Layouts/BaseLayouts1.dart';
import 'package:reg_on/PengajuanKK/form_pemula.dart';
import 'package:reg_on/PengajuanKK/form_ubah_status.dart';

class PengajuanKKBeranda extends StatelessWidget {
  const PengajuanKKBeranda({super.key});

  Widget _buildButton(BuildContext context, String text) {
    return InkWell(
      onTap: () {
        // Navigasi ke form sesuai jenis
        switch (text) {
          case 'Pemula':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FormPemulaKK()),
            );
            break;
          case 'Ubah Status':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FormUbahStatusKK()),
            );
            break;
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 50),
        padding: const EdgeInsets.symmetric(vertical: 65, horizontal: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> jenisKKList = [
      'Pemula',
      'Ubah Status',
    ];

    return BaseLayouts1(
      title: "Pengajuan KK",
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < jenisKKList.length; i++) ...[
              _buildButton(context, jenisKKList[i]),
              if (i != jenisKKList.length - 1)
                const SizedBox(height: 50), // 🔹 Jarak antar tombol
            ],
          ],
        ),
      ),
    );
  }
}
