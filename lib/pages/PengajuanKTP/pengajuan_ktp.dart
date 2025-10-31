import 'package:flutter/material.dart';
import 'package:reg_on/Layouts/BaseLayouts1.dart';
import 'package:reg_on/pages/PengajuanKTP/form_pemula.dart';
import 'package:reg_on/pages/PengajuanKTP/form_kehilangan.dart';
import 'package:reg_on/pages/PengajuanKTP/form_rusak_ubah_status.dart';

class PengajuanBeranda extends StatelessWidget {
  const PengajuanBeranda({super.key});

  Widget _buildButton(BuildContext context, String text) {
    return InkWell(
      onTap: () {
        // Navigasi ke form sesuai jenis
        switch (text) {
          case 'Pemula':
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FormPemula()));
            break;
          case 'Kehilangan':
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FormKehilangan()));
            break;
          case 'Rusak atau Ubah Status':
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FormRusakUbahStatus()));
            break;
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            )
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
    final List<String> jenisKtpList = [
      'Pemula',
      'Kehilangan',
      'Rusak atau Ubah Status'
    ];

    return BaseLayouts1(
      title: "Pengajuan KTP",
      child: Column(
        children: jenisKtpList.asMap().entries.map((entry) {
          int index = entry.key;
          String jenis = entry.value;

          Alignment alignment =
              index % 2 == 0 ? Alignment.centerLeft : Alignment.centerRight;

          return Align(
            alignment: alignment,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              margin: const EdgeInsets.symmetric(vertical: 15),
              child: _buildButton(context, jenis),
            ),
          );
        }).toList(),
      ),
    );
  }
}
