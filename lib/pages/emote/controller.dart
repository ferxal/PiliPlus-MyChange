import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliplus/http/loading_state.dart';
import 'package:piliplus/http/reply.dart';
import 'package:piliplus/models_new/emote/package.dart';
import 'package:piliplus/pages/common/common_list_controller.dart';
import 'package:piliplus/services/custom_emote_service.dart';
import 'package:piliplus/utils/storage_pref.dart';

class EmotePanelController extends CommonListController<List<Package>?, Package>
    with GetSingleTickerProviderStateMixin {
  TabController? tabController;
  final CustomEmoteService _customEmoteService = Get.put(CustomEmoteService());

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  bool customHandleResponse(bool isRefresh, Success<List<Package>?> response) {
    if (response.response?.isNotEmpty == true) {
      tabController = TabController(
        length: response.response!.length,
        vsync: this,
      );
    }
    loadingState.value = response;
    return true;
  }

  @override
  Future<LoadingState<List<Package>?>> customGetData() async {
    try {
      print('=== 开始加载表情包 ===');
      
      // 1. 获取哔哩哔哩官方表情包
      print('1. 加载B站官方表情包...');
      final biliEmotes = await ReplyHttp.getEmoteList(business: 'reply');
      if (biliEmotes is Success<List<Package>?>) {
        print('✓ B站表情包加载成功: ${biliEmotes.response?.length ?? 0}个分类');
      } else {
        print('✗ B站表情包加载失败');
      }
      
      // 2. 获取自定义表情包URL列表
      final customUrls = Pref.customEmoteUrls;
      print('2. 用户配置的URL数量: ${customUrls.length}');
      
      // 3. 尝试加载自定义表情包（无论用户是否配置，都尝试从配置文件加载）
      print('3. 加载自定义表情包...');
      final customEmotes = await _customEmoteService.loadEmotePackages(customUrls);
      
      // 4. 融合两个数据源
      if (biliEmotes is Success<List<Package>?>) {
        if (customEmotes is Success<List<Package>>) {
          // 两者都成功，合并列表
          print('✓ 自定义表情包加载成功: ${customEmotes.response.length}个分类');
          final mergedList = <Package>[
            ...?biliEmotes.response,
            ...customEmotes.response,
          ];
          print('=== 表情包加载完成: 总计${mergedList.length}个分类 ===');
          return Success(mergedList);
        } else {
          // 自定义表情包加载失败，只返回B站表情包
          final errMsg = customEmotes is Error ? (customEmotes as Error).errMsg : '未知错误';
          print('✗ 自定义表情包加载失败: $errMsg');
          print('=== 返回B站表情包: ${biliEmotes.response?.length ?? 0}个分类 ===');
          return biliEmotes;
        }
      } else if (customEmotes is Success<List<Package>>) {
        // B站表情包加载失败，返回自定义表情包
        print('✓ 自定义表情包加载成功: ${customEmotes.response.length}个分类');
        print('=== 返回自定义表情包: ${customEmotes.response.length}个分类 ===');
        return Success(customEmotes.response);
      } else {
        // 两者都失败
        print('=== 表情包加载失败：B站和自定义表情包都无法加载 ===');
        return const Error('加载表情包失败');
      }
    } catch (e) {
      print('=== 表情包加载异常: $e ===');
      return Error('加载表情包异常: $e');
    }
  }

  @override
  void onClose() {
    tabController?.dispose();
    super.onClose();
  }
}
