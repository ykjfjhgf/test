/// 编辑器页（features/editor/presentation）——R-EDI-01~08
///
/// 顶栏（返回/新建日记/⋯）+ 信息行（时间 + ✓自动保存）+ 标题与**常驻**日记本选择条
/// + 正文（图片缩略图预览 + 文本）+ 底部工具条（居中紧凑）；无 Dock。
/// v0.1.1：
/// - 日记本选择条常驻显示（R-EDI-09，不再隐藏式拖动）；
/// - 图片/拍摄/文件/语音调用手机系统能力，涂鸦为 App 内画板（R-EDI-10）；
/// - 工具条紧凑居中（R-EDI-11）。
library;

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_2/core/constants/dimens.dart';
import 'package:flutter_application_2/core/theme/app_theme.dart';
import 'package:flutter_application_2/core/utils/date_utils.dart';
import 'package:flutter_application_2/core/widgets/capsule_chip.dart';
import 'package:flutter_application_2/data/models/notebook.dart';
import 'package:flutter_application_2/data/providers.dart';
import 'package:flutter_application_2/features/diary/presentation/diary_provider.dart';
import 'package:flutter_application_2/features/editor/presentation/add_menu.dart';
import 'package:flutter_application_2/features/editor/presentation/editor_provider.dart';
import 'package:flutter_application_2/features/editor/presentation/editor_toolbar.dart';
import 'package:flutter_application_2/features/editor/presentation/sketch_pad.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class EditorPage extends ConsumerStatefulWidget {
  const EditorPage({super.key});

  @override
  ConsumerState<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends ConsumerState<EditorPage> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final editorAsync = ref.watch(editorProvider);
    final settings = ref.watch(settingsProvider).value;
    final notebooks = ref.watch(notebooksProvider).value ?? const <Notebook>[];
    final nameOf = {for (final n in notebooks) n.id: n.name};

    return editorAsync.when(
      loading: () => Scaffold(
        backgroundColor: colors.pageBg,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: colors.pageBg,
        body: Center(
            child: Text('加载失败', style: TextStyle(color: colors.secondaryText))),
      ),
      data: (editor) {
        final hint = settings?.autoSaveHintEnabled ?? true;
        // 同步外部变更到输入框（防抖动写循环）
        _syncController(_titleCtrl, editor.title);
        _syncController(_contentCtrl, editor.content);

        return Scaffold(
          backgroundColor: colors.pageBg,
          body: SafeArea(
            child: Column(
              children: [
                // 顶栏（R-EDI-01）
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 12, 0),
                  child: Row(
                    children: [
                      _iconBtn(context, Icons.arrow_back, () => Navigator.pop(context)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          editor.entryId == null ? '新建日记' : '编辑日记',
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w700),
                        ),
                      ),
                      _iconBtn(context, Icons.more_horiz, () => _openMore(context, editor.entryId != null)),
                    ],
                  ),
                ),
                // 信息行：时间 + ✓ 已自动保存（R-EDI-02）
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 2),
                  child: Row(
                    children: [
                      Text(DateUtils.full(editor.entryDate),
                          style: TextStyle(fontSize: 12, color: colors.secondaryText)),
                      const Spacer(),
                      if (hint)
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colors.festivalGreen,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              editor.lastSavedAt == null
                                  ? '尚未保存'
                                  : '✓ 已自动保存 ${DateUtils.time(editor.lastSavedAt!)}',
                              style: TextStyle(
                                  fontSize: 11, color: colors.festivalGreen),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                // 标题行（R-EDI-03）
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 2),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _titleCtrl,
                          onChanged: ref.read(editorProvider.notifier).onTitleChanged,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700),
                          decoration: InputDecoration(
                            hintText: '无标题',
                            hintStyle: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: colors.secondaryText),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: colors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.menu_book_outlined, size: 13),
                            const SizedBox(width: 4),
                            Text(
                              nameOf[editor.notebookId] ?? '未选日记本',
                              style: TextStyle(fontSize: 11, color: colors.secondaryText),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // v0.1.1（R-EDI-09）：日记本选择常驻胶囊行
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      for (final nb in notebooks) ...[
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: CapsuleChip(
                            label: nb.name,
                            selected: nb.id == editor.notebookId,
                            onTap: () =>
                                ref.read(editorProvider.notifier).moveTo(nb.id),
                          ),
                        ),
                      ],
                      if (notebooks.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                          child: Text('暂无日记本，可在设置中创建',
                              style: TextStyle(
                                  fontSize: 12, color: colors.secondaryText)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                // 正文：图片缩略图预览 + 文本（v0.1.1 R-EDI-07 改）
                if (editor.images.isNotEmpty)
                  SizedBox(
                    height: 58,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        for (final p in editor.images)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(p),
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  width: 48,
                                  height: 48,
                                  color: colors.imagePlaceholder,
                                  child: const Icon(Icons.image_outlined,
                                      size: 20, color: Colors.black26),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                Expanded(
                  child: TextField(
                    controller: _contentCtrl,
                    onChanged: ref.read(editorProvider.notifier).onContentChanged,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: const TextStyle(fontSize: 15, height: 1.7),
                    decoration: InputDecoration(
                      hintText: '开始记录...',
                      hintStyle:
                          TextStyle(fontSize: 15, color: colors.secondaryText),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    ),
                  ),
                ),
                // 工具条（v0.1.1：居中紧凑）
                EditorToolbar(
                  onImage: _pickImages,
                  onVoice: _recordVoice,
                  onAdd: _openAddMenu,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _syncController(TextEditingController ctrl, String value) {
    if (ctrl.text != value) {
      ctrl.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }
  }

  void _insert(String text) {
    ref.read(editorProvider.notifier).insertText(text);
    ref.read(editorProvider.notifier).saveNow();
  }

  // ── 系统能力调用（v0.1.1 R-EDI-10）──

  /// 相册多选（手机自带相册）
  Future<void> _pickImages() async {
    try {
      final files = await ImagePicker().pickMultiImage();
      if (files.isEmpty || !mounted) return;
      final paths = files.map((f) => f.path).where((p) => p.isNotEmpty).toList();
      if (paths.isEmpty) return;
      ref.read(editorProvider.notifier).addImages(paths);
      ref.read(editorProvider.notifier).saveNow();
    } catch (_) {
      if (mounted) _toast('无法打开相册');
    }
  }

  /// 拍摄（手机自带相机）
  Future<void> _pickCamera() async {
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.camera);
      if (file == null || !mounted) return;
      ref.read(editorProvider.notifier).addImages([file.path]);
      ref.read(editorProvider.notifier).saveNow();
    } catch (_) {
      if (mounted) _toast('无法打开相机');
    }
  }

  /// 文件（手机系统文件选择器；file_picker 13.x：静态 pickFiles 返回列表，取消=空）
  Future<void> _pickFile() async {
    try {
      final files = await FilePicker.pickFiles();
      if (files.isEmpty || !mounted) return;
      final names = files.map((f) => '[文件] ${f.name}').join('\n');
      _insert(names);
    } catch (_) {
      if (mounted) _toast('无法打开文件选择器');
    }
  }

  /// 语音（系统录音；record 7.x：AudioRecorder，需输出路径）
  Future<void> _recordVoice() async {
    final recorder = AudioRecorder();
    try {
      if (!await recorder.hasPermission()) {
        _toast('没有麦克风权限');
        return;
      }
      final dir = await getApplicationDocumentsDirectory();
      final voiceDir = Directory('${dir.path}/voice');
      if (!await voiceDir.exists()) await voiceDir.create(recursive: true);
      final outPath =
          '${voiceDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await recorder.start(const RecordConfig(), path: outPath);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('录音中…'),
          content: const Text('点击「停止」结束录音并插入'),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('停止'),
            ),
          ],
        ),
      );
      final path = await recorder.stop();
      if (path != null && path.isNotEmpty) {
        _insert('[语音] 已录制');
      }
    } catch (_) {
      try {
        await recorder.stop();
      } catch (_) {}
      if (mounted) _toast('录音不可用（请检查麦克风）');
    }
  }

  /// 涂鸦：App 内画板（R-EDI-06 v0.1.1）
  Future<void> _openSketch() async {
    final path = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const SketchPadPage()),
    );
    if (path != null && path.isNotEmpty && mounted) {
      ref.read(editorProvider.notifier).addImages([path]);
      ref.read(editorProvider.notifier).saveNow();
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _openAddMenu() async {
    final action = await AddMenu.show(context);
    if (action == null || !mounted) return;
    switch (action) {
      case AddMenuAction.table:
        await _askTable();
      case AddMenuAction.camera:
        await _pickCamera();
      case AddMenuAction.file:
        await _pickFile();
      case AddMenuAction.sketch:
        await _openSketch();
    }
  }

  Future<void> _askTable() async {
    var rows = 3;
    var cols = 3;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: const Text('插入表格'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text('行数'),
                  const Spacer(),
                  _stepBtn(setDlg, () => setDlg(() => rows = (rows - 1).clamp(1, 9)), Icons.remove),
                  Text(' $rows ', style: const TextStyle(fontSize: 16)),
                  _stepBtn(setDlg, () => setDlg(() => rows = (rows + 1).clamp(1, 9)), Icons.add),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('列数'),
                  const Spacer(),
                  _stepBtn(setDlg, () => setDlg(() => cols = (cols - 1).clamp(1, 6)), Icons.remove),
                  Text(' $cols ', style: const TextStyle(fontSize: 16)),
                  _stepBtn(setDlg, () => setDlg(() => cols = (cols + 1).clamp(1, 6)), Icons.add),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                ref.read(editorProvider.notifier).insertText('[表格 $rows×$cols]');
                ref.read(editorProvider.notifier).saveNow();
              },
              child: const Text('插入'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepBtn(StateSetter setDlg, VoidCallback onTap, IconData icon) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: AppDimens.minTouchTarget,
        height: AppDimens.minTouchTarget,
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: Theme.of(context).colorScheme.primary.withValues(alpha: .12)),
        child: Icon(icon, size: 20),
      ),
    );
  }

  Widget _iconBtn(BuildContext context, IconData icon, VoidCallback onTap) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: AppDimens.minTouchTarget,
        height: AppDimens.minTouchTarget,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.card,
          border: Border.all(color: colors.border),
        ),
        child: Icon(icon, size: 20, color: colors.secondaryText),
      ),
    );
  }

  Future<void> _openMore(BuildContext context, bool hasEntry) async {
    final colors = Theme.of(context).extension<AppColors>()!;
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _moreItem(ctx, Icons.bookmark_outline, '保存草稿', 'draft'),
            _moreItem(ctx, Icons.drive_file_move_outline, '移动日记本', 'move'),
            if (hasEntry) _moreItem(ctx, Icons.delete_outline, '删除', 'delete'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (!context.mounted || action == null) return;
    switch (action) {
      case 'draft':
        await ref.read(editorProvider.notifier).saveDraft();
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('已保存草稿')));
        }
      case 'move':
        await _pickNotebook();
      case 'delete':
        await ref.read(editorProvider.notifier).delete();
        if (context.mounted) Navigator.pop(context);
    }
  }

  Widget _moreItem(BuildContext context, IconData icon, String label, String value) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return InkWell(
      onTap: () => Navigator.pop(context, value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: colors.secondaryText),
            const SizedBox(width: 14),
            Text(label, style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Future<void> _pickNotebook() async {
    final notebooks = ref.read(notebooksProvider).value ?? const <Notebook>[];
    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(14),
              child: Text('移动日记本', style: TextStyle(fontWeight: FontWeight.w700)),
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
    if (picked != null && mounted) {
      await ref.read(editorProvider.notifier).moveTo(picked);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('已移动到该日记本')));
      }
    }
  }
}
