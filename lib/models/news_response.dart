import 'package:news_application/models/news_articles.dart';

class NewsResponse {
  final String status;
  final int totalResults;
  final List<NewsArticles> articles;

  NewsResponse({required this.status, required this.totalResults, required this.articles});

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    return NewsResponse(
      status: json['status'] ?? '',
      totalResults: json['totalResults'] ?? 0,
      // kode yang digunakan untuk mengkonversi data mentah dari server agar
      // siap digunakan oleh aplikasi 
      articles: (json['articles'] as List<dynamic>?)
                ?.map((article) => NewsArticles.fromJson(article))
                .toList() ?? []
    );
  }
}