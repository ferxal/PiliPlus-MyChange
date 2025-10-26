import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliplus/models/common/reply/reply_search_type.dart';
import 'package:piliplus/pages/video/reply_search_item/child/controller.dart';
import 'package:piliplus/utils/extension.dart';
import 'package:piliplus/utils/utils.dart';

class ReplySearchController extends GetxController
    with GetSingleTickerProviderStateMixin {
  ReplySearchController(this.type, this.oid);
  final int type;
  final int oid;

  late final tabController = TabController(vsync: this, length: 2);
  final editingController = TextEditingController();
  final focusNode = FocusNode();

  late final videoCtr = Get.put(
    ReplySearchChildController(this, ReplySearchType.video),
    tag: Utils.generateRandomString(8),
  );
  late final articleCtr = Get.put(
    ReplySearchChildController(this, ReplySearchType.article),
    tag: Utils.generateRandomString(8),
  );

  void onClear() {
    if (editingController.value.text.isNotEmpty) {
      editingController.clear();
      focusNode.requestFocus();
    } else {
      Get.back();
    }
  }

  @override
  void onInit() {
    super.onInit();
    submit();
  }

  void submit() {
    videoCtr
      ..scrollController.jumpToTop()
      ..onReload();
    articleCtr
      ..scrollController.jumpToTop()
      ..onReload();
  }

  @override
  void onClose() {
    editingController.dispose();
    focusNode.dispose();
    tabController.dispose();
    super.onClose();
  }
}
