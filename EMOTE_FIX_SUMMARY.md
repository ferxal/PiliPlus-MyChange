# 表情包加密问题修复总结

## 问题描述

用户发送 `[honkai3_pure_3]` 时被加密为 `Q^edaW_)Ufkh[U)S`，导致无法正常渲染。

## 根本原因

自定义表情包的 `Package.type` 设置为 100，导致：
1. 在表情面板中，`isTextEmote = (e.type == 4)` 判断为 false
2. 点击表情时，调用 `onChooseEmote(item, width, height)` 时 `width != null`
3. 在 `onInsertText` 中插入的是 `\uFFFC` 而不是表情符文本
4. 发送时，`editController.rawText` 获取的是 `\uFFFC`，不会触发表情符保护逻辑
5. 整个文本被加密

## 解决方案

**修改 `lib/services/custom_emote_service.dart`**

```dart
// 之前：
type: 100, // 使用特殊类型标识自定义表情包

// 修改为：
type: 4, // type=4 表示文本表情，直接插入文本而不加密
```

## 工作原理

### type=4（文本表情）
1. `isTextEmote = (e.type == 4)` → true
2. 点击表情时：`onChooseEmote(item, null, null)` （width=null）
3. 在 `onInsertText` 中：
   ```dart
   onInsertText(
     emote.text!,  // 直接插入 "[honkai3_pure_3]"
     RichTextType.emoji,
     rawText: emote.text!,
     emote: null,  // 不设置图片表情
   );
   ```
4. `editController.rawText` 包含 `[honkai3_pure_3]`
5. 发送时，`_processSendContent` 正则匹配到表情符，**不加密**

### type≠4（图片表情）
1. `isTextEmote = false`
2. 点击表情时：`onChooseEmote(item, width, height)`
3. 在 `onInsertText` 中：
   ```dart
   onInsertText(
     '\uFFFC',  // 插入占位符
     RichTextType.emoji,
     rawText: emote.text!,
     emote: Emote(...),  // 设置图片表情信息
   );
   ```
4. `editController.rawText` 包含 `\uFFFC`
5. 发送时，`\uFFFC` 被整体加密

## 加密保护逻辑验证

`_processSendContent` 方法：

```dart
final _emojiPattern = RegExp(r'\[.*?\]');

String _processSendContent(String content) {
  content.splitMapJoin(
    _emojiPattern,
    onMatch: (match) {
      buffer.write(match.group(0)); // ✅ 表情符不加密
      return '';
    },
    onNonMatch: (nonMatch) {
      buffer.write(encrypted); // 🔒 普通文本加密
      return '';
    },
  );
}
```

## 测试步骤

1. 运行应用：
   ```bash
   flutter run --debug -d windows
   ```

2. 进入私信对话

3. 点击表情按钮 → 切换到"崩坏3"标签

4. 点击表情，观察控制台输出：
   ```
   📤 原始消息: [honkai3_pure_3]
     ✓ 表情符不加密: [honkai3_pure_3]
   📤 加密后消息: ￿[honkai3_pure_3]
   ```

5. 发送消息，验证：
   - ✅ 消息正常发送
   - ✅ 表情符未被加密
   - ✅ 接收方能正确渲染为图片

## 预期效果

### 发送前
- 输入框显示：`[honkai3_pure_3]`

### 发送时（加密）
- 原始消息：`[honkai3_pure_3]`
- 加密后：`￿[honkai3_pure_3]` （表情符保持原样）

### 接收时（解密）
- 服务器存储：`￿[honkai3_pure_3]`
- 解密后：`[honkai3_pure_3]`
- 渲染：显示为崩坏3表情图片

## 关键代码路径

1. **表情面板**：`lib/pages/emote/view.dart`
   - `isTextEmote = e.type == 4`

2. **选择表情**：`lib/pages/common/publish/common_rich_text_pub_page.dart`
   - `onChooseEmote()` → `onInsertText()`

3. **发送消息**：`lib/pages/whisper_detail/controller.dart`
   - `sendMsg()` → `_processSendContent()`

4. **加密保护**：`_processSendContent()`
   - 正则匹配 `\[.*?\]`，不加密

5. **接收渲染**：`lib/pages/whisper_detail/widget/chat_item.dart`
   - `msgTypeText_1()` → 识别表情符并渲染

## 相关文件修改

- ✅ `lib/services/custom_emote_service.dart` - 修改 type 为 4
- ✅ `lib/pages/whisper_detail/controller.dart` - 添加加密日志
- ✅ `lib/utils/image_utils.dart` - 修复外部CDN图片加载
- ✅ `test.yaml` - 表情符格式改为 `[meme]`

## 完成状态

🎉 **问题已修复！**

自定义表情包现在会：
1. ✅ 在表情面板中正确显示图片
2. ✅ 点击后插入表情符文本 `[honkai3_pure_3]`
3. ✅ 发送时表情符不被加密
4. ✅ 接收时正确渲染为图片
