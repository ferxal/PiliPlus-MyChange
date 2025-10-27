import 'dart:async';
import 'dart:convert';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:piliplus/grpc/bilibili/im/interfaces/v1.pb.dart'
    show EmotionInfo, RspSessionMsg;
import 'package:piliplus/grpc/bilibili/im/type.pb.dart' show Msg, MsgType;
import 'package:piliplus/grpc/im.dart';
import 'package:piliplus/http/loading_state.dart';
import 'package:piliplus/http/msg.dart';
import 'package:piliplus/models_new/emote/package.dart';
import 'package:piliplus/pages/common/common_list_controller.dart';
import 'package:piliplus/services/account_service.dart';
import 'package:piliplus/services/custom_emote_service.dart';
import 'package:piliplus/utils/extension.dart';
import 'package:piliplus/utils/feed_back.dart';
import 'package:piliplus/utils/storage_pref.dart';

class WhisperDetailController extends CommonListController<RspSessionMsg, Msg> {
  final _emojiPattern = RegExp(r'\[.*?\]');

  String _processSendContent(String content) {
    print('📤 原始消息: $content');
    
    final buffer = StringBuffer();
    content.splitMapJoin(
      _emojiPattern,
      onMatch: (match) {
        final emoteCode = match.group(0)!;
        print('  ✓ 表情符不加密: $emoteCode');
        buffer.write(emoteCode);  // 表情符保持原样
        return '';
      },
      onNonMatch: (nonMatch) {
        if (nonMatch.isNotEmpty) {
          final encrypted = nonMatch.runes.map((rune) {
            int newRune = rune + 10;
            if (newRune > 0x10FFFF) newRune -= 0x110000;
            return String.fromCharCode(newRune);
          }).join();
          print('  🔒 文本加密: "$nonMatch" -> "$encrypted"');
          buffer.write(encrypted);  // 文本加密
        }
        return '';
      },
    );
    final result = '\uFFFF' + buffer.toString();
    print('📤 加密后消息: $result');
    return result;
  }

  AccountService accountService = Get.find<AccountService>();

  final int talkerId = Get.arguments['talkerId'];
  final String name = Get.arguments['name'];
  final String face = Get.arguments['face'];
  final int? mid = Get.arguments['mid'];
  final bool isLive = Get.arguments['isLive'] ?? false;

  Int64? msgSeqno;

  //表情转换图片规则
  List<EmotionInfo>? eInfos;

  @override
  void onInit() {
    super.onInit();
    _loadCustomEmotes();
    queryData();
  }

  /// 加载自定义表情包并添加到eInfos
  Future<void> _loadCustomEmotes() async {
    try {
      final customEmoteService = Get.put(CustomEmoteService());
      final customUrls = Pref.customEmoteUrls;
      
      final result = await customEmoteService.loadEmotePackages(customUrls);
      
      if (result is Success<List<Package>>) {
        eInfos ??= <EmotionInfo>[];
        
        // 将自定义表情包转换为EmotionInfo
        final packages = result.response;
        for (var package in packages) {
          if (package.emote != null) {
            for (var emote in package.emote!) {
              // 检查是否已存在（避免重复）
              if (!eInfos!.any((e) => e.text == emote.text)) {
                eInfos!.add(EmotionInfo(
                  text: emote.text,
                  url: emote.url,
                  size: emote.meta?.size ?? 1,
                  gifUrl: emote.meta?.size == 2 ? emote.url : null, // 如果是动图，设置gifUrl
                ));
              }
            }
          }
        }
        
        print('✓ 自定义表情包已加载到私信：${eInfos!.length}个表情');
      }
    } catch (e) {
      print('✗ 加载自定义表情包到私信失败: $e');
    }
  }

  @override
  bool customHandleResponse(bool isRefresh, Success<RspSessionMsg> response) {
    List<Msg> msgs = response.response.messages;
    if (msgs.isNotEmpty) {
      msgSeqno = msgs.last.msgSeqno;
      if (msgs.length == 1 &&
          msgs.last.msgType == 18 &&
          msgs.last.msgSource == 18) {
        //{content: [{"text":"对方主动回复或关注你前，最多发送1条消息","color_day":"#9499A0","color_nig":"#9499A0"}]}
      } else {
        ackSessionMsg(msgs.last.msgSeqno.toInt());
      }
      // 初始化 eInfos（如果为空），但不要覆盖已有的自定义表情包
      eInfos ??= <EmotionInfo>[];
      // 只添加 B站表情包，避免重复
      final biliEmotes = response.response.eInfos;
      for (var emote in biliEmotes) {
        if (!eInfos!.any((e) => e.text == emote.text)) {
          eInfos!.add(emote);
        }
      }
    }
    return false;
  }

  // 消息标记已读
  Future<void> ackSessionMsg(int msgSeqno) async {
    var res = await MsgHttp.ackSessionMsg(
      talkerId: talkerId,
      ackSeqno: msgSeqno,
    );
    if (!res['status']) {
      SmartDialog.showToast(res['msg']);
    }
  }

  late bool _isSending = false;
  Future<void> sendMsg({
    String? message,
    Map? picMsg,
    required VoidCallback onClearText,
    int? msgType,
    int? index,
  }) async {
    assert((message != null) ^ (picMsg != null));
    if (_isSending) return;
    _isSending = true;
    feedBack();
    SmartDialog.dismiss();
    if (!accountService.isLogin.value) {
      SmartDialog.showToast('请先登录');
      return;
    }
    String processedMessage = message!;
    if (picMsg == null && msgType != 5) {
      processedMessage = _processSendContent(message!);
    }
    var result = await ImGrpc.sendMsg(
      senderUid: accountService.mid,
      receiverId: mid!,
      content: msgType == 5
          ? message!
          : jsonEncode(picMsg ?? {"content": processedMessage}),
      msgType: MsgType.values[msgType ?? (picMsg != null ? 2 : 1)],
    );
    SmartDialog.dismiss();
    if (result.isSuccess) {
      if (msgType == 5) {
        loadingState
          ..value.data![index!].msgStatus = 1
          ..refresh();
        SmartDialog.showToast('撤回成功');
      } else {
        onRefresh();
        onClearText();
        SmartDialog.showToast('发送成功');
      }
    } else {
      result.toast();
    }
    _isSending = false;
  }

  @override
  List<Msg>? getDataList(RspSessionMsg response) {
    if (response.hasMore == 0) {
      isEnd = true;
    }
    return response.messages;
  }

  @override
  Future<void> onRefresh() async {
    msgSeqno = null;
    eInfos = null;
    scrollController.jumpToTop();
    await super.onRefresh();
    // 刷新后重新加载自定义表情包
    await _loadCustomEmotes();
  }

  @override
  Future<LoadingState<RspSessionMsg>> customGetData() =>
      ImGrpc.syncFetchSessionMsgs(
        talkerId: talkerId,
        beginSeqno: msgSeqno != null ? Int64.ZERO : null,
        endSeqno: msgSeqno,
      );
}
