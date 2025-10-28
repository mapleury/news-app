import 'dart:convert';

import 'package:news_application/models/news_response.dart';
import 'package:news_application/utils/constants.dart';
// ini kaya shortcut: kita kasih alias 'http' biar gampang akses package http
import 'package:http/http.dart' as http;

class NewsServices {
  // base URL dari API (https://newsapi.org/v2/)
  static const String _baseUrl = Constants.baseUrl;
  // API key buat autentikasi ke server
  static final String _apiKey = Constants.apiKey;

  // ---------- GET TOP HEADLINES ----------
  // fungsi ini buat ngambil berita utama (headline) dari API
  Future<NewsResponse> getTopHeadlines({
    String country =
        Constants.defaultCountry, // default country (biasanya "us" atau "id")
    String? category, // kategori berita (misal: tech, sports, health)
    int page = 1, // halaman ke berapa
    int pageSize = 20, // berapa berita per halaman
  }) async {
    try {
      // bikin query params buat dikirim ke endpoint API
      final Map<String, String> queryParams = {
        'apiKey': _apiKey,
        'country': country,
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };

      // kalau kategori diisi, tambahin ke parameter
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }

      // bikin URI lengkap dari baseUrl + endpoint + queryParams
      // jadi kayak nyusun URL final buat request ke server
      final uri = Uri.parse(
        '$_baseUrl${Constants.topHeadlines}',
      ).replace(queryParameters: queryParams);

      // kirim GET request ke server dan tunggu response-nya
      final response = await http.get(uri);

      // kalau sukses (statusCode 200), berarti data bisa diambil
      if (response.statusCode == 200) {
        // decode JSON dari API ke bentuk data Dart
        final jsonData = json.decode(response.body);
        // ubah JSON jadi object NewsResponse biar gampang dipakai di UI
        return NewsResponse.fromJson(jsonData);
      } else {
        // kalau status code bukan 200 → berarti gagal load data
        throw Exception('Failed to load news, please try again later.');
      }
    } catch (e) {
      // kalau ada error lain (misal: no internet, timeout, dll)
      throw Exception('Another problem occurs, please try again later');
    }
  }

  // ---------- SEARCH NEWS ----------
  // fungsi buat cari berita berdasarkan keyword yang diketik user
  Future<NewsResponse> searchNews({
    required String query, // keyword pencarian
    int page = 1, // halaman keberapa
    int pageSize = 20, // berapa berita ditampilkan per halaman
    String? sortBy, // bisa diisi 'popularity', 'relevancy', 'publishedAt', dll
  }) async {
    try {
      // buat parameter pencarian
      final Map<String, String> queryParams = {
        'apiKey': _apiKey,
        'q': query,
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };

      // kalau ada sortBy (urutan berita), tambahin ke param
      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sortBy'] = sortBy;
      }

      // bentuk URI-nya mirip kayak topHeadlines tapi endpoint-nya beda
      final uri = Uri.parse(
        '$_baseUrl${Constants.everything}',
      ).replace(queryParameters: queryParams);

      // kirim request ke server
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        // decode JSON dan ubah ke model NewsResponse
        final jsonData = json.decode(response.body);
        return NewsResponse.fromJson(jsonData);
      } else {
        // kalau gagal
        throw Exception('Failed to load news, please try again later.');
      }
    } catch (e) {
      // handle error umum
      throw Exception('Another problem occurs, please try again later.');
    }
  }
}
