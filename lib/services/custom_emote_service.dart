import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Response;
import 'package:path_provider/path_provider.dart';
import 'package:piliplus/http/loading_state.dart';
import 'package:piliplus/models_new/emote/emote.dart';
import 'package:piliplus/models_new/emote/meta.dart';
import 'package:piliplus/models_new/emote/package.dart';
import 'package:yaml/yaml.dart';

/// 自定义表情包服务
/// 支持从云端或本地YAML文件加载表情包
class CustomEmoteService extends GetxService {
  static CustomEmoteService get instance => Get.find<CustomEmoteService>();
  
  static const String _configFileName = 'emoji_sources.yaml';
  static const String _configFolderName = 'config';
  
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
  ));

  /// 从配置文件和用户配置加载所有表情包
  /// 优先级：配置文件 -> 用户UI配置
  Future<LoadingState<List<Package>>> loadEmotePackages(List<String> userUrls) async {
    try {
      final List<Package> allPackages = [];
      
      // 1. 从配置文件加载
      final configUrls = await _loadSourcesFromConfig();
      print('从配置文件加载到 ${configUrls.length} 个数据源');
      
      // 2. 合并用户配置的URL（去重）
      final allUrls = <String>[
        ...configUrls,
        ...userUrls.where((url) => !configUrls.contains(url)),
      ];
      
      if (allUrls.isEmpty) {
        print('没有配置任何表情包数据源');
        return const Error('没有配置任何表情包数据源');
      }
      
      print('总共需要加载 ${allUrls.length} 个数据源');
      
      // 3. 加载所有数据源
      for (String url in allUrls) {
        try {
          final packages = await _loadSingleSource(url);
          allPackages.addAll(packages);
          print('成功加载数据源: $url (${packages.length}个分类)');
        } catch (e) {
          print('加载表情包失败: $url, 错误: $e');
          // 继续加载其他源，不中断
        }
      }
      
      if (allPackages.isEmpty) {
        return const Error('无法加载任何自定义表情包');
      }
      
      print('成功加载 ${allPackages.length} 个表情包分类');
      return Success(allPackages);
    } catch (e) {
      print('加载自定义表情包异常: $e');
      return Error('加载自定义表情包失败: $e');
    }
  }
  
  /// 从配置文件加载数据源列表
  Future<List<String>> _loadSourcesFromConfig() async {
    try {
      // 尝试从多个位置读取配置文件
      String? configContent;
      
      // 1. 尝试从应用文档目录读取
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final configFile = File('${appDir.path}/$_configFolderName/$_configFileName');
        if (await configFile.exists()) {
          configContent = await configFile.readAsString(encoding: utf8);
          print('从应用文档目录加载配置: ${configFile.path}');
        }
      } catch (e) {
        print('从应用文档目录读取配置失败: $e');
      }
      
      // 2. 尝试从assets读取（打包在应用中）
      if (configContent == null) {
        try {
          configContent = await rootBundle.loadString('$_configFolderName/$_configFileName');
          print('从assets加载配置文件');
        } catch (e) {
          print('从assets读取配置失败: $e');
        }
      }
      
      // 3. 尝试从当前目录读取（开发环境）
      if (configContent == null) {
        try {
          final configFile = File('$_configFolderName/$_configFileName');
          if (await configFile.exists()) {
            configContent = await configFile.readAsString(encoding: utf8);
            print('从当前目录加载配置: ${configFile.path}');
          }
        } catch (e) {
          print('从当前目录读取配置失败: $e');
        }
      }
      
      if (configContent == null) {
        print('未找到配置文件，将只使用用户配置的数据源');
        return [];
      }
      
      return _parseSourceConfig(configContent);
    } catch (e) {
      print('加载配置文件异常: $e');
      return [];
    }
  }
  
  /// 解析配置文件内容
  List<String> _parseSourceConfig(String yamlContent) {
    try {
      final dynamic yamlDoc = loadYaml(yamlContent);
      
      if (yamlDoc is! YamlMap) {
        print('配置文件格式错误：根节点必须是Map');
        return [];
      }
      
      final sources = yamlDoc['sources'];
      if (sources == null || sources is! YamlList) {
        print('配置文件缺少sources字段或格式不正确');
        return [];
      }
      
      final List<String> urls = [];
      
      for (var source in sources) {
        if (source is! YamlMap) continue;
        
        // 检查是否启用（默认为true）
        final enabled = source['enabled'] ?? true;
        if (enabled != true) {
          final name = source['name'] ?? source['url'];
          print('跳过已禁用的数据源: $name');
          continue;
        }
        
        final url = source['url']?.toString();
        if (url != null && url.isNotEmpty) {
          urls.add(url);
        }
      }
      
      return urls;
    } catch (e) {
      print('解析配置文件失败: $e');
      return [];
    }
  }

  /// 从单个源加载表情包
  Future<List<Package>> _loadSingleSource(String source) async {
    String yamlContent;
    
    if (source.startsWith('http://') || source.startsWith('https://')) {
      // 从网络加载
      yamlContent = await _loadFromUrl(source);
    } else {
      // 从本地文件或assets加载
      yamlContent = await _loadFromFileOrAssets(source);
    }
    
    return _parseYaml(yamlContent);
  }

  /// 从URL加载YAML内容
  Future<String> _loadFromUrl(String url) async {
    try {
      final response = await _dio.get(
        url,
        options: Options(
          responseType: ResponseType.plain,
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        return response.data.toString();
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('网络请求失败: $e');
    }
  }

  /// 从本地文件或assets加载YAML内容
  Future<String> _loadFromFileOrAssets(String path) async {
    // 1. 首先尝试从assets加载（适用于相对路径）
    if (!path.startsWith('/') && !path.contains(':')) {
      try {
        final content = await rootBundle.loadString(path);
        print('从assets加载文件: $path');
        return content;
      } catch (e) {
        print('从assets加载失败: $path, 尝试文件系统...');
      }
    }
    
    // 2. 尝试作为绝对路径从文件系统加载
    try {
      final file = File(path);
      if (await file.exists()) {
        print('从文件系统加载: ${file.path}');
        return await file.readAsString(encoding: utf8);
      }
    } catch (e) {
      print('从文件系统加载失败: $path, $e');
    }
    
    // 3. 尝试从当前目录加载（开发环境）
    try {
      final currentDir = Directory.current;
      final file = File('${currentDir.path}/$path');
      if (await file.exists()) {
        print('从当前目录加载: ${file.path}');
        return await file.readAsString(encoding: utf8);
      }
    } catch (e) {
      print('从当前目录加载失败: $path, $e');
    }
    
    throw Exception('无法加载文件: $path（已尝试assets、文件系统、当前目录）');
  }

  /// 解析YAML内容并转换为Package列表
  List<Package> _parseYaml(String yamlContent) {
    try {
      final dynamic yamlDoc = loadYaml(yamlContent);
      
      if (yamlDoc is! YamlMap) {
        throw Exception('YAML格式错误：根节点必须是Map');
      }
      
      final categories = yamlDoc['categories'];
      if (categories == null || categories is! YamlList) {
        throw Exception('YAML格式错误：缺少categories字段或格式不正确');
      }
      
      final List<Package> packages = [];
      final now = DateTime.now();
      
      for (var category in categories) {
        if (category is! YamlMap) continue;
        
        final String? categoryId = category['id']?.toString();
        final String? categoryName = category['name']?.toString();
        final emojis = category['emojis'];
        
        if (categoryId == null || categoryName == null || emojis is! YamlList) {
          continue;
        }
        
        final List<Emote> emoteList = [];
        String? packageUrl;
        
        for (var emoji in emojis) {
          if (emoji is! YamlMap) continue;
          
          final String? name = emoji['name']?.toString();
          final String? code = emoji['code']?.toString();
          final String? url = emoji['url']?.toString();
          final bool animated = emoji['animated'] == true;
          
          // 检查有效期
          if (!_isValidEmote(emoji, now)) {
            continue;
          }
          
          if (code != null && url != null) {
            // 使用第一个表情的URL作为分类封面
            packageUrl ??= url;
            
            emoteList.add(Emote(
              text: code,
              url: url,
              meta: Meta(
                alias: name,
                size: animated ? 2 : 1, // 动图设为2，静图设为1
              ),
            ));
          }
        }
        
        if (emoteList.isNotEmpty && packageUrl != null) {
          packages.add(Package(
            url: packageUrl,
            type: 4, // type=4 表示文本表情，直接插入文本而不加密
            emote: emoteList,
          ));
        }
      }
      
      return packages;
    } catch (e) {
      throw Exception('YAML解析失败: $e');
    }
  }

  /// 检查表情是否在有效期内
  bool _isValidEmote(YamlMap emoji, DateTime now) {
    final validity = emoji['validity'];
    if (validity == null || validity is! YamlMap) {
      return true; // 没有有效期限制
    }
    
    final startStr = validity['start']?.toString();
    final endStr = validity['end']?.toString();
    
    if (startStr == '*' || startStr == null) {
      // 无起始时间限制
    } else {
      try {
        final start = DateTime.parse(startStr);
        if (now.isBefore(start)) {
          return false;
        }
      } catch (e) {
        // 解析失败，忽略
      }
    }
    
    if (endStr == '*' || endStr == null) {
      // 无结束时间限制
    } else {
      try {
        final end = DateTime.parse(endStr);
        if (now.isAfter(end)) {
          return false;
        }
      } catch (e) {
        // 解析失败，忽略
      }
    }
    
    return true;
  }

  @override
  void onClose() {
    _dio.close();
    super.onClose();
  }
}
