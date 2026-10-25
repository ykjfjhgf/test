/// 主题色选择（features/settings/presentation）——R-SET-02
///
/// 预设 6 色（选中=外环描边）+ 自定义取色器（HSV 滑块 + hex 输入）。
/// 选择即调用回调持久化（AppTheme 动态生成全局生效）。
library;

import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/app_theme.dart';
import 'package:flutter_application_2/features/settings/domain/settings_domain.dart';

class ColorPickerSheet {
  ColorPickerSheet._();

  /// 预设色圆点行（含自定义入口）
  static Widget presetRow(BuildContext context, String currentHex, ValueChanged<String> onPick) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Row(
      children: [
        for (final p in SettingsDomain.presetColors) ...[
          _dot(context, p.hex, currentHex, onPick),
          const SizedBox(width: 12),
        ],
        // 自定义入口
        GestureDetector(
          onTap: () => _openCustom(context, currentHex, onPick),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.imagePlaceholder,
              border: Border.all(
                color: currentHex.toUpperCase() == '#FFFFFF'.toUpperCase()
                    ? colors.border
                    : colors.secondaryText,
                width: 1,
              ),
            ),
            child: Icon(Icons.colorize, size: 18, color: colors.secondaryText),
          ),
        ),
      ],
    );
  }

  static Widget _dot(BuildContext context, String hex, String currentHex, ValueChanged<String> onPick) {
    final color = AppTheme.colorFromHex(hex);
    final selected = hex.toUpperCase() == currentHex.toUpperCase();

    return GestureDetector(
      onTap: () => onPick(hex),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          // 选中=外环描边（R-SET-02）
          border: selected
              ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 3)
              : Border.all(color: Colors.white.withValues(alpha: .2)),
        ),
        child: selected
            ? const Icon(Icons.check, size: 18, color: Colors.white)
            : null,
      ),
    );
  }

  static Future<void> _openCustom(
      BuildContext context, String currentHex, ValueChanged<String> onPick) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _CustomPicker(initial: currentHex),
    );
    if (picked != null && picked != currentHex) onPick(picked);
  }
}

class _CustomPicker extends StatefulWidget {
  final String initial;

  const _CustomPicker({required this.initial});

  @override
  State<_CustomPicker> createState() => _CustomPickerState();
}

class _CustomPickerState extends State<_CustomPicker> {
  late HSVColor _hsv;
  final _hexCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final color = AppTheme.colorFromHex(widget.initial);
    _hsv = HSVColor.fromColor(color);
    _hexCtrl.text = widget.initial.replaceAll('#', '').toUpperCase();
  }

  @override
  void dispose() {
    _hexCtrl.dispose();
    super.dispose();
  }

  String get _hex {
    final c = _hsv.toColor();
    final r = (c.r * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase();
    final g = (c.g * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase();
    final b = (c.b * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase();
    return '#$r$g$b';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final preview = _hsv.toColor();

    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: preview,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.border),
                ),
              ),
              const SizedBox(width: 12),
              const Text('自定义主题色', style: TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(context, _hex),
                child: const Text('完成'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _slider('色相', _hsv.hue / 360, (v) => setState(() => _hsv = _hsv.withHue(v * 360))),
          _slider('饱和度', _hsv.saturation, (v) => setState(() => _hsv = _hsv.withSaturation(v))),
          _slider('亮度', _hsv.value, (v) => setState(() => _hsv = _hsv.withValue(v))),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('色值', style: TextStyle(fontSize: 13, color: colors.secondaryText)),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _hexCtrl,
                  decoration: const InputDecoration(
                    prefixText: '#',
                    hintText: '0AA69A',
                    isDense: true,
                  ),
                  onChanged: (v) {
                    final cleaned = v.replaceAll('#', '');
                    if (cleaned.length != 6) return;
                    final c = AppTheme.colorFromHex(cleaned);
                    setState(() => _hsv = HSVColor.fromColor(c));
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _slider(String label, double value, ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(width: 44, child: Text(label, style: const TextStyle(fontSize: 13))),
        Expanded(
          child: Slider(value: value, onChanged: onChanged),
        ),
      ],
    );
  }
}
