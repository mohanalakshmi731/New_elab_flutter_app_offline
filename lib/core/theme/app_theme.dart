import 'dart:async';
import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_fonts.dart';

export 'app_fonts.dart' show AppFonts;

/// Material 3 themes built from the CSS variables in `src/style.css`.
///
/// Radii follow the web's `--radius: 1rem`: `rounded-sm` 12, `rounded-md` 14
/// (inputs, buttons, menus), `rounded-lg` 16, `rounded-xl` 20 (cards).
///
/// Fonts follow `--font-sans`: Plus Jakarta Sans in light mode, Inter in dark
/// mode (`.dark` redefines `--font-sans: Inter, …`).
class AppTheme {
  AppTheme._();

  static const radius = 16.0;

  /// `rounded-sm` = `calc(var(--radius) - 4px)`.
  static const radiusSm = 12.0;

  /// `rounded-md` = `calc(var(--radius) - 2px)`.
  static const radiusMd = 14.0;

  /// `rounded-lg` = `var(--radius)`.
  static const radiusLg = 16.0;

  /// `rounded-xl` = `calc(var(--radius) + 4px)`.
  static const radiusXl = 20.0;

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.primaryForeground,
      secondary: AppColors.secondary,
      onSecondary: AppColors.secondaryForeground,
      tertiary: AppColors.accent,
      onTertiary: AppColors.accentForeground,
      error: AppColors.destructive,
      onError: AppColors.destructiveForeground,
      surface: AppColors.card,
      onSurface: AppColors.foreground,
      surfaceContainerHighest: AppColors.muted,
      onSurfaceVariant: AppColors.mutedForeground,
      outline: AppColors.border,
      outlineVariant: AppColors.border,
    );
    return _base(scheme, AppColors.dashboardLight);
  }

  static ThemeData dark() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.darkPrimary,
      onPrimary: AppColors.darkPrimaryForeground,
      secondary: AppColors.secondary,
      onSecondary: AppColors.secondaryForeground,
      tertiary: AppColors.accent,
      onTertiary: AppColors.accentForeground,
      error: AppColors.darkDestructive,
      onError: AppColors.darkDestructiveForeground,
      surface: AppColors.cardDark,
      onSurface: AppColors.darkForeground,
      surfaceContainerHighest: AppColors.darkMuted,
      onSurfaceVariant: AppColors.darkMutedForeground,
      outline: AppColors.darkBorder,
      outlineVariant: AppColors.cardBorderDark,
    );
    return _base(scheme, AppColors.dashboardDark);
  }

  /// `--font-sans` of the given mode (see [AppFonts]).
  static String fontFamily(Brightness b) => b == Brightness.dark ? AppFonts.inter : AppFonts.plusJakartaSans;

  static TextTheme _fontTextTheme(Brightness b) {
    unawaited(AppFonts.ensureLoaded());
    return ThemeData(brightness: b).textTheme.apply(fontFamily: fontFamily(b), fontFamilyFallback: AppFonts.fallback);
  }

  static ThemeData _base(ColorScheme scheme, Color scaffold) {
    final isDark = scheme.brightness == Brightness.dark;
    final textTheme = _fontTextTheme(scheme.brightness)
        .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
    final input = isDark ? AppColors.darkInput : AppColors.input;
    final ring = isDark ? AppColors.darkRing : AppColors.ring;
    final destructive = isDark ? AppColors.darkDestructive : AppColors.destructive;
    final popover = isDark ? AppColors.darkPopover : AppColors.popover;
    final border = isDark ? AppColors.darkBorder : AppColors.border;

    // shadcn <Input>: `rounded-md border border-input`, focus-visible:
    // `border-ring ring-[3px] ring-ring/50`; aria-invalid: `border-destructive`
    // (+ `ring-destructive/20`, dark /40, while focused).
    RingInputBorder field(Color side, {Color ringColor = Colors.transparent}) => RingInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: side),
          ringColor: ringColor,
          shadows: AppShadows.xs,
        );

    final menuShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd),
      side: BorderSide(color: border),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      fontFamily: fontFamily(scheme.brightness),
      fontFamilyFallback: AppFonts.fallback,
      textTheme: textTheme,
      // `* { @apply border-border }`
      dividerColor: border,
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      cardTheme: CardThemeData(
        color: isDark ? AppColors.cardDark : Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: isDark ? Tw.slate800 : Tw.slate100),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        // `selection:bg-primary` (Flutter can't recolour the selected text).
        selectionColor: scheme.primary.withValues(alpha: 0.35),
        selectionHandleColor: scheme.primary,
        cursorColor: scheme.onSurface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        // `bg-transparent dark:bg-input/30`
        fillColor: isDark ? input.withValues(alpha: 0.3) : Colors.transparent,
        hoverColor: Colors.transparent,
        // `h-9 px-3` with a 20px line (text-sm).
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        hintStyle: const TextStyle(color: AppColors.placeholder),
        errorStyle: TextStyle(color: destructive, fontSize: 14, height: 20 / 14),
        errorMaxLines: 3,
        border: field(input),
        enabledBorder: field(input),
        disabledBorder: field(input),
        focusedBorder: field(ring, ringColor: ring.withValues(alpha: 0.5)),
        errorBorder: field(destructive),
        focusedErrorBorder: field(destructive, ringColor: destructive.withValues(alpha: isDark ? 0.4 : 0.2)),
      ),
      // shadcn `<Button>` (default variant) for plain Material buttons.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(0, 36),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      // shadcn `variant="outline"`.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          backgroundColor: isDark ? input.withValues(alpha: 0.3) : AppColors.background,
          side: BorderSide(color: isDark ? input : border),
          minimumSize: const Size(0, 36),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      // Native `title="…"` tooltips (the shadcn <Tooltip> is only used by the
      // top bar's colour-mode button, which styles itself).
      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 500),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2B2B2B) : Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isDark ? const Color(0xFF5A5A5A) : const Color(0xFFC4C4C4)),
          boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 2))],
        ),
        textStyle: TextStyle(fontSize: 12, color: isDark ? Colors.white : const Color(0xFF1F1F1F)),
      ),
      // shadcn `<DropdownMenuContent>` / `<PopoverContent>`: `bg-popover border
      // rounded-md p-1 shadow-md`.
      popupMenuTheme: PopupMenuThemeData(
        color: popover,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.5),
        shape: menuShape,
        menuPadding: const EdgeInsets.all(4),
        textStyle: TextStyle(fontSize: 14, color: scheme.onSurface),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(popover),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: const WidgetStatePropertyAll(2),
          shadowColor: WidgetStatePropertyAll(Colors.black.withValues(alpha: 0.5)),
          padding: const WidgetStatePropertyAll(EdgeInsets.all(4)),
          shape: WidgetStatePropertyAll(menuShape),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? Tw.slate900 : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusXl)),
      ),
      // `::-webkit-scrollbar { width: 4px }`, thumb #d1d5db (hover #9ca3af).
      scrollbarTheme: ScrollbarThemeData(
        thickness: const WidgetStatePropertyAll(4),
        radius: const Radius.circular(99),
        crossAxisMargin: 0,
        mainAxisMargin: 0,
        minThumbLength: 24,
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.hovered) || s.contains(WidgetState.dragged)
              ? AppColors.scrollbarThumbHover
              : AppColors.scrollbarThumb,
        ),
        trackColor: const WidgetStatePropertyAll(Colors.transparent),
        trackBorderColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      // Native `<input type="checkbox">` (Chrome: #0075ff when checked).
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? const Color(0xFF0075FF) : Colors.transparent,
        ),
        checkColor: const WidgetStatePropertyAll(Colors.white),
        side: const BorderSide(color: Color(0xFF767676)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
    );
  }
}

/// An [OutlineInputBorder] that also paints the CSS focus ring
/// (`ring-[3px] ring-ring/50`, a box-shadow outside the border box).
class RingInputBorder extends OutlineInputBorder {
  const RingInputBorder({
    super.borderSide = const BorderSide(),
    super.borderRadius = const BorderRadius.all(Radius.circular(AppTheme.radiusMd)),
    super.gapPadding = 4.0,
    this.ringColor = Colors.transparent,
    this.ringWidth = 3,
    this.shadows = const [],
  });

  /// Transparent = no ring.
  final Color ringColor;
  final double ringWidth;

  /// Box shadows painted outside the field (`shadow-xs`).
  final List<BoxShadow> shadows;

  @override
  RingInputBorder copyWith({
    BorderSide? borderSide,
    BorderRadius? borderRadius,
    double? gapPadding,
    Color? ringColor,
    double? ringWidth,
    List<BoxShadow>? shadows,
  }) {
    return RingInputBorder(
      borderSide: borderSide ?? this.borderSide,
      borderRadius: borderRadius ?? this.borderRadius,
      gapPadding: gapPadding ?? this.gapPadding,
      ringColor: ringColor ?? this.ringColor,
      ringWidth: ringWidth ?? this.ringWidth,
      shadows: shadows ?? this.shadows,
    );
  }

  @override
  RingInputBorder scale(double t) => RingInputBorder(
        borderSide: borderSide.scale(t),
        borderRadius: borderRadius * t,
        gapPadding: gapPadding * t,
        ringColor: ringColor,
        ringWidth: ringWidth * t,
        shadows: shadows,
      );

  static RingInputBorder _lerp(OutlineInputBorder a, RingInputBorder b, double t) {
    final ra = a is RingInputBorder ? a : null;
    return RingInputBorder(
      borderRadius: BorderRadius.lerp(a.borderRadius, b.borderRadius, t)!,
      borderSide: BorderSide.lerp(a.borderSide, b.borderSide, t),
      gapPadding: lerpDouble(a.gapPadding, b.gapPadding, t)!,
      ringColor: Color.lerp(ra?.ringColor ?? Colors.transparent, b.ringColor, t)!,
      ringWidth: lerpDouble(ra?.ringWidth ?? b.ringWidth, b.ringWidth, t)!,
      shadows: t < 0.5 ? (ra?.shadows ?? b.shadows) : b.shadows,
    );
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is OutlineInputBorder) return _lerp(a, this, t);
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is RingInputBorder) return _lerp(this, b, t);
    return super.lerpTo(b, t);
  }

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    double? gapStart,
    double gapExtent = 0.0,
    double gapPercentage = 0.0,
    TextDirection? textDirection,
  }) {
    if (shadows.isNotEmpty) {
      // Outside the field only (the fill is already painted).
      final outer = borderRadius.toRRect(rect);
      canvas.save();
      canvas.clipPath(
        Path()
          ..fillType = PathFillType.evenOdd
          ..addRect(rect.inflate(64))
          ..addRRect(outer),
      );
      for (final s in shadows) {
        canvas.drawRRect(outer.shift(s.offset).inflate(s.spreadRadius), s.toPaint());
      }
      canvas.restore();
    }
    if (ringWidth > 0 && ringColor.a > 0) {
      final ringRect = borderRadius.toRRect(rect).inflate(ringWidth / 2);
      canvas.drawRRect(
        ringRect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = ringWidth
          ..color = ringColor,
      );
    }
    super.paint(canvas, rect,
        gapStart: gapStart, gapExtent: gapExtent, gapPercentage: gapPercentage, textDirection: textDirection);
  }

  @override
  bool operator ==(Object other) =>
      other is RingInputBorder &&
      other.borderSide == borderSide &&
      other.borderRadius == borderRadius &&
      other.gapPadding == gapPadding &&
      other.ringColor == ringColor &&
      other.ringWidth == ringWidth &&
      listEquals(other.shadows, shadows);

  @override
  int get hashCode => Object.hash(borderSide, borderRadius, gapPadding, ringColor, ringWidth, Object.hashAll(shadows));
}

/// A CSS `box-shadow` layer as a Flutter [BoxShadow]. A CSS blur radius `B`
/// is a Gaussian with σ = B/2, while Flutter's `blurRadius` r means
/// σ = r·0.57735 + 0.5, so the radius is converted to match.
BoxShadow cssShadow(double x, double y, double blur, double spread, Color color) => BoxShadow(
      color: color,
      offset: Offset(x, y),
      blurRadius: blur <= 1 ? blur / 2 : (blur / 2 - 0.5) / 0.57735,
      spreadRadius: spread,
    );

/// The app's shadow scale. style.css redefines Tailwind's `--shadow-*`
/// (same values in light and dark). Because they are CSS variables, colour
/// modifiers such as `shadow-indigo-500/20` have no effect on them on the web.
class AppShadows {
  AppShadows._();

  static final xs2 = [cssShadow(0, 1, 3, 0, const Color(0x0D000000))];
  static final xs = [cssShadow(0, 1, 3, 0, const Color(0x0D000000))];
  static final sm = [
    cssShadow(0, 1, 3, 0, const Color(0x1A000000)),
    cssShadow(0, 1, 2, -1, const Color(0x1A000000)),
  ];

  /// `shadow` (no suffix).
  static final base = sm;
  static final md = [
    cssShadow(0, 1, 3, 0, const Color(0x1A000000)),
    cssShadow(0, 2, 4, -1, const Color(0x1A000000)),
  ];
  static final lg = [
    cssShadow(0, 1, 3, 0, const Color(0x1A000000)),
    cssShadow(0, 4, 6, -1, const Color(0x1A000000)),
  ];
  static final xl = [
    cssShadow(0, 1, 3, 0, const Color(0x1A000000)),
    cssShadow(0, 8, 10, -1, const Color(0x1A000000)),
  ];
  static final xl2 = [cssShadow(0, 1, 3, 0, const Color(0x40000000))];
}

extension ThemeX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Tailwind breakpoints.
  bool get isSm => screenWidth >= 640;
  bool get isMd => screenWidth >= 768;
  bool get isLg => screenWidth >= 1024;
  bool get isXl => screenWidth >= 1280;
  bool get is2xl => screenWidth >= 1536;

  // ── style.css variables for the current mode ──

  /// `--foreground`
  Color get fgColor => isDark ? AppColors.darkForeground : AppColors.foreground;

  /// `--muted-foreground` (#1f2430 light, #9db1d4 dark).
  Color get mutedFgColor => isDark ? AppColors.darkMutedForeground : AppColors.mutedForeground;

  /// `--muted`
  Color get mutedColor => isDark ? AppColors.darkMuted : AppColors.muted;

  /// `--border`
  Color get borderColor => isDark ? AppColors.darkBorder : AppColors.border;

  /// `--input`
  Color get inputColor => isDark ? AppColors.darkInput : AppColors.input;

  /// `--ring`
  Color get ringColor => isDark ? AppColors.darkRing : AppColors.ring;

  /// `--popover` / `--card`
  Color get popoverColor => isDark ? AppColors.darkPopover : AppColors.popover;

  /// `--destructive`
  Color get destructiveColor => isDark ? AppColors.darkDestructive : AppColors.destructive;
}
