import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliplus/pages/custom_emote_setting/controller.dart';

class CustomEmoteSettingPage extends StatefulWidget {
  const CustomEmoteSettingPage({super.key});

  @override
  State<CustomEmoteSettingPage> createState() => _CustomEmoteSettingPageState();
}

class _CustomEmoteSettingPageState extends State<CustomEmoteSettingPage> {
  final CustomEmoteSettingController _controller = Get.put(CustomEmoteSettingController());

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('自定义表情包'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: '帮助',
            onPressed: _showHelp,
          ),
        ],
      ),
      body: Column(
        children: [
          // URL输入区域
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller.urlController,
                    decoration: const InputDecoration(
                      labelText: 'YAML配置文件URL或本地路径',
                      hintText: 'https://example.com/emotes.yaml',
                      border: OutlineInputBorder(),
                      helperText: '支持HTTP/HTTPS远程URL或本地文件路径',
                    ),
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () {
                    _controller.addUrl(_controller.urlController.text.trim());
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('添加'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // URL列表
          Expanded(
            child: Obx(() {
              if (_controller.emoteUrls.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emoji_emotions_outlined,
                        size: 64,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '暂无自定义表情包',
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '点击上方添加按钮添加YAML配置文件',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: _controller.emoteUrls.length,
                padding: const EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  final url = _controller.emoteUrls[index];
                  final isLocal = !url.startsWith('http://') && !url.startsWith('https://');

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: ListTile(
                      leading: Icon(
                        isLocal ? Icons.folder : Icons.cloud,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(
                        url,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(isLocal ? '本地文件' : '远程URL'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: '删除',
                        onPressed: () => _showDeleteConfirm(context, index),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个表情包配置吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _controller.removeUrl(index);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('使用说明'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'YAML配置文件格式：',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '配置文件应包含以下结构：\n'
                '• config: 版本信息\n'
                '• categories: 表情包分类列表\n'
                '  - id: 分类ID\n'
                '  - name: 分类名称\n'
                '  - emojis: 表情列表\n'
                '    - name: 表情名称\n'
                '    - code: 表情代码\n'
                '    - url: 图片URL\n'
                '    - animated: 是否动图\n'
                '    - validity: 有效期',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              const Text(
                '示例：',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '参考项目根目录下的 test.yaml 文件',
                  style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<CustomEmoteSettingController>();
    super.dispose();
  }
}
