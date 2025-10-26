import 'package:get/get.dart';
import 'package:piliplus/models/common/later_view_type.dart';
import 'package:piliplus/utils/storage.dart';
import 'package:piliplus/utils/storage_key.dart';
import 'package:piliplus/utils/storage_pref.dart';

class LaterBaseController extends GetxController {
  RxBool enableMultiSelect = false.obs;
  RxInt checkedCount = 0.obs;

  RxMap<LaterViewType, int> counts = {
    for (final item in LaterViewType.values) item: -1,
  }.obs;

  late double dx = 0;
  late final RxBool isPlayAll = Pref.enablePlayAll.obs;

  void setIsPlayAll(bool isPlayAll) {
    if (this.isPlayAll.value == isPlayAll) return;
    this.isPlayAll.value = isPlayAll;
    GStorage.setting.put(SettingBoxKey.enablePlayAll, isPlayAll);
  }
}
