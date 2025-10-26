import 'package:get/get.dart';
import 'package:piliplus/http/loading_state.dart';
import 'package:piliplus/http/match.dart';
import 'package:piliplus/models_new/match/match_info/contest.dart';
import 'package:piliplus/pages/common/dyn/common_dyn_controller.dart';

class MatchInfoController extends CommonDynController {
  @override
  final int oid = int.parse(Get.parameters['cid']!);
  @override
  final int replyType = 27;

  @override
  dynamic get sourceId => oid.toString();

  final Rx<LoadingState<MatchContest?>> infoState =
      LoadingState<MatchContest?>.loading().obs;

  @override
  void onInit() {
    super.onInit();
    getMatchInfo();
  }

  Future<void> getMatchInfo() async {
    var res = await MatchHttp.matchInfo(oid);
    if (res.isSuccess) {
      queryData();
    }
    infoState.value = res;
  }
}
