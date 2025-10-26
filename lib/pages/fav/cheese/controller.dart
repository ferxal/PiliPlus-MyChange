import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:piliplus/http/fav.dart';
import 'package:piliplus/http/loading_state.dart';
import 'package:piliplus/models_new/space/space_cheese/data.dart';
import 'package:piliplus/models_new/space/space_cheese/item.dart';
import 'package:piliplus/pages/common/common_list_controller.dart';
import 'package:piliplus/utils/accounts.dart';

class FavCheeseController
    extends CommonListController<SpaceCheeseData, SpaceCheeseItem> {
  final mid = Accounts.main.mid;

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  List<SpaceCheeseItem>? getDataList(SpaceCheeseData response) {
    isEnd = response.page?.next == false;
    return response.items;
  }

  @override
  Future<LoadingState<SpaceCheeseData>> customGetData() =>
      FavHttp.favPugv(mid: mid, page: page);

  Future<void> onRemove(int index, int? sid) async {
    var res = await FavHttp.delFavPugv(sid);
    if (res['status']) {
      loadingState
        ..value.data!.removeAt(index)
        ..refresh();
      SmartDialog.showToast('已取消收藏');
    } else {
      SmartDialog.showToast(res['msg']);
    }
  }
}
