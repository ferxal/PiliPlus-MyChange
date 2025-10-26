import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliplus/pages/follow_type/follow_same/controller.dart';
import 'package:piliplus/pages/follow_type/view.dart';
import 'package:piliplus/utils/extension.dart';

class FollowSamePage extends StatefulWidget {
  const FollowSamePage({super.key});

  @override
  State<FollowSamePage> createState() => _FollowSamePageState();
}

class _FollowSamePageState extends FollowTypePageState<FollowSamePage> {
  @override
  final controller = Get.putOrFind(
    FollowSameController.new,
    tag: Get.parameters['mid'],
  );

  @override
  PreferredSizeWidget get appBar => AppBar(
    title: Obx(
      () {
        final name = controller.name.value;
        return Text('${name == null ? '' : '我与$name的'}共同关注');
      },
    ),
  );
}
