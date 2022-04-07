import 'dart:io';
import 'package:dio/dio.dart';
import 'package:quran_hd/models/quran_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart' as path;

class QuranHD {
  Dio dio = Dio();

  List<String> quranHdURLs = [
    'https://firebasestorage.googleapis.com/v0/b/myproject-16a3f.appspot.com/o/1.jpg?alt=media&token=3163677b-dc09-4443-8d57-f8efa6df925a',
    'https://firebasestorage.googleapis.com/v0/b/myproject-16a3f.appspot.com/o/2.jpg?alt=media&token=bfc2b267-fa63-499e-8205-9346fe73d51d',
    'https://firebasestorage.googleapis.com/v0/b/myproject-16a3f.appspot.com/o/3.jpg?alt=media&token=79c32d65-d89e-486d-a63f-df9a45877a57',
    'https://firebasestorage.googleapis.com/v0/b/myproject-16a3f.appspot.com/o/4.jpg?alt=media&token=034586fb-08c6-498e-b447-894f2f81821d',
  ];

  List<QuranPage> quranPages = [];

  Future<void> savePagesPath(int page, String path) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('quran_page ' + page.toString(), path);
  }

  Future<void> initPages() async {
    quranPages = [];
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    for (int i = 1; i < 5; i++) {
      String? path = sharedPreferences.getString('quran_page ' + i.toString());
      if (path == null) {
        quranPages.add(QuranPage(page: i, path: '$i.jpg', isHd: false));
      } else {
        quranPages.add(QuranPage(page: i, path: path, isHd: true));
      }
    }
  }

  Future deleteAllImageFromSharedPreffrence() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.clear();
  }

  Future downloadQuranPagesHd() async {
    String tempDir = (await path.getApplicationDocumentsDirectory()).path;
    for (int i = 0; i < quranHdURLs.length; i++) {
      String? savePath = await downloadImageHd(
        quranHdURLs[i],
        tempDir + '\\' + (i + 1).toString() + '.jpg',
      );
      if (savePath != null) {
        savePagesPath(i + 1, savePath);
      }
    }
  }

  Future<String?> downloadImageHd(String url, String savePath) async {
    try {
      Response response = await dio.get(
        url,
        onReceiveProgress: showDownloadProgress,
        //Received data with List<int>
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );
      File file = File(savePath);
      var raf = file.openSync(mode: FileMode.write);
      // response.data is List<int> type
      raf.writeFromSync(response.data);
      await raf.close();

      print(savePath);
      return savePath;
    } catch (e) {
      print(e);
    }
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {
      print((received / total * 100).toStringAsFixed(0) + "%");
    }
  }
}
