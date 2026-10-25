/// 应用根组件（app/app.dart）
///
/// 读取全局设置流，动态装配主题（R-SET-01/02）；路由集中注册；
/// 主框架挂载 HomeShell。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_2/app/routes.dart';
import 'package:flutter_application_2/app/shell/home_shell.dart';
import 'package:flutter_application_2/core/theme/app_theme.dart';
import 'package:flutter_application_2/data/models/app_settings.dart';
import 'package:flutter_application_2/data/providers.dart';
import 'package:flutter_application_2/features/editor/presentation/editor_page.dart';
import 'package:flutter_application_2/features/editor/presentation/editor_provider.dart';

class DiaryApp extends ConsumerWidget {
  const DiaryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(settingsProvider).value ?? AppSettings.defaults;
    final primary = AppTheme.primaryOf(settings);

    return MaterialApp(
      title: '日记',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(primary),
      darkTheme: AppTheme.dark(primary),
      themeMode: AppTheme.themeModeOf(settings),
      initialRoute: AppRoutes.home,
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.editor) {
          final args = settings.arguments as Map<String, dynamic>? ?? const {};
          final date = DateTime.tryParse(args['date'] as String? ?? '') ?? DateTime.now();
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => ProviderScope(
              overrides: [
                editorProvider.overrideWith(() =>
                    EditorNotifier(args: EditorArgs(
                      date: date,
                      entryId: args['entryId'] as String?,
                    ))),
              ],
              child: const EditorPage(),
            ),
          );
        }
        return null;
      },
      home: const HomeShell(),
    );
  }
}
