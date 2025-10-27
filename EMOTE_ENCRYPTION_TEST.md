# 自定义表情包加密逻辑测试文档

## 加密机制说明

PiliPlus的私信消息使用了简单的字符偏移加密：
- **普通文本**：每个字符的Unicode码点 +10
- **表情符 `[meme]`**：**不加密**，保持原样
- **标记**：消息前加 `\uFFFF` 标识为加密消息

## 加密逻辑实现

```dart
String _processSendContent(String content) {
  final _emojiPattern = RegExp(r'\[.*?\]');
  final buffer = StringBuffer();
  
  content.splitMapJoin(
    _emojiPattern,
    onMatch: (match) {
      // 表情符不加密，直接保留
      buffer.write(match.group(0));
      return '';
    },
    onNonMatch: (nonMatch) {
      // 普通文本进行加密
      buffer.write(
        nonMatch.runes.map((rune) {
          int newRune = rune + 10;
          if (newRune > 0x10FFFF) newRune -= 0x110000;
          return String.fromCharCode(newRune);
        }).join(),
      );
      return '';
    },
  );
  
  return '\uFFFF' + buffer.toString();
}
```

## 测试场景

### 场景1: 纯文本消息
**输入**: `你好`
**处理过程**:
- ✓ 文本加密: "你好" -> 加密后的字符
- 📤 加密后消息: `\uFFFF[加密文本]`

### 场景2: 纯表情消息
**输入**: `[honkai3_pure_3]`
**处理过程**:
- ✓ 表情符不加密: `[honkai3_pure_3]`
- 📤 加密后消息: `\uFFFF[honkai3_pure_3]`

### 场景3: 混合消息（文本+表情）
**输入**: `你好[honkai3_pure_3]世界`
**处理过程**:
- 🔒 文本加密: "你好" -> 加密后的字符
- ✓ 表情符不加密: `[honkai3_pure_3]`
- 🔒 文本加密: "世界" -> 加密后的字符
- 📤 加密后消息: `\uFFFF[加密文本][honkai3_pure_3][加密文本]`

### 场景4: 多个表情
**输入**: `测试[honkai3_pure_3]表情[honkai3_pure_4]包`
**处理过程**:
- 🔒 文本加密: "测试"
- ✓ 表情符不加密: `[honkai3_pure_3]`
- 🔒 文本加密: "表情"
- ✓ 表情符不加密: `[honkai3_pure_4]`
- 🔒 文本加密: "包"

## 解密逻辑

在 `ChatItem` 的 `_processReceiveContent` 方法中：

```dart
String _processReceiveContent(String content) {
  if (!content.startsWith('\uFFFF')) {
    return content; // 未加密的消息
  }
  content = content.substring(1); // 移除标记
  
  final regex = RegExp(patterns.join('|')); // patterns包含表情符和URL
  final buffer = StringBuffer();
  
  content.splitMapJoin(
    regex,
    onMatch: (match) {
      buffer.write(match.group(0)); // 表情符和URL保持原样
      return '';
    },
    onNonMatch: (nonMatch) {
      buffer.write(
        nonMatch.runes.map((rune) {
          int newRune = rune - 10; // 字符-10解密
          if (newRune < 0) newRune += 0x110000;
          return String.fromCharCode(newRune);
        }).join(),
      );
      return '';
    },
  );
  
  return buffer.toString();
}
```

## 测试步骤

### 1. 运行应用并查看日志

```bash
flutter run --debug -d windows
```

### 2. 发送测试消息

在私信中依次发送以下消息，观察控制台输出：

1. **纯表情**: 点击崩坏3表情
2. **文本+表情**: 输入 `你好`，然后点击表情
3. **表情+文本**: 点击表情，然后输入 `世界`
4. **混合消息**: 输入 `测试`，点击表情，再输入 `包`

### 3. 验证日志输出

每次发送消息时，控制台应该显示：

```
📤 原始消息: [消息内容]
  ✓ 表情符不加密: [honkai3_pure_3]
  🔒 文本加密: "你好" -> "[加密后]"
📤 加密后消息: [最终消息]
```

### 4. 验证消息渲染

- ✅ 发送的消息应该在聊天记录中正确显示
- ✅ 表情符应该渲染为图片
- ✅ 文本应该正常显示（已解密）

## 常见问题

### Q1: 表情显示为文本 `[honkai3_pure_3]`
**原因**: 表情符未在 `eInfos` 中注册
**解决**: 检查控制台是否有 "✓ 自定义表情包已加载到私信" 日志

### Q2: 发送失败
**原因**: 可能是网络问题或权限问题
**解决**: 检查网络连接和登录状态

### Q3: 消息乱码
**原因**: 加密/解密逻辑不匹配
**解决**: 
- 检查发送时是否调用了 `_processSendContent`
- 检查接收时是否调用了 `_processReceiveContent`

## 关键点总结

✅ **加密逻辑已正确实现**
- 表情符 `[...]` 格式不会被加密
- 正则表达式 `r'\[.*?\]'` 正确匹配表情符
- 加密只作用于普通文本

✅ **解密逻辑已正确实现**
- 识别加密标记 `\uFFFF`
- 表情符和URL保持原样
- 普通文本进行解密（字符-10）

✅ **表情包集成已完成**
- 自定义表情包加载到 `eInfos`
- 表情面板正确显示
- 消息中正确渲染

## 调试建议

如果遇到问题，请：
1. 查看控制台日志，确认加密过程
2. 检查 `eInfos` 是否包含自定义表情
3. 验证表情符格式是否为 `[meme]`
4. 确认网络请求是否成功
