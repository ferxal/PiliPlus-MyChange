import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:piliplus/pages/emote/controller.dart';
import 'package:piliplus/utils/storage_pref.dart';

class CustomEmoteSettingController extends GetxController {
  final RxList<String> emoteUrls = <String>[].obs;
  final TextEditingController urlController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadUrls();
  }

  void _loadUrls() {
    emoteUrls.value = Pref.customEmoteUrls;
  }

  void addUrl(String url) {
    if (url.isEmpty) {
      SmartDialog.showToast('URL不能为空');
      return;
    }

    if (emoteUrls.contains(url)) {
      SmartDialog.showToast('该URL已存在');
      return;
    }

    emoteUrls.add(url);
    _saveUrls();
    urlController.clear();
    SmartDialog.showToast('添加成功');
    _refreshEmotePanel();
  }

  void removeUrl(int index) {
    if (index >= 0 && index < emoteUrls.length) {
      emoteUrls.removeAt(index);
      _saveUrls();
      SmartDialog.showToast('删除成功');
      _refreshEmotePanel();
    }
  }

  void _saveUrls() {
    Pref.customEmoteUrls = emoteUrls;
  }

  void _refreshEmotePanel() {
    // 刷新表情包面板
    try {
      final controller = Get.find<EmotePanelController>();
      controller.onRefresh();
    } catch (e) {
      // 表情包面板可能未初始化，忽略错误
    }
  }

  @override
  void onClose() {
    urlController.dispose();
    super.onClose();
  }
}
