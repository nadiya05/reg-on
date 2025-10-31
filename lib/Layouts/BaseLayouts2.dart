import 'package:flutter/material.dart';

class BaseLayouts2 extends StatelessWidget {
  final String title;       // judul halaman form
  final Widget child;       // konten form
  final bool showBack;      // tombol back

  const BaseLayouts2({
    super.key,
    required this.title,
    required this.child,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0077B6), // biru background
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 HEADER
            Container(
              height: 90,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button kiri
                  if (showBack)
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    )
                  else
                    const SizedBox(width: 48), // simetris kalau ga ada back

                  const Spacer(), // dorong logo ke kanan

                  // Logo di kanan
                  Image.asset(
                    "assets/images/logo.png",
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),

            // 🔹 FORM CONTAINER
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      child, // form isi beda-beda di sini
                    ],
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