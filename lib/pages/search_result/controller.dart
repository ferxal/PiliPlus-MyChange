import 'package:get/get.dart';
import 'package:piliplus/models/common/search/search_type.dart';

class SearchResultController extends GetxController {
  String keyword = Get.parameters['keyword'] ?? '';

  RxList<int> count = List.filled(SearchType.values.length, -1).obs;

  RxInt toTopIndex = (-1).obs;

  @override
  void onClose() {
    toTopIndex.close();
    super.onClose();
  }
}
