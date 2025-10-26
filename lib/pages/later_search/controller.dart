import 'package:get/get.dart';
import 'package:piliplus/http/loading_state.dart';
import 'package:piliplus/http/user.dart';
import 'package:piliplus/models_new/later/data.dart';
import 'package:piliplus/models_new/later/list.dart';
import 'package:piliplus/pages/common/multi_select/base.dart';
import 'package:piliplus/pages/common/search/common_search_controller.dart';
import 'package:piliplus/pages/later/controller.dart' show BaseLaterController;

class LaterSearchController
    extends CommonSearchController<LaterData, LaterItemModel>
    with
        CommonMultiSelectMixin<LaterItemModel>,
        DeleteItemMixin,
        BaseLaterController {
  dynamic mid = Get.arguments['mid'];
  dynamic count = Get.arguments['count'];

  @override
  Future<LoadingState<LaterData>> customGetData() => UserHttp.seeYouLater(
    page: page,
    keyword: editController.value.text,
  );

  @override
  List<LaterItemModel>? getDataList(LaterData response) {
    return response.list;
  }
}
