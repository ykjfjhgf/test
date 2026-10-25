/// 隐私与安全服务（services/security_service.dart）——R-SET-04
///
/// 密码本：SHA-256 哈希存储（不明文）；锁定时长映射。
library;

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_application_2/data/models/app_settings.dart';

class SecurityService {
  SecurityService._();

  /// SHA-256 哈希（带固定盐前缀，避免与其他场景撞哈希）
  static String hashPassword(String password) {
    final bytes = utf8.encode('diaryapp-salt::$password');
    return sha256.convert(bytes).toString();
  }

  /// 校验密码：明文 + 存量哈希比对（哈希由设置写入，见 settings 页）
  static bool verify(String password, String storedHash) =>
      hashPassword(password) == storedHash;

  /// 锁定时长 → 失效时间（null = 关闭锁定）
  static Duration? lockTimeoutDuration(LockTimeout t) => switch (t) {
        LockTimeout.immediately => Duration.zero,
        LockTimeout.oneMinute => const Duration(minutes: 1),
        LockTimeout.fiveMinutes => const Duration(minutes: 5),
        LockTimeout.off => null,
      };

  /// 是否已锁定：解锁时间 + 锁定时长判定
  static bool isLocked(DateTime? unlockedAt, LockTimeout timeout) {
    final duration = lockTimeoutDuration(timeout);
    if (duration == null) return false; // 关闭
    if (unlockedAt == null) return true; // 从未解锁
    if (duration == Duration.zero) return true; // 离开后立即
    return DateTime.now().difference(unlockedAt) > duration;
  }
}
