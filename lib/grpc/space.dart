import 'package:fixnum/fixnum.dart';
import 'package:piliplus/grpc/bilibili/app/dynamic/v2.pb.dart';
import 'package:piliplus/grpc/bilibili/pagination.pb.dart';
import 'package:piliplus/grpc/grpc_req.dart';
import 'package:piliplus/grpc/url.dart';
import 'package:piliplus/http/loading_state.dart';

class SpaceGrpc {
  static Future<LoadingState<OpusSpaceFlowResp>> opusSpaceFlow({
    required int hostMid,
    String? next,
    required String filterType,
  }) {
    return GrpcReq.request(
      GrpcUrl.opusSpaceFlow,
      OpusSpaceFlowReq(
        hostMid: Int64(hostMid),
        pagination: Pagination(
          pageSize: 20,
          next: next,
        ),
        filterType: filterType,
      ),
      OpusSpaceFlowResp.fromBuffer,
    );
  }
}
