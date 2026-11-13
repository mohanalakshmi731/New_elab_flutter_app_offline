import 'package:flutter/material.dart';

/// Values from the web's `src/style.css` that the login and dashboard screens
/// need exactly, but that the shared theme does not expose.
///
/// The `shadow-*` utilities resolve to the `--shadow-*` variables of
/// style.css (`@theme inline`), so they are the same subtle black shadows in
/// light and dark mode, and coloured `shadow-<color>/<n>` modifiers have no
/// effect on them (checked against the Tailwind 4.1.18 build).
class WebShadow {
  WebShadow._();

  static const _a05 = Color(0x0D000000);
  static const _a10 = Color(0x1A000000);

  /// `shadow-xs`: `0 1px 3px 0 rgb(0 0 0 / .05)`
  static const xs = [BoxShadow(color: _a05, blurRadius: 3, offset: Offset(0, 1))];

  /// `shadow-sm`: `0 1px 3px 0 rgb(0 0 0/.1), 0 1px 2px -1px rgb(0 0 0/.1)`
  static const sm = [
    BoxShadow(color: _a10, blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: _a10, blurRadius: 2, spreadRadius: -1, offset: Offset(0, 1)),
  ];

  /// `shadow-md`: `0 1px 3px 0 rgb(0 0 0/.1), 0 2px 4px -1px rgb(0 0 0/.1)`
  static const md = [
    BoxShadow(color: _a10, blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: _a10, blurRadius: 4, spreadRadius: -1, offset: Offset(0, 2)),
  ];

  /// `shadow-lg`: `0 1px 3px 0 rgb(0 0 0/.1), 0 4px 6px -1px rgb(0 0 0/.1)`
  static const lg = [
    BoxShadow(color: _a10, blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: _a10, blurRadius: 6, spreadRadius: -1, offset: Offset(0, 4)),
  ];

  /// `shadow-xl`: `0 1px 3px 0 rgb(0 0 0/.1), 0 8px 10px -1px rgb(0 0 0/.1)`
  static const xl = [
    BoxShadow(color: _a10, blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: _a10, blurRadius: 10, spreadRadius: -1, offset: Offset(0, 8)),
  ];
}

/// CSS colour variables of style.css (`:root` / `.dark`).
class WebColors {
  WebColors._();

  /// `--accent` (the `.dark` block redefines it to the same value).
  static const accent = Color(0xFFF49148);

  /// `--accent-foreground`
  static const accentForeground = Color(0xFF1F2430);

  /// `--input` (light) / `.dark --input`
  static const input = Color(0xFFE1E3E9);
  static const inputDark = Color(0xFF303540);

  /// `--popover` (light) / `.dark --popover`
  static const popoverDark = Color(0xFF2A2F3C);

  /// `--foreground` / `--card-foreground`
  static const foreground = Color(0xFF1F2430);
  static const foregroundDark = Color(0xFFE1E3E9);

  /// `--muted-foreground`
  static const mutedForeground = Color(0xFF1F2430);
  static const mutedForegroundDark = Color(0xFF9DB1D4);

  /// Global `[data-placeholder] { color: #9ca3af }` (unlayered, so it beats
  /// the select trigger's `data-[placeholder]:text-muted-foreground`).
  static const placeholder = Color(0xFF9CA3AF);
}

/// Tailwind line heights (`text-xs` … `text-4xl`) as Flutter `height`s.
class TwLeading {
  TwLeading._();
  static const xs = 16 / 12;
  static const sm = 20 / 14;
  static const base = 24 / 16;
  static const lg = 28 / 18;
  static const xl = 28 / 20;
  static const x2l = 32 / 24;
  static const x3l = 36 / 30;
  static const x4l = 40 / 36;

  /// Arbitrary `text-[Npx]` sizes inherit the body's 1.5.
  static const inherit = 1.5;
}
