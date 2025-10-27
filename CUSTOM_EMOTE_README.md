# 自定义表情包功能使用说明

## 功能概述

PiliPlus现已支持在私信模块的表情包面板中添加自定义表情包。自定义表情包通过YAML配置文件进行管理，可以从云端URL或本地文件加载，并与哔哩哔哩官方表情包完美融合。

## 功能特性

- ✅ 支持云端HTTP/HTTPS URL加载
- ✅ 支持本地文件路径加载
- ✅ 与B站官方表情包无缝融合
- ✅ 支持动图和静图
- ✅ 支持表情有效期设置
- ✅ 容错机制，单个源加载失败不影响其他源
- ✅ 可视化配置界面
- ✅ **集中配置文件管理**（`config/emoji_sources.yaml`）

## 使用方法

### 方式一：集中配置文件（推荐）

**适用场景**：批量管理多个表情包数据源，适合开发者和高级用户

1. 编辑 `config/emoji_sources.yaml` 文件
2. 在 `sources` 列表中添加表情包数据源：
   ```yaml
   sources:
     - url: "test.yaml"
       name: "测试表情包"
       enabled: true
     
     - url: "https://example.com/emotes.yaml"
       name: "远程表情包"
       enabled: true
   ```
3. 保存文件后重启应用即可自动加载

**优势**：
- 批量管理多个数据源
- 可以启用/禁用单个数据源
- 配置持久化，不会丢失
- 适合团队共享配置

### 方式二：UI界面配置

**适用场景**：临时添加单个表情包，适合普通用户

在私信聊天界面中：
1. 点击输入框左侧的表情按钮
2. 在表情面板底部点击 "➕" 图标（加号按钮）
3. 进入"自定义表情包"配置页面
4. 在URL输入框中输入YAML配置文件的URL或本地路径
5. 点击"添加"按钮
6. 表情包将自动加载并显示在表情面板中

支持的URL格式：
- 远程URL：`https://example.com/emotes.yaml`
- 本地文件：`C:\Users\YourName\Documents\emotes.yaml` (Windows)
- 本地文件：`/home/user/emotes.yaml` (Linux)

**管理表情包**：
- **查看**：所有添加的配置URL会显示在列表中
- **删除**：点击配置项右侧的删除按钮可移除表情包

### 数据源优先级

配置文件中的数据源会优先加载，UI配置的数据源会追加在后面（自动去重）。

## YAML配置文件格式

### 基本结构

```yaml
config:
  version: "1.0.0"
  updated_at: "2024-01-15T10:30:00Z"

categories:
  - id: "category_id"
    name: "分类名称"
    description: "分类描述"
    emojis:
      - name: "表情名称"
        code: ":emoji_code:"
        url: "https://example.com/emoji.gif"
        file_size: 45800
        animated: true
        validity:
          start: "*"
          end: "*"
```

### 字段说明

#### config（配置信息）
- `version`: 配置文件版本号
- `updated_at`: 最后更新时间

#### categories（表情包分类）
- `id`: 分类唯一标识（字符串）
- `name`: 分类显示名称
- `description`: 分类描述（可选）
- `emojis`: 该分类下的表情包数组

#### emojis（表情包）
- `name`: 表情包名称
- `code`: **表情包代码，格式必须为 `[meme]`（中括号），与B站表情包格式一致**
  - ✅ 正确：`[honkai3_pure_3]`
  - ❌ 错误：`:honkai3_pure_3:`
- `url`: 表情包图片URL（支持GIF、PNG、JPG、WEBP等格式，支持外部CDN）
- `file_size`: 文件大小（字节，可选，用于优化预加载）
- `animated`: 是否为动图（true/false）
- `validity`: 生效时间范围（可选）
  - `start`: 开始时间（ISO 8601格式，或 "*" 表示永久）
  - `end`: 结束时间（ISO 8601格式，或 "*" 表示永久）

### 示例配置

参考项目根目录下的 `test.yaml` 文件：

```yaml
config:
  version: "1.1.0"
  updated_at: "2024-01-15T10:30:00Z"

categories:
  - id: "honkai3"
    name: "崩坏3"
    description: "崩坏3系列表情包"
    emojis:
      - name: "崩坏3-纯净-3"
        code: "[honkai3_pure_3]"  # 注意：使用中括号格式
        url: "https://cdn.jsdelivr.net/gh/2x-ercha/twikoo-magic@master/image/HONKAI3-Pure/11.gif"
        file_size: 45800
        animated: true
        validity:
          start: "*"
          end: "*"

      - name: "崩坏3-纯净-4"
        code: "[honkai3_pure_4]"  # 注意：使用中括号格式
        url: "https://cdn.jsdelivr.net/gh/2x-ercha/twikoo-magic@master/image/HONKAI3-Pure/12.gif"
        file_size: 51200
        animated: true
        validity:
          start: "*"
          end: "*"
```

## 快速测试

### 方法1：使用预配置的配置文件（最简单）

应用已内置 `config/emoji_sources.yaml` 配置文件，其中包含了 `test.yaml` 作为示例数据源：

1. 直接运行应用 `flutter run`
2. 进入任意私信对话
3. 点击表情按钮打开表情面板
4. 应该能看到B站官方表情包后面新增了"崩坏3"分类

### 方法2：通过UI添加（传统方式）

1. 打开自定义表情包配置页面
2. 输入test.yaml的完整路径，例如：
   - Windows: `C:\chenHen\Code\PiliPlus-MyChange\test.yaml`
   - 或使用相对路径（如果支持）
3. 点击"添加"按钮
4. 返回私信界面，打开表情面板
5. 应该能看到B站官方表情包后面新增了"崩坏3"分类

## 技术实现

### 核心组件

1. **CustomEmoteService** (`lib/services/custom_emote_service.dart`)
   - 负责从URL或本地文件加载YAML配置
   - 支持从配置文件批量加载数据源
   - 解析YAML并转换为表情包数据模型
   - 处理表情包有效期验证
   - 多位置查找配置文件（应用文档目录、assets、当前目录）

2. **配置文件** (`config/emoji_sources.yaml`)
   - 集中管理所有表情包数据源
   - 支持启用/禁用单个数据源
   - 打包在应用assets中，开箱即用

3. **EmotePanelController** (`lib/pages/emote/controller.dart`)
   - 融合B站官方表情包和自定义表情包
   - 统一管理表情包数据源

4. **CustomEmoteSettingPage** (`lib/pages/custom_emote_setting/`)
   - 提供可视化的配置管理界面
   - 支持添加、删除配置URL

### 数据存储

1. **配置文件存储**（优先）
   - 文件：`config/emoji_sources.yaml`
   - 位置：应用assets或文档目录
   - 打包在应用中，支持离线使用

2. **用户配置存储**（补充）
   - 存储：Hive数据库
   - Key: `customEmoteUrls`
   - Type: `List<String>`
   - 位置: `GStorage.setting`

### 配置文件查找顺序

1. 应用文档目录：`{DocumentsDir}/config/emoji_sources.yaml`
2. 应用assets：`config/emoji_sources.yaml`（打包在应用内）
3. 当前工作目录：`config/emoji_sources.yaml`（开发环境）

### 容错机制

- 单个源加载失败不影响其他源
- B站表情包加载失败时仍可显示自定义表情包
- 自定义表情包加载失败时仍可显示B站表情包
- 解析错误会在控制台输出，不会导致应用崩溃

## 注意事项

1. **网络要求**：加载远程URL需要网络连接，请确保URL可访问
2. **文件权限**：加载本地文件需要有读取权限
3. **图片格式**：建议使用常见图片格式（GIF、PNG、JPG、WEBP）
4. **文件大小**：建议单个表情包图片不超过1MB，以保证加载速度
5. **YAML格式**：配置文件必须是有效的YAML格式，否则解析会失败
6. **缓存**：表情包图片会被缓存，首次加载可能较慢

## 常见问题

### Q: 添加配置后没有显示表情包？
A: 
- 检查URL或文件路径是否正确
- 检查YAML格式是否有效
- 查看控制台是否有错误日志
- 尝试重新加载表情包面板

### Q: 表情包可以跨平台使用吗？
A: 是的，YAML配置文件是跨平台的，但本地文件路径需要根据操作系统调整。

### Q: 可以添加多少个表情包配置？
A: 理论上没有限制，但建议不要超过10个，以保证加载速度。

### Q: 如何制作自己的表情包配置？
A: 参考 `test.yaml` 的格式创建YAML文件，上传到可访问的URL或保存到本地。

### Q: 配置文件和UI配置有什么区别？
A: 
- **配置文件**：批量管理，配置持久，适合开发者和团队使用
- **UI配置**：单个添加，存储在数据库，适合临时测试
- 两者可以同时使用，会自动合并（去重）

### Q: 如何禁用某个数据源？
A: 在 `config/emoji_sources.yaml` 中将对应数据源的 `enabled` 设置为 `false`。

## 更新日志

### v1.2.2 (2024-01-15) - 性能优化版 🚀
- 🐛 **修复面板显示** - 自定义表情包在面板中正确显示为图片（之前显示为[meme]文本）
- 🐛 **修复刷新丢失** - 发送消息后刷新不再丢失自定义表情包
- ⚡ **性能优化** - 优化大量动图的渲染性能
  - GridView添加cacheExtent预加载
  - 优化图片淡入淡出动画时长
  - 智能判断显示逻辑（根据URL而不是type）

### v1.2.1 (2024-01-15) - 最终修复版 ⭐
- 🐛 **修复加密问题** - 彻底解决表情符被误解密的问题
  - 发送时：表情符不加密，普通文本加密
  - 接收时：表情符不解密，普通文本解密
  - 添加显式的 `[meme]` 格式保护正则表达式
- ✅ **完美兼容** - 官方平台可正常查看自定义表情符文本

### v1.2.0 (2024-01-15)
- 🐛 **修复图片加载失败** - 外部CDN图片现在可以正常显示
- ✨ **支持消息渲染** - 自定义表情包现在会在聊天消息中正确渲染
- 📝 **表情符格式** - 统一使用 `[meme]` 格式（中括号），与B站表情包一致
- ♻️ **优化URL处理** - 只对B站图片URL添加质量参数，避免破坏外部CDN的URL

### v1.1.0 (2024-01-15)
- ✨ 新增集中配置文件系统 (`config/emoji_sources.yaml`)
- ✨ 支持批量管理表情包数据源
- ✨ 支持启用/禁用单个数据源
- ✨ 配置文件打包在应用中，开箱即用
- ♻️ 优化数据源加载逻辑，支持多位置查找

### v1.0.0 (2024-01-15)
- ✨ 首次发布自定义表情包功能
- ✨ 支持YAML配置文件加载
- ✨ 支持云端和本地文件
- ✨ 可视化配置界面
- ✨ 与B站表情包无缝融合
