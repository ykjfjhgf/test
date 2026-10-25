/// 语音转文字服务（services/voice_service.dart）——R-EDI-05
///
/// 平台能力封装占位：正式实现需接入 speech_to_text（Android/iOS）或
/// 系统语音识别；桌面端可走 Web Speech / 第三方转写。接口先行，
/// 编辑器工具条「语音」已接入调用点。
library;

class VoiceService {
  VoiceService._();

  /// 录制并转写为文本；未接入平台能力时返回空并提示
  static Future<String> voiceToText() async {
    // TODO(0.2.0): 接入 speech_to_text / 系统识别，返回转写文本
    return '';
  }
}
