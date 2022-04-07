import 'dart:io';

import 'package:flutter/material.dart';
import 'package:quran_hd/models/quran_page.dart';
import 'package:quran_hd/quran_hd/quran_hd.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  QuranHD quranHD = QuranHD();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: quranHD.initPages(),
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            return PageView.builder(
                itemCount: quranHD.quranPages.length,
                itemBuilder: (_, index) {
                  QuranPage quranPage = quranHD.quranPages[index];
                  if (quranPage.isHd) {
                    return Image.file(
                      File(quranPage.path),
                      fit: BoxFit.fill,
                    );
                  }
                  return Image.asset(
                    'assets/quran/${quranPage.path}',
                    fit: BoxFit.fill,
                  );
                });
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await quranHD.downloadQuranPagesHd();
          // await quranHD.deleteAllImageFromSharedPreffrence();
          setState(() {});
        },
      ),
    );
  }
}
