import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

/// 背景模糊着色器的 uniform 接线守卫。
///
/// ## 为什么要有这条（2026-09-29 真机崩溃的账）
///
/// `_InspireBackdropBlurPassState._updateShader` 给每个 float uniform 的编号
/// 必须与 `shaders/inspire_blur_backdrop.frag` 的**声明顺序**逐一对上。着色器里
/// 加一个 uniform、Dart 侧没跟着核对编号（或反之），运行时不会报「参数对不上」，
/// 而是 `setFloat` 直接越界崩溃（`_typedDataIndexCheck`）或静默写错槽位 ——
/// 两者都比编译错误更难查（2026-09-29 补丁 5 上机时真机崩溃过一次）。
///
/// 这条用例把**全部** float 槽位逐个写一遍：着色器编译产物里 float 数量少于
/// Dart 侧写的最大编号时，这里立刻红。
void main() {
  test('背景模糊着色器接受全部 float uniform 槽位（0..24，补丁 5 的 24 号含内）', () async {
    final program = await ui.FragmentProgram.fromAsset(
      'shaders/inspire_blur_backdrop.frag',
    );
    final shader = program.fragmentShader();

    final image = _onePixelImage();
    // 采样器槽位：0 = u_texture，1 = u_blur_texture（强度图）。
    shader.setImageSampler(0, image);
    shader.setImageSampler(1, image);

    // float 槽位 0..24：u_size(0,1) sigma(2) direction(3,4) area(5..8)
    // transform(9..16) colorAdjustment(17..23) topCornerRadius(24)。
    for (var i = 0; i <= 24; i++) {
      shader.setFloat(i, 1.0);
    }
  });
}

ui.Image _onePixelImage() {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  canvas.drawRect(
    ui.Rect.fromLTWH(0, 0, 1, 1),
    ui.Paint()..color = const ui.Color(0xFF000000),
  );
  return recorder.endRecording().toImageSync(1, 1);
}
