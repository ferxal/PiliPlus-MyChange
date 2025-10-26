import 'package:get/get.dart';
import 'package:piliplus/http/loading_state.dart';
import 'package:piliplus/http/video.dart';
import 'package:piliplus/models/model_hot_video_item.dart';
import 'package:piliplus/pages/common/common_list_controller.dart';

class RelatedController
    extends CommonListController<List<HotVideoItemModel>?, HotVideoItemModel> {
  RelatedController({this.autoQuery = true});
  String bvid = Get.arguments['bvid'];
  final bool autoQuery;

  @override
  void onInit() {
    super.onInit();
    if (autoQuery) {
      queryData();
    }
  }

  @override
  Future<LoadingState<List<HotVideoItemModel>?>> customGetData() =>
      VideoHttp.relatedVideoList(bvid: bvid);
}
