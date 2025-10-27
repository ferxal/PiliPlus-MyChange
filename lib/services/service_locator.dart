import 'package:get/get.dart';
import 'package:piliplus/services/account_service.dart';
import 'package:piliplus/services/audio_handler.dart';
import 'package:piliplus/services/audio_session.dart';

VideoPlayerServiceHandler? videoPlayerServiceHandler;
AudioSessionHandler? audioSessionHandler;

Future<void> setupServiceLocator() async {
  // 注册 AccountService
  Get.put(AccountService());
  
  final audio = await initAudioService();
  videoPlayerServiceHandler = audio;
  audioSessionHandler = AudioSessionHandler();
}
