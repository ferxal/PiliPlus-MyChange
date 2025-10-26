import 'package:dio/dio.dart';
import 'package:piliplus/http/api.dart';
import 'package:piliplus/http/init.dart';
import 'package:piliplus/models/user/danmaku_block.dart';
import 'package:piliplus/utils/accounts.dart';

class DanmakuFilterHttp {
  static Future danmakuFilter() async {
    var res = await Request().get(Api.danmakuFilter);
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': DanmakuBlockDataModel.fromJson(res.data['data']),
      };
    } else {
      return {
        'status': false,
        'msg': res.data['message'],
      };
    }
  }

  static Future danmakuFilterDel({required int ids}) async {
    var res = await Request().post(
      Api.danmakuFilterDel,
      data: {
        'ids': ids,
        'csrf': Accounts.main.csrf,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    if (res.data['code'] == 0) {
      return {'status': true};
    } else {
      return {
        'status': false,
        'msg': res.data['message'],
      };
    }
  }

  static Future danmakuFilterAdd({
    required String filter,
    required int type,
  }) async {
    var res = await Request().post(
      Api.danmakuFilterAdd,
      data: {
        'type': type,
        'filter': filter,
        'csrf': Accounts.main.csrf,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': SimpleRule.fromJson(res.data['data']),
      };
    } else {
      return {
        'status': false,
        'msg': res.data['message'],
      };
    }
  }
}
