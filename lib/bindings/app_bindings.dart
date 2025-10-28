import 'package:get/get.dart';
import 'package:news_application/controllers/news_controller.dart';

class AppBindings implements Bindings {
  @override
  void dependencies() {
    Get.put<NewsController>(NewsController(), permanent: true);
  }
}