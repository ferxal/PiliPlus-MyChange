import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:piliplus/grpc/grpc_req.dart';
import 'package:piliplus/http/init.dart';
import 'package:piliplus/services/service_locator.dart';
import 'package:piliplus/utils/accounts.dart';
import 'package:piliplus/utils/app_scheme.dart';
import 'package:piliplus/utils/cache_manage.dart';
import 'package:piliplus/utils/update.dart';
import 'package:catcher_2/catcher_2.dart';
import 'package:piliplus/plugin/pl_player/controller.dart';

/// 初始化服务
Future<void> initService() async {
  await setupServiceLocator();
}

/// 初始化 HTTP 客户端
Future<void> initHttp() async {
  // Request.init(); // 移除错误调用
  // Request 实例会在首次使用时自动初始化，无需手动调用
  
  // 初始化 gRPC 请求头（私信等功能需要）
  GrpcReq.updateHeaders(Accounts.main.accessKey);
}

/// 初始化异常捕获器
Future<void> initCatcher() async {
  // TODO: 实现 Catcher 配置
}

/// 初始化 WebView
Future<void> initInAppWebView() async {
  try {
    await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  } catch (e) {
    // setWebContentsDebuggingEnabled 在某些平台（如 Windows）上未实现
    // 捕获异常以避免程序崩溃
    print('WebView debugging setup skipped: $e');
  }
}

/// 初始化更新检查
Future<void> initUpdate() async {
  // TODO: 实现更新检查逻辑
}

/// 初始化应用程序 Scheme 处理
Future<void> initAppScheme() async {
  PiliScheme.init();
}

/// 初始化缓存管理
Future<void> initCacheManage() async {
  // await CacheManage.init(); // 移除错误调用
  // CacheManage 无需初始化，相关方法直接调用即可
}

/// 初始化播放器
Future<void> initPlayer() async {
  // await PlPlayerController.init(); // 移除错误调用
  // PlPlayerController 通过 getInstance() 获取，无需单独初始化
}