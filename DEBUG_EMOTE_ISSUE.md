# 表情包加载问题调试指南

## 问题现象
在私信会话的表情包面板中看不到自定义表情包。

## 已修复的问题
1. ✅ 修复了文件加载逻辑，现在支持从assets、文件系统、当前目录多位置查找
2. ✅ 添加了详细的调试日志输出

## 调试步骤

### 1. 确保应用完全重启（重要！）

**问题原因**：修改配置文件后，如果只是热重载，assets中的文件不会更新。

**解决方法**：
```bash
# 停止当前运行的应用（按 Ctrl+C 或关闭应用窗口）
# 然后完全重新运行
flutter run --debug -d windows
```

### 2. 查看控制台输出

运行应用后，在控制台中查找以下日志：

```
=== 开始加载表情包 ===
1. 加载B站官方表情包...
✓ B站表情包加载成功: X个分类
2. 用户配置的URL数量: X
3. 加载自定义表情包...
从配置文件加载到 X 个数据源
总共需要加载 X 个数据源
从assets加载文件: config/emoji_sources.yaml
成功加载数据源: XXX (X个分类)
✓ 自定义表情包加载成功: X个分类
=== 表情包加载完成: 总计X个分类 ===
```

### 3. 检查配置文件

打开 `config/emoji_sources.yaml`，确认：

```yaml
sources:
  - url: "test.yaml"              # 相对路径，从assets加载
    name: "测试表情包"
    enabled: true                  # 必须为true
```

或使用远程URL：
```yaml
sources:
  - url: "https://your-cdn.com/test.yaml"
    name: "远程表情包"
    enabled: true
```

### 4. 验证test.yaml在assets中

确认 `pubspec.yaml` 中包含：
```yaml
flutter:
  assets:
    - config/
    - test.yaml
```

### 5. 测试表情包面板

1. 运行应用
2. 进入任意私信对话
3. 点击输入框左侧的表情按钮
4. 应该能看到：
   - B站官方表情包（若干分类）
   - 自定义表情包（例如"崩坏3"）

## 常见问题排查

### Q1: 看不到任何调试日志
**可能原因**：表情包面板没有被打开
**解决方法**：必须点击表情按钮才会触发加载

### Q2: 日志显示"从assets加载失败"
**可能原因**：文件没有正确打包到assets
**解决方法**：
1. 检查 `pubspec.yaml` 中的assets配置
2. 运行 `flutter clean`
3. 重新运行 `flutter run`

### Q3: 日志显示"无法加载文件"
**可能原因**：
1. 配置文件中URL格式错误
2. 远程URL无法访问
3. 文件路径不正确

**解决方法**：
1. 检查URL是否正确
2. 测试远程URL是否可访问
3. 使用相对路径（如 "test.yaml"）从assets加载

### Q4: 日志显示"YAML格式错误"
**可能原因**：表情包YAML文件格式不正确
**解决方法**：参考 `test.yaml` 的格式，确保：
- 有 `config` 和 `categories` 字段
- 每个分类有 `id`、`name`、`emojis` 字段
- 每个表情有 `name`、`code`、`url` 字段

### Q5: 自定义表情包加载成功但看不到
**可能原因**：TabController长度没有更新
**解决方法**：完全重启应用（不要用热重载）

## 完整测试流程

```bash
# 1. 清理构建
flutter clean

# 2. 获取依赖
flutter pub get

# 3. 运行应用
flutter run --debug -d windows

# 4. 在应用中测试
# - 打开私信
# - 点击表情按钮
# - 查看表情列表

# 5. 查看控制台日志
# 确认表情包是否加载成功
```

## 示例配置（开箱即用）

`config/emoji_sources.yaml`:
```yaml
config:
  version: "1.0.0"

sources:
  - url: "test.yaml"
    name: "测试表情包"
    enabled: true
```

这个配置会从assets加载 `test.yaml`，应该能立即看到效果。

## 获取帮助

如果问题仍然存在，请提供：
1. 完整的控制台日志输出
2. `config/emoji_sources.yaml` 的内容
3. 应用版本和运行平台
