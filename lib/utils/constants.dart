import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  static const String baseUrl = 'https://newsapi.org/v2/';

  // Get api key from env variables
  static String get apiKey => dotenv.env['API_KEY'] ?? '';

  // list of endpoints
  static const String topHeadlines = 'top-headlines';
  static const String everything = 'everything';

  //list categories
  static const List<String> categories = [
    'business',
    'entertainment',
    'general',
    'health',
    'science',
    'sports',
  ];

  //list of countries
  static const List<String> defaultCountries = ['id', 'us', 'gb', 'ca', 'au'];

  // default info
  static const String appName = 'News App';
  static const String appVersion = '1.0.0';
}
