import 'package:flutter/material.dart';
import 'package:piliplus/common/constants.dart';
import 'package:piliplus/common/widgets/badge.dart';
import 'package:piliplus/common/widgets/image/image_save.dart';
import 'package:piliplus/common/widgets/image/network_img_layer.dart';
import 'package:piliplus/models/search/result.dart';
import 'package:piliplus/utils/page_utils.dart';
import 'package:piliplus/utils/utils.dart';

// 视频卡片 - 垂直布局
class PgcCardVSearch extends StatelessWidget {
  const PgcCardVSearch({
    super.key,
    required this.item,
  });

  final SearchPgcItemModel item;

  @override
  Widget build(BuildContext context) {
    void onLongPress() => imageSaveDialog(
      title: item.title.map((e) => e.text).join(),
      cover: item.cover,
    );
    return Card(
      shape: const RoundedRectangleBorder(borderRadius: StyleString.mdRadius),
      child: InkWell(
        borderRadius: StyleString.mdRadius,
        onLongPress: onLongPress,
        onSecondaryTap: Utils.isMobile ? null : onLongPress,
        onTap: () => PageUtils.viewPgc(seasonId: item.seasonId),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 0.75,
              child: LayoutBuilder(
                builder: (context, boxConstraints) {
                  final double maxWidth = boxConstraints.maxWidth;
                  final double maxHeight = boxConstraints.maxHeight;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      NetworkImgLayer(
                        src: item.cover,
                        width: maxWidth,
                        height: maxHeight,
                      ),
                      PBadge(
                        text: item.seasonTypeName,
                        right: 6,
                        top: 6,
                      ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 5, 0, 3),
              child: Text(
                item.title.map((e) => e.text).join(),
                textAlign: TextAlign.start,
                style: const TextStyle(
                  letterSpacing: 0.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
