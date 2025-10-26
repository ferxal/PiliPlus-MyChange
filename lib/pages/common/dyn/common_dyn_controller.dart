import 'package:get/get.dart';
import 'package:piliplus/grpc/bilibili/main/community/reply/v1.pb.dart';
import 'package:piliplus/grpc/reply.dart';
import 'package:piliplus/http/loading_state.dart';
import 'package:piliplus/pages/common/reply_controller.dart';
import 'package:piliplus/utils/storage_pref.dart';

abstract class CommonDynController extends ReplyController<MainListReply> {
  int get oid;
  int get replyType;

  late final RxBool showTitle = false.obs;

  late final horizontalPreview = Pref.horizontalPreview;
  late final List<double> ratio = Pref.dynamicDetailRatio;

  @override
  Future<LoadingState<MainListReply>> customGetData() => ReplyGrpc.mainList(
    type: replyType,
    oid: oid,
    mode: mode.value,
    cursorNext: cursorNext,
    offset: paginationReply?.nextOffset,
  );

  @override
  List<ReplyInfo>? getDataList(MainListReply response) {
    return response.replies;
  }
}
