/// 设置页（features/settings/presentation）——R-SET-01~08
///
/// 外观（主题三选/主题色预设+自定义）、日记本、隐私与安全、编辑器偏好、
/// 数据（导出/备份）、关于。所有变更即持久化（SettingsRepository.save）。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_2/core/theme/app_theme.dart';
import 'package:flutter_application_2/core/widgets/app_toggle.dart';
import 'package:flutter_application_2/data/models/app_settings.dart';
import 'package:flutter_application_2/data/models/notebook.dart';
import 'package:flutter_application_2/data/providers.dart';
import 'package:flutter_application_2/features/diary/presentation/diary_provider.dart';
import 'package:flutter_application_2/features/settings/domain/settings_domain.dart';
import 'package:flutter_application_2/features/settings/presentation/color_picker_sheet.dart';
import 'package:flutter_application_2/features/settings/presentation/settings_group.dart';
import 'package:flutter_application_2/services/backup_service.dart';
import 'package:flutter_application_2/services/security_service.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value ?? AppSettings.defaults;
    final notebooks = ref.watch(notebooksProvider).value ?? const <Notebook>[];

    Future<void> save(AppSettings s) =>
        ref.read(settingsRepositoryProvider).save(s);

    return Column(
      children: [
        // 大标题
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 14, 20, 6),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('设置',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 12),
            children: [
              // ── 外观（R-SET-01/02）──
              SettingsGroup(
                title: '外观',
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // v0.1.1（R-SET-09 改）：标签与 SegmentedButton 同一行，三段等宽
                        Row(
                          children: [
                            const Text('主题', style: TextStyle(fontSize: 15)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SegmentedButton<AppThemeMode>(
                                segments: const [
                                  ButtonSegment(value: AppThemeMode.light, label: Text('浅色')),
                                  ButtonSegment(value: AppThemeMode.dark, label: Text('深色')),
                                  ButtonSegment(value: AppThemeMode.system, label: Text('跟随系统')),
                                ],
                                selected: {settings.themeMode},
                                onSelectionChanged: (s) =>
                                    save(settings.copyWith(themeMode: s.first)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('主题色', style: TextStyle(fontSize: 15)),
                        const SizedBox(height: 12),
                        ColorPickerSheet.presetRow(
                          context,
                          settings.themeColorHex,
                          (hex) => save(settings.copyWith(themeColorHex: hex)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // ── 日记本（R-SET-03）──
              SettingsGroup(
                title: '日记本',
                children: [
                  SettingsRow(
                    icon: Icons.add_circle_outline,
                    title: '＋ 新建日记本',
                    onTap: () => _createNotebook(context, ref, notebooks.length),
                  ),
                  SettingsRow(
                    icon: Icons.menu_book_outlined,
                    title: '日记本管理',
                    trailing: '${notebooks.length}本',
                    onTap: () => _showNotebooks(context, ref, notebooks),
                  ),
                ],
              ),
              // ── 隐私与安全（R-SET-04）──
              SettingsGroup(
                title: '隐私与安全',
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: AppToggle(
                      title: '设为私密（密码本）',
                      subtitle: settings.privatePasswordHash == null
                          ? '未设置密码，开启后需验证'
                          : '已设置密码',
                      value: settings.privatePasswordHash != null,
                      onChanged: (v) async {
                        if (v) {
                          await _setPassword(context, ref);
                        } else {
                          await save(settings.copyWith(privatePasswordHash: null));
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('锁定时长', style: TextStyle(fontSize: 15)),
                        const SizedBox(height: 10),
                        SegmentedButton<LockTimeout>(
                          segments: [
                            for (final t in LockTimeout.values)
                              ButtonSegment(
                                value: t,
                                label: Text(SettingsDomain.lockTimeoutLabel(t.name)),
                              ),
                          ],
                          selected: {settings.lockTimeout},
                          onSelectionChanged: (s) =>
                              save(settings.copyWith(lockTimeout: s.first)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // ── 编辑器（R-SET-05）──
              SettingsGroup(
                title: '编辑器',
                children: [
                  SettingsRow(
                    icon: Icons.bookmark_outline,
                    title: '默认日记本',
                    trailing: notebooks
                            .where((n) => n.id == settings.defaultNotebookId)
                            .firstOrNull
                            ?.name ??
                        '（未设置）',
                    onTap: () => _pickDefaultNotebook(context, ref, settings, notebooks),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: AppToggle(
                      title: '隐藏式日记本栏',
                      value: settings.hiddenBarEnabled,
                      onChanged: (v) => save(settings.copyWith(hiddenBarEnabled: v)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: AppToggle(
                      title: '自动保存提示',
                      value: settings.autoSaveHintEnabled,
                      onChanged: (v) => save(settings.copyWith(autoSaveHintEnabled: v)),
                    ),
                  ),
                ],
              ),
              // ── 数据（R-SET-06）──
              SettingsGroup(
                title: '数据',
                children: [
                  SettingsRow(
                    icon: Icons.ios_share,
                    title: '导出数据',
                    onTap: () => _exportData(context, ref),
                  ),
                  SettingsRow(
                    icon: Icons.settings_backup_restore,
                    title: '备份与恢复',
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('备份/恢复文件选择器待接入（R-SET-06）'))),
                  ),
                ],
              ),
              // ── 关于 ──
              SettingsGroup(
                title: '关于',
                children: [
                  SettingsRow(
                    icon: Icons.info_outline,
                    title: '版本',
                    trailing: '0.1.1',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _createNotebook(BuildContext context, WidgetRef ref, int count) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('新建日记本'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '日记本名称'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('创建'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    await ref.read(notebookRepositoryProvider).create(Notebook(
          id: 'nb-${DateTime.now().microsecondsSinceEpoch}',
          name: name,
          createdAt: DateTime.now(),
          sortOrder: count,
        ));
  }

  Future<void> _showNotebooks(BuildContext context, WidgetRef ref, List<Notebook> notebooks) async {
    final colors = Theme.of(context).extension<AppColors>()!;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.card,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(14),
              child: Text('日记本管理', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            for (final nb in notebooks)
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.colorFromHex(nb.coverColorHex),
                  radius: 10,
                ),
                title: Text(nb.name),
                subtitle: Text(nb.isPrivate ? '私密' : '普通'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await ref.read(notebookRepositoryProvider).delete(nb.id);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _setPassword(BuildContext context, WidgetRef ref) async {
    final pwd1 = TextEditingController();
    final pwd2 = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('设置密码本密码'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pwd1,
              obscureText: true,
              decoration: const InputDecoration(hintText: '密码'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: pwd2,
              obscureText: true,
              decoration: const InputDecoration(hintText: '再次输入'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('确认'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (pwd1.text.isEmpty || pwd1.text != pwd2.text) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('两次密码不一致或为空')));
      }
      return;
    }
    final settings = ref.read(settingsProvider).value ?? AppSettings.defaults;
    await ref.read(settingsRepositoryProvider).save(
        settings.copyWith(privatePasswordHash: SecurityService.hashPassword(pwd1.text)));
  }

  Future<void> _pickDefaultNotebook(
      BuildContext context, WidgetRef ref, AppSettings settings, List<Notebook> notebooks) async {
    final colors = Theme.of(context).extension<AppColors>()!;
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: colors.card,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(14),
              child: Text('默认日记本', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            ListTile(
              leading: const Icon(Icons.remove_circle_outline),
              title: const Text('（未设置）'),
              onTap: () => Navigator.pop(ctx, ''),
            ),
            for (final nb in notebooks)
              ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: Text(nb.name),
                onTap: () => Navigator.pop(ctx, nb.id),
              ),
          ],
        ),
      ),
    );
    if (picked == null) return;
    await ref.read(settingsRepositoryProvider).save(
        picked.isEmpty
            ? settings.copyWith(clearDefaultNotebook: true)
            : settings.copyWith(defaultNotebookId: picked));
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    final entries = await ref.read(entryRepositoryProvider).watchAll().first;
    final notebooks = await ref.read(notebookRepositoryProvider).watchAll().first;
    final settings = ref.read(settingsProvider).value ?? AppSettings.defaults;
    final json = BackupService.buildJson(
        entries: entries, notebooks: notebooks, settings: settings);
    final path = await BackupService.exportToFile(json, '.');
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('已导出：$path')));
    }
  }
}
