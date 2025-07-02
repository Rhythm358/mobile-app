// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

// class Palette {
//   Color get pen => const Color(0xFF7986CB); // 薄い青紫（変更なし）
//   Color get darkPen => const Color(0xFF303F9F); // 濃い青紫（変更なし）
//   Color get redPen => const Color(0xFFF44336); // 鮮やかな赤（変更なし）
//   Color get inkFullOpacity => const Color(0xFF283593); // 濃いインク色（変更なし）
//   Color get ink => const Color(0xEE283593); // 透明なインク色（変更なし）
//   Color get backgroundMain => const Color(0xFFF3F4FB); // より明るい薄い青
//   Color get backgroundLevelSelection => const Color(0xFFD0D6F2); // やや濃い薄い青
//   Color get backgroundPlaySession => const Color(0xFF9FA8DA); // 中間の青（変更なし）
//   Color get background4 => const Color(0xFF5C6BC0); // 濃い青（変更なし）
//   Color get backgroundSettings => const Color(0xFFE8EAF6); // 設定画面用の薄い青
//   Color get trueWhite => const Color(0xFFFFFFFF); // 純粋な白（変更なし）
// }

class Palette {
  Color get pen => const Color(0xFFFFFFFF); // 薄い青紫（変更なし）
  Color get darkPen => const Color(0xFFFFFFFF); // 濃い青紫（変更なし）
  Color get redPen => const Color(0xFFFFFFFF); // 鮮やかな赤（変更なし）

  Color get background4 => const Color(0xFFFFFFFF);

  Color get trueWhite => const Color(0xFFFFFFFF);

  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // Color get ink => const Color(0xFF444444); // 濃い灰色
  // Color get backgroundMain => const Color(0xFFC44F4F); // やや濃いオレンジ（暗く）
  // Color get backgroundPlaySession => const Color(0xFFB3D98F); // 中間の黄緑
  // Color get backgroundSettings => const Color(0xFFF9F9F9); // 薄いクリーム色（暖かく）
  // Color get backgroundLevelSelection => const Color(0xFFC44F4F); // やや濃いオレンジ（暗く）
  // Color get inkFullOpacity => const Color(0xFF283593); // 濃いインク色
  Color get ink => const Color(0xFFFFFFFF); // 純粋な白（文字色）
  Color get darkInk => const Color(0xFF2C3E50); // 濃い青グレー（濃いインク）
  Color get backgroundMain => const Color(0xFF2F343A); // 深いグレー
  Color get backgroundPlaySession => const Color(0xFF454F55); // 中間グレー
  Color get backgroundSettings => const Color(0xFF454F55); // 薄いクリーム色
  Color get backgroundLevelSelection => const Color(0xFF454F55); // 中間グレー
  Color get inkFullOpacity => const Color(0xFFFFFFFF); // 濃い青グレー（濃いインク）
  Color get highlight => const Color(0xFFE67E73); // 明るいオレンジ（ハイライト）
  Color get accent => const Color(0xFFC6E2B5); // 明るい黄緑（アクセント）
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
}
