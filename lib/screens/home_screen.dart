// A brand new way to make a screen using GetX state management
// basically: kita bikin UI yang langsung sinkron sama controller data-nya

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:news_application/controllers/news_controller.dart';
import 'package:news_application/routes/app_pages.dart';
import 'package:news_application/utils/app_colors.dart';
import 'package:news_application/widgets/category_chip.dart';
import 'package:news_application/widgets/loading_shimmer.dart';
import 'package:news_application/widgets/news_card.dart';

// pake GetView biar bisa langsung akses controller tanpa harus manual inject
class HomeScreen extends GetView<NewsController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ---------- APP BAR ----------
      appBar: AppBar(
        title: Text('News App'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            // buka dialog buat search berita
            onPressed: () => _showSearchDialog(context),
          )
        ],
      ),

      // ---------- BODY ----------
      body: Column(
        children: [
          // ----- CATEGORY LIST -----
          Container(
            height: 60,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: controller.categories.length,
              itemBuilder: (context, index) {
                final category = controller.categories[index];
                // Obx biar UI langsung update kalo kategori berubah
                return Obx(() => CategoryChip(
                  label: category.capitalize ?? category,
                  isSelected: controller.selectedCategory == category,
                  // pas user tap kategori, fetch berita baru
                  onTap: () => controller.selectCategory(category)
                ));
              },
            ),
          ),
          
          // ----- NEWS LIST -----
          Expanded(
            // Obx = reactive builder, auto rebuild pas data berubah
            child: Obx(() {
              // tampilkan shimmer pas loading
              if (controller.isLoading) {
                return LoadingShimmer();
              }

              // kalau ada error
              if (controller.error.isNotEmpty) {
                return _buildErrorWidget();
              }

              // kalau datanya kosong (belum ada berita)
              if (controller.articles.isEmpty) {
                return _buildEmptyWidget();
              }

              // kalau semua oke, tampilkan daftar berita
              return RefreshIndicator(
                onRefresh: controller.refreshNews,
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: controller.articles.length,
                  itemBuilder: (context, index) {
                    final article = controller.articles[index];
                    return NewsCard(
                      article: article,
                      // pas diklik, navigasi ke detail berita
                      onTap: () => Get.toNamed(
                        Routes.NEWS_DETAIL,
                        // argument = data yang dikirim ke halaman detail
                        arguments: article
                      ),
                    );
                  },
                ),
              );
            }),
          )
        ],
      ),
    );
  }

  // ---------- EMPTY STATE ----------
  // tampilan kalau belum ada berita yang bisa ditampilkan
  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.newspaper,
            size: 64,
            color: AppColors.textHint,
          ),
          SizedBox(height: 16),
          Text(
            'No news available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Please try again later',
            style: TextStyle(
              color: AppColors.textSecondary
            ),
          )
        ],
      ),
    );
  }

  // ---------- ERROR STATE ----------
  // tampilan kalau gagal load berita (misal no internet)
  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary
            ),
          ),
          SizedBox(height:  8),
          Text(
            'Please check your internet connection',
            style: TextStyle(
              color: AppColors.textSecondary
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: controller.refreshNews,
            child: Text('Retry'),
          )
        ],
      ),
    );
  }

  // ---------- SEARCH DIALOG ----------
  // pop-up buat cari berita berdasarkan keyword user
  void _showSearchDialog(BuildContext context) {
    final TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Search News'),
        content: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Please type a news..',
            border: OutlineInputBorder()
          ),
          // langsung search pas user tekan enter
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              controller.searchNews(value);
              Navigator.of(context).pop(); // close dialog
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // cancel
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (searchController.text.isNotEmpty) {
                controller.searchNews(searchController.text);
                Navigator.of(context).pop();
              }
            },
            child: Text('Search'),
          )
        ],
      ),
    );
  }
}
