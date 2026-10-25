/// 涂鸦画板（features/editor/presentation）——R-EDI-06 涂鸦（v0.1.1）
///
/// App 内自绘画板：多色笔、清空、完成保存为 PNG 到应用文档目录，
/// 返回图片路径交由编辑器插入（addImages）。
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/app_theme.dart';
import 'package:path_provider/path_provider.dart';

class SketchPadPage extends StatefulWidget {
  const SketchPadPage({super.key});

  @override
  State<SketchPadPage> createState() => _SketchPadPageState();
}

class _SketchPadPageState extends State<SketchPadPage> {
  static const double _canvasW = 720;
  static const double _canvasH = 720;
  static const List<Color> _palette = [
    Color(0xFF111111),
    Color(0xFFEF4444),
    Color(0xFF2563EB),
    Color(0xFF0AA69A),
    Color(0xFFF59E0B),
  ];

  final List<_Stroke> _strokes = [];
  _Stroke? _current;
  Color _color = _palette.first;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      backgroundColor: colors.pageBg,
      appBar: AppBar(
        backgroundColor: colors.card,
        title: const Text('涂鸦'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveAndReturn,
            child: const Text('完成', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: Column(
        children: [
          // 色板
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final c in _palette) ...[
                  GestureDetector(
                    onTap: () => setState(() => _color = c),
                    child: Container(
                      width: 34,
                      height: 34,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: c,
                        border: _color == c
                            ? Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 3)
                            : null,
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: '清空',
                  onPressed: () => setState(() => _strokes.clear()),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final scale = constraints.maxWidth / _canvasW;
                      return GestureDetector(
                        onPanStart: (d) {
                          final p = _toCanvas(d.localPosition, scale);
                          _current = _Stroke(_color, [p]);
                          setState(() => _strokes.add(_current!));
                        },
                        onPanUpdate: (d) {
                          _current?.points.add(_toCanvas(d.localPosition, scale));
                          setState(() {});
                        },
                        onPanEnd: (_) => _current = null,
                        child: CustomPaint(
                          painter: _SketchPainter(_strokes),
                          size: Size.square(constraints.maxWidth),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Offset _toCanvas(Offset local, double scale) =>
      Offset(local.dx / scale, local.dy / scale);

  Future<void> _saveAndReturn() async {
    if (_strokes.isEmpty) {
      Navigator.pop(context);
      return;
    }
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      _SketchPainter(_strokes).paint(canvas, const Size(_canvasW, _canvasH));
      final picture = recorder.endRecording();
      final image = await picture.toImage(_canvasW.toInt(), _canvasH.toInt());
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) {
        if (mounted) Navigator.pop(context);
        return;
      }
      final dir = await getApplicationDocumentsDirectory();
      final sketchDir = Directory('${dir.path}/sketch');
      if (!await sketchDir.exists()) await sketchDir.create(recursive: true);
      final file = File(
          '${sketchDir.path}/sketch_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes.buffer.asUint8List());
      if (mounted) Navigator.pop(context, file.path);
    } catch (_) {
      if (mounted) Navigator.pop(context);
    }
  }
}

class _Stroke {
  final Color color;
  final List<Offset> points;
  _Stroke(this.color, this.points);
}

class _SketchPainter extends CustomPainter {
  final List<_Stroke> strokes;

  _SketchPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFFFFFFFF));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final s in strokes) {
      if (s.points.length < 2) continue;
      paint.color = s.color;
      final path = Path()..moveTo(s.points.first.dx, s.points.first.dy);
      for (final p in s.points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_SketchPainter oldDelegate) =>
      oldDelegate.strokes != strokes;
}
