import 'package:get/get.dart';
import 'package:piliplus/http/loading_state.dart';
import 'package:piliplus/http/member.dart';
import 'package:piliplus/models_new/space/space/tab2.dart';
import 'package:piliplus/models_new/space/space_opus/data.dart';
import 'package:piliplus/models_new/space/space_opus/item.dart';
import 'package:piliplus/pages/common/common_list_controller.dart';
import 'package:piliplus/pages/member/controller.dart';

class MemberOpusController
    extends CommonListController<SpaceOpusData, SpaceOpusItemModel> {
  MemberOpusController({
    required this.heroTag,
    required this.mid,
  });

  final String? heroTag;
  final int mid;

  String offset = '';
  Rx<SpaceTabFilter> type = const SpaceTabFilter(
    text: "全部图文",
    meta: "all",
    tabName: "图文",
  ).obs;
  List<SpaceTabFilter>? filter;

  @override
  void onInit() {
    super.onInit();
    filter = Get.find<MemberController>(tag: heroTag).tab2
        ?.firstWhereOrNull((e) => e.param == 'contribute')
        ?.items
        ?.firstWhereOrNull((e) => e.param == 'opus')
        ?.filter;
    queryData();
  }

  @override
  Future<void> onRefresh() {
    offset = '';
    return super.onRefresh();
  }

  @override
  List<SpaceOpusItemModel>? getDataList(SpaceOpusData response) {
    offset = response.offset ?? '';
    if (response.hasMore == false) {
      isEnd = true;
    }
    return response.items;
  }

  @override
  Future<LoadingState<SpaceOpusData>> customGetData() => MemberHttp.spaceOpus(
    hostMid: mid,
    page: page,
    offset: offset,
    type: type.value.meta,
  );
}
