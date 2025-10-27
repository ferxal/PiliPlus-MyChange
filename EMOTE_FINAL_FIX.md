# 表情包加密问题最终修复方案

## 🔍 问题诊断

### 用户发现的关键线索
- 在PiliPlus客户端发送 `[honkai3_pure_3]` → 显示为 `Q^edaW_)Ufkh[U)S` (乱码)
- 在官方平台查看同一消息 → 显示为 `[honkai3_pure_3]` (正常)

### 根本原因
**表情符没有被加密，但被误判为加密消息并被解密了！**

```
发送流程（之前的错误）：
[honkai3_pure_3] → 添加标记 → ￿[honkai3_pure_3]

接收流程（PiliPlus）：
￿[honkai3_pure_3] → 看到￿标记 → 认为是加密消息 
→ 对整个内容解密（字符-10）→ Q^edaW_)Ufkh[U)S ❌

接收流程（官方平台）：
￿[honkai3_pure_3] → 没有解密逻辑 → 直接显示 [honkai3_pure_3] ✅
```

## ✅ 修复方案

### 核心原则
**[meme]格式的内容在发送和接收时都不进行任何加密/解密处理**

### 修改1: 发送逻辑 (`lib/pages/whisper_detail/controller.dart`)

```dart
String _processSendContent(String content) {
  final buffer = StringBuffer();
  content.splitMapJoin(
    RegExp(r'\[.*?\]'),  // 匹配所有[...]格式
    onMatch: (match) {
      buffer.write(match.group(0));  // ✅ 表情符保持原样，不加密
      return '';
    },
    onNonMatch: (nonMatch) {
      if (nonMatch.isNotEmpty) {
        // 🔒 只加密普通文本
        final encrypted = nonMatch.runes.map((rune) {
          int newRune = rune + 10;
          if (newRune > 0x10FFFF) newRune -= 0x110000;
          return String.fromCharCode(newRune);
        }).join();
        buffer.write(encrypted);
      }
      return '';
    },
  );
  return '\uFFFF' + buffer.toString();  // 添加加密标记
}
```

### 修改2: 接收逻辑 (`lib/pages/whisper_detail/widget/chat_item.dart`)

#### 添加表情符保护
```dart
final List<String> patterns = [
  Constants.urlRegex.pattern,
  r'\[[\w_]+\]',  // ⭐ 添加自定义表情包格式保护
];
```

#### 解密时跳过表情符
```dart
String _processReceiveContent(String content) {
  if (!content.startsWith('\uFFFF')) {
    return content;  // 没有加密标记，直接返回
  }
  content = content.substring(1);  // 移除￿标记
  
  final regex = RegExp(patterns.join('|'));
  final buffer = StringBuffer();
  content.splitMapJoin(
    regex,
    onMatch: (match) {
      buffer.write(match.group(0));  // ✅ URL和表情符不解密
      return '';
    },
    onNonMatch: (nonMatch) {
      // 🔓 只解密普通文本
      buffer.write(
        nonMatch.runes.map((rune) {
          int newRune = rune - 10;
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

## 📊 完整流程示例

### 场景1: 纯表情消息
```
发送：[honkai3_pure_3]
↓
加密处理：
  ✓ 表情符不加密: [honkai3_pure_3]
  结果: ￿[honkai3_pure_3]
↓
服务器存储：￿[honkai3_pure_3]
↓
接收解密：
  检测到￿标记
  匹配 [honkai3_pure_3] → 不解密
  结果: [honkai3_pure_3]
↓
渲染：显示为崩坏3表情图片 ✅
```

### 场景2: 混合消息
```
发送：你好[honkai3_pure_3]世界
↓
加密处理：
  🔒 文本加密: "你好"
  ✓ 表情符不加密: [honkai3_pure_3]
  🔒 文本加密: "世界"
  结果: ￿[加密]你好[honkai3_pure_3][加密]世界
↓
服务器存储：￿[加密]你好[honkai3_pure_3][加密]世界
↓
接收解密：
  检测到￿标记
  解密文本部分
  匹配 [honkai3_pure_3] → 不解密
  结果: 你好[honkai3_pure_3]世界
↓
渲染：
  - "你好" 显示为文本
  - [honkai3_pure_3] 显示为表情图片
  - "世界" 显示为文本
  ✅
```

### 场景3: 纯文本
```
发送：你好
↓
加密处理：
  🔒 文本加密: "你好"
  结果: ￿[加密]你好
↓
服务器存储：￿[加密]你好
↓
接收解密：
  检测到￿标记
  🔓 解密文本: "你好"
  结果: 你好
↓
渲染：显示为 "你好" ✅
```

## 🔑 关键修改点

### 1. 发送端 (`controller.dart`)
- ✅ 保留 `splitMapJoin` 逻辑
- ✅ 表情符匹配正则：`r'\[.*?\]'`
- ✅ 表情符不加密，普通文本加密
- ✅ 添加 `\uFFFF` 标记

### 2. 接收端 (`chat_item.dart`)
- ✅ 添加表情符保护正则：`r'\[[\w_]+\]'`
- ✅ patterns 包含：URL正则 + 表情符正则 + eInfos中的表情
- ✅ 解密时跳过匹配的表情符
- ✅ 渲染时查找 emojiMap，有则显示图片，无则显示文本

### 3. 表情包配置 (`custom_emote_service.dart`)
- ✅ `type = 4` (文本表情)
- ✅ 表情符格式：`[meme]` (中括号)

## 🧪 测试验证

### 控制台日志

#### 发送时
```
📤 原始消息: 你好[honkai3_pure_3]世界
  🔒 文本加密: "你好" -> "[加密后]"
  ✓ 表情符不加密: [honkai3_pure_3]
  🔒 文本加密: "世界" -> "[加密后]"
📤 加密后消息: ￿[加密]你好[honkai3_pure_3][加密]世界
```

#### 接收时（隐式）
- 检测 `\uFFFF` 标记
- 解密普通文本
- 保留表情符原样
- 结果：`你好[honkai3_pure_3]世界`

### 运行测试
```bash
flutter clean
flutter run --debug -d windows
```

1. 进入私信对话
2. 点击表情 → 发送 `[honkai3_pure_3]`
3. 观察控制台输出
4. 验证消息渲染为图片
5. 在官方平台查看，应该显示 `[honkai3_pure_3]`

## 📋 修改文件清单

| 文件 | 修改内容 | 状态 |
|------|---------|------|
| `lib/pages/whisper_detail/controller.dart` | 发送端：splitMapJoin部分加密 | ✅ |
| `lib/pages/whisper_detail/widget/chat_item.dart` | 接收端：添加表情符保护正则 | ✅ |
| `lib/services/custom_emote_service.dart` | type=4，表情符格式[meme] | ✅ |
| `lib/utils/image_utils.dart` | 修复外部CDN图片加载 | ✅ |
| `test.yaml` | 表情符格式改为[meme] | ✅ |

## 🎯 预期结果

### PiliPlus客户端
- ✅ 发送 `[honkai3_pure_3]` → 显示为表情图片
- ✅ 接收 `[honkai3_pure_3]` → 显示为表情图片
- ✅ 混合消息正确处理

### 官方平台
- ✅ 显示 `[honkai3_pure_3]` 文本（官方不识别自定义表情）

### 兼容性
- ✅ B站官方表情正常工作
- ✅ URL不被破坏
- ✅ 普通文本正常加密

## 🚀 完成！

现在自定义表情包将完全不受加密/解密影响，同时保持与B站官方表情包的完美兼容！
