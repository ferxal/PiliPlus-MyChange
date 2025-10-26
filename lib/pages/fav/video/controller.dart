import 'package:get/get.dart';
import 'package:piliplus/http/fav.dart';
import 'package:piliplus/http/loading_state.dart';
import 'package:piliplus/models_new/fav/fav_folder/data.dart';
import 'package:piliplus/models_new/fav/fav_folder/list.dart';
import 'package:piliplus/pages/common/common_list_controller.dart';
import 'package:piliplus/services/account_service.dart';

class FavController extends CommonListController<FavFolderData, FavFolderInfo> {
  AccountService accountService = Get.find<AccountService>();

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  Future<void> queryData([bool isRefresh = true]) {
    if (!accountService.isLogin.value) {
      loadingState.value = const Error('账号未登录');
      return Future.value();
    }
    return super.queryData(isRefresh);
  }

  @override
  List<FavFolderInfo>? getDataList(FavFolderData response) {
    if (response.hasMore == false) {
      isEnd = true;
    }
    return response.list;
  }

  @override
  Future<LoadingState<FavFolderData>> customGetData() => FavHttp.userfavFolder(
    pn: page,
    ps: 20,
    mid: accountService.mid,
  );
}
