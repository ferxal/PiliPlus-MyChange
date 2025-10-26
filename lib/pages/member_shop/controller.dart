import 'package:piliplus/http/loading_state.dart';
import 'package:piliplus/http/member.dart';
import 'package:piliplus/models_new/space/space_shop/data.dart';
import 'package:piliplus/models_new/space/space_shop/item.dart';
import 'package:piliplus/pages/common/common_list_controller.dart';

class MemberShopController
    extends CommonListController<SpaceShopData, SpaceShopItem> {
  MemberShopController(this.mid);

  final int mid;

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  bool? showMoreTab;
  String? clickUrl;
  String? showMoreDesc;

  @override
  List<SpaceShopItem>? getDataList(SpaceShopData response) {
    isEnd = response.haveNextPage == false;
    showMoreTab = response.showMoreTab;
    clickUrl = response.clickUrl;
    showMoreDesc = response.showMoreDesc;
    return response.data;
  }

  @override
  Future<LoadingState<SpaceShopData>> customGetData() =>
      MemberHttp.spaceShop(mid: mid);
}
