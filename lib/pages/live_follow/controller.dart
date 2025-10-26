import 'package:get/get.dart';
import 'package:piliplus/http/live.dart';
import 'package:piliplus/http/loading_state.dart';
import 'package:piliplus/models_new/live/live_follow/data.dart';
import 'package:piliplus/models_new/live/live_follow/item.dart';
import 'package:piliplus/pages/common/common_list_controller.dart';

class LiveFollowController
    extends CommonListController<LiveFollowData, LiveFollowItem> {
  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  Rx<int?> count = Rx<int?>(null);

  @override
  void checkIsEnd(int length) {
    final count = this.count.value;
    if (count != null && length >= count) {
      isEnd = true;
    }
  }

  @override
  List<LiveFollowItem>? getDataList(LiveFollowData response) {
    count.value = response.liveCount;
    return response.list;
  }

  @override
  Future<LoadingState<LiveFollowData>> customGetData() =>
      LiveHttp.liveFollow(page);
}
