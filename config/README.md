# Config 配置文件夹

此文件夹用于存放 PiliPlus 的各项配置文件。

## 文件说明

### emoji_sources.yaml
表情包数据源配置文件，用于批量管理自定义表情包的加载源。

**功能：**
- 集中管理所有表情包数据源
- 支持本地文件和远程URL
- 支持启用/禁用单个数据源
- 支持添加描述信息便于管理

**使用方法：**
1. 编辑 `emoji_sources.yaml` 文件
2. 在 `sources` 列表中添加表情包YAML文件的URL或路径
3. 保存文件
4. 应用会自动加载配置中启用的所有数据源

**示例：**
```yaml
sources:
  - url: "test.yaml"
    name: "测试表情包"
    enabled: true
  
  - url: "https://example.com/emotes.yaml"
    name: "远程表情包"
    enabled: true
```

## 配置文件格式

所有配置文件使用 YAML 格式，遵循以下基本结构：

```yaml
config:
  version: "1.0.0"
  description: "配置描述"
  updated_at: "更新时间"

# 具体配置项...
```

## 路径解析规则

### 相对路径
相对路径基于应用根目录解析：
- `test.yaml` → 应用根目录下的 test.yaml
- `config/emoji_sources.yaml` → config文件夹下的文件

### 绝对路径
支持操作系统的绝对路径：
- Windows: `C:\Users\Name\Documents\emotes.yaml`
- Linux: `/home/user/emotes.yaml`
- macOS: `/Users/name/Documents/emotes.yaml`

### 远程URL
支持 HTTP/HTTPS 协议：
- `https://cdn.example.com/emotes.yaml`
- `http://example.com/emotes.yaml`

## 注意事项

1. **文件权限**：确保应用有读取配置文件的权限
2. **网络访问**：远程URL需要网络连接
3. **格式正确**：YAML格式必须正确，否则解析会失败
4. **版本管理**：建议使用版本号标识配置文件版本

## 未来扩展

此文件夹将来可能包含：
- `theme_settings.yaml` - 主题配置
- `filter_rules.yaml` - 内容过滤规则
- `shortcut_keys.yaml` - 快捷键配置
- `proxy_settings.yaml` - 代理配置
- 等等...
