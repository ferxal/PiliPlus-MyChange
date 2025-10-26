import 'package:get/get.dart';
import 'package:piliplus/models/user/info.dart';
import 'package:piliplus/utils/storage_pref.dart';

class AccountService extends GetxService {
  late int mid;
  late final RxString name;
  late final RxString face;
  late final RxBool isLogin;

  @override
  void onInit() {
    super.onInit();
    UserInfoData? userInfo = Pref.userInfoCache;
    mid = userInfo?.mid ?? 0;
    name = (userInfo?.uname ?? '').obs;
    face = (userInfo?.face ?? '').obs;
    isLogin = (userInfo != null).obs;
  }
}
