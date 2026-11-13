import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/pagination.dart';

/// The `<Pagination>` block under every web list (`m-4 flex justify-end`):
/// `Prev [1][2]…[10] Next` with `gap-1`, page numbers in groups of 5
/// (phones) / 10, active page `bg-blue-500 text-white`, others `border`.
class AppPagination extends StatelessWidget {
  const AppPagination({
    super.key,
    required this.meta,
    required this.onPageChanged,
    this.perGroup,
    this.alignment = MainAxisAlignment.end,
    this.padding = const EdgeInsets.all(16),
  });

  final PageMeta meta;

  /// Called with the requested page; out-of-range pages are never emitted.
  final ValueChanged<int> onPageChanged;

  /// Defaults to 5 below 640px and 10 above, like `visiblePages()`.
  final int? perGroup;
  final MainAxisAlignment alignment;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final current = meta.currentPage;
    final last = meta.lastPage;
    final pages = visiblePageGroup(current, last, perGroup ?? (context.isSm ? 10 : 5));
    final fontSize = context.isSm ? 14.0 : 12.0;
    final border = context.isDark ? AppColors.darkBorder : AppColors.border;

    void go(int p) {
      if (p < 1 || p > last || p == current) return;
      onPageChanged(p);
    }

    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, c) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          // `justify-end` needs the row to span the available width.
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: c.maxWidth.isFinite ? c.maxWidth : 0),
            child: Row(
              mainAxisAlignment: alignment,
              children: [
                _NavButton(label: 'Prev', enabled: current > 1, onTap: () => go(current - 1)),
                const SizedBox(width: 4),
                for (final p in pages) ...[
                  _PageChip(page: p, active: p == current, border: border, fontSize: fontSize, onTap: () => go(p)),
                  const SizedBox(width: 4),
                ],
                _NavButton(label: 'Next', enabled: current < last, onTap: () => go(current + 1)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// `<PaginationItem class="px-2 py-1 rounded text-xs sm:text-sm">` on top of
/// `buttonVariants({ variant: isActive ? 'outline' : 'ghost' })`: 36px tall
/// (`h-9` survives the override), `font-medium`, `border`; the active page
/// adds `bg-blue-500 text-white` (in dark mode `dark:bg-input/30` wins).
/// Hover: `bg-accent text-accent-foreground` (dark: active `input/50`,
/// others `accent/50`).
class _PageChip extends StatefulWidget {
  const _PageChip({
    required this.page,
    required this.active,
    required this.border,
    required this.fontSize,
    required this.onTap,
  });

  final int page;
  final bool active;
  final Color border;
  final double fontSize;
  final VoidCallback onTap;

  @override
  State<_PageChip> createState() => _PageChipState();
}

class _PageChipState extends State<_PageChip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final input = context.inputColor;
    Color bg;
    Color? fg;
    Color border = widget.border;
    if (widget.active) {
      bg = dark ? input.withValues(alpha: _hover ? 0.5 : 0.3) : (_hover ? AppColors.accent : Tw.blue500);
      fg = _hover ? AppColors.accentForeground : Colors.white;
      if (dark) border = input;
    } else {
      bg = _hover ? (dark ? AppColors.accent.withValues(alpha: 0.5) : AppColors.accent) : Colors.transparent;
      fg = _hover ? AppColors.accentForeground : null;
    }
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: border),
            boxShadow: widget.active ? AppShadows.xs : null,
          ),
          child: Text(
            '${widget.page}',
            style: TextStyle(fontSize: widget.fontSize, fontWeight: FontWeight.w500, color: fg),
          ),
        ),
      ),
    );
  }
}

/// `<PaginationPrevious>Prev</PaginationPrevious>`: the slot replaces the
/// chevron, so only the text shows. Ghost button `h-9 px-2.5 text-sm
/// font-medium rounded-md`, `hover:bg-accent`; `opacity-50` when disabled.
class _NavButton extends StatefulWidget {
  const _NavButton({required this.label, required this.enabled, required this.onTap});

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final hot = _hover && widget.enabled;
    return Opacity(
      opacity: widget.enabled ? 1 : 0.5,
      child: MouseRegion(
        cursor: widget.enabled ? SystemMouseCursors.click : MouseCursor.defer,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.enabled ? widget.onTap : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: hot ? (dark ? AppColors.accent.withValues(alpha: 0.5) : AppColors.accent) : Colors.transparent,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: hot ? AppColors.accentForeground : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
