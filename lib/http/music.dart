import 'package:dio/dio.dart';
import 'package:piliplus/http/api.dart';
import 'package:piliplus/http/init.dart';
import 'package:piliplus/http/loading_state.dart';
import 'package:piliplus/models_new/music/bgm_detail.dart';
import 'package:piliplus/models_new/music/bgm_recommend_list.dart';
import 'package:piliplus/utils/accounts.dart';
import 'package:piliplus/utils/wbi_sign.dart';

class MusicHttp {
  static Future<LoadingState<MusicDetail>> bgmDetail(String musicId) async {
    final res = await Request().get(
      Api.bgmDetail,
      queryParameters: await WbiSign.makSign({
        'music_id': musicId,
        'relation_from': 'bgm_page',
      }),
    );
    if (res.data['code'] == 0) {
      return Success(MusicDetail.fromJson(res.data['data']));
    } else {
      return Error(res.data['message']);
    }
  }

  static Future<LoadingState<Null>> wishUpdate(
    String musicId,
    bool hasLike,
  ) async {
    final res = await Request().post(
      Api.wishUpdate,
      data: {
        'music_id': musicId,
        'state': hasLike ? 2 : 1,
        'csrf': Accounts.main.csrf,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    if (res.data['code'] == 0) {
      return const Success(null);
    } else {
      return Error(res.data['message']);
    }
  }

  static Future<LoadingState<List<BgmRecommend>?>> bgmRecommend(
    String musicId,
  ) async {
    final res = await Request().get(
      Api.bgmRecommend,
      queryParameters: {
        'music_id': musicId,
      },
    );
    if (res.data['code'] == 0) {
      return Success(
        (res.data['data']?['list'] as List?)
            ?.map((i) => BgmRecommend.fromJson(i))
            .toList(),
      );
    } else {
      return Error(res.data['message']);
    }
  }
}
