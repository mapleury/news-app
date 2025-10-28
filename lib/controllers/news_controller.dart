import 'package:get/get.dart';
import 'package:news_application/models/news_articles.dart';
import 'package:news_application/services/news_services.dart';
import 'package:news_application/utils/constants.dart';

// Controller ini basically jadi jembatan antara UI dan data logic (NewsServices)
class NewsController extends GetxController {
  // buat akses fungsi API dari NewsServices
  final NewsServices _newsServices = NewsServices();

  // ---------- VARIABLES ----------
  // pakai Rx (reactive) biar bisa auto update UI kalo datanya berubah

  final _isLoading = false.obs; // true pas lagi loading, false kalo udah kelar
  final _articles = <NewsArticles>[].obs; // list berita yang udah ke-fetch
  final _selectedCategory = 'general'.obs; // kategori yang lagi dipilih user
  final _error = ''.obs; // buat nampung pesan error biar bisa ditampilin ke UI

  // ---------- GETTERS ----------
  // ini cara aman buat "ngintip" isi variable di atas dari luar class
  bool get isLoading => _isLoading.value;
  List<NewsArticles> get articles => _articles;
  String get selectedCategory => _selectedCategory.value;
  String get error => _error.value;
  List<String> get categories => Constants.categories;

  // ---------- FETCH BERITA UTAMA ----------
  // auto jalan pas app dibuka, ngambil berita utama dari API top-headlines
  Future<void> fetchTopHeadlines({String? category}) async {
    try {
      _isLoading.value = true; // tandain lagi loading
      _error.value = ''; // reset error biar bersih

      // ambil data dari API sesuai kategori (default = selectedCategory)
      final response = await _newsServices.getTopHeadlines(
        category: category ?? _selectedCategory.value,
      );

      _articles.value = response.articles; // update list artikel ke UI
    } catch (e) {
      _error.value = e.toString(); // simpen error ke variable
      // munculin snackbar kalo gagal
      Get.snackbar(
        'Error',
        'Failed to load news: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false; // apapun hasilnya, stop loading
    }
  }

  // ---------- REFRESH ----------
  // buat refresh berita (biasanya pas user swipe down)
  Future<void> refreshNews() async {
    await fetchTopHeadlines();
  }

  // ---------- GANTI KATEGORI ----------
  // pas user milih kategori lain di UI
  void selectCategory(String category) {
    if (_selectedCategory.value != category) {
      _selectedCategory.value = category;
      fetchTopHeadlines(
        category: category,
      ); // fetch berita sesuai kategori baru
    }
  }

  // ---------- SEARCH BERITA ----------
  // buat fitur pencarian berita
  Future<void> searchNews(String query) async {
    if (query.isEmpty) return; // kalo query kosong, skip aja

    try {
      _isLoading.value = true;
      _error.value = '';

      final response = await _newsServices.searchNews(query: query);
      _articles.value = response.articles; // tampilkan hasil pencarian
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to search news: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }
}
