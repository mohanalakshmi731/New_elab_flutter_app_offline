import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/external_link.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/web_content_view.dart';
import 'teacher_course_logic.dart';

/// Tailwind colours used by `teachercoursepage.vue` that `Tw` lacks.
class TcTw {
  TcTw._();
  static const emerald800 = Color(0xFF065F46);
  static const emerald900 = Color(0xFF064E3B);
  static const emerald950 = Color(0xFF022C22);
  static const amber700 = Color(0xFFB45309);
  static const blue200 = Color(0xFFBFDBFE);
  static const blue300 = Color(0xFF93C5FD);
  static const red50 = Color(0xFFFEF2F2);
  static const red200 = Color(0xFFFECACA);
  static const red400 = Color(0xFFF87171);
  static const red700 = Color(0xFFB91C1C);
  static const red950 = Color(0xFF450A0A);
  static const rose100 = Color(0xFFFFE4E6);
  static const rose700 = Color(0xFFBE123C);
  static const emerald900a30 = Color(0x4D064E3B);
}

/// The `--shadow-*` tokens of `src/style.css` (same in light and dark).
/// Tailwind v4 can't recolour these `var()` shadows, so `shadow-emerald-200`
/// / `shadow-slate-200/60` next to them have no effect on the web either.
class TcShadows {
  TcShadows._();
  static const _c = Color(0x1A000000);

  /// `shadow-xs`: `0 1px 3px 0 hsl(0 0% 0% / 0.05)`
  static const xs = [BoxShadow(color: Color(0x0D000000), blurRadius: 3, offset: Offset(0, 1))];

  /// `shadow-sm`: `0 1px 3px 0 /.1, 0 1px 2px -1px /.1`
  static const sm = [
    BoxShadow(color: _c, blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: _c, blurRadius: 2, spreadRadius: -1, offset: Offset(0, 1)),
  ];

  /// `shadow-md`: `0 1px 3px 0 /.1, 0 2px 4px -1px /.1`
  static const md = [
    BoxShadow(color: _c, blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: _c, blurRadius: 4, spreadRadius: -1, offset: Offset(0, 2)),
  ];

  /// `shadow-lg`: `0 1px 3px 0 /.1, 0 4px 6px -1px /.1`
  static const lg = [
    BoxShadow(color: _c, blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: _c, blurRadius: 6, spreadRadius: -1, offset: Offset(0, 4)),
  ];

  /// `shadow-xl`: `0 1px 3px 0 /.1, 0 8px 10px -1px /.1`
  static const xl = [
    BoxShadow(color: _c, blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: _c, blurRadius: 10, spreadRadius: -1, offset: Offset(0, 8)),
  ];
}

/// `text-muted-foreground` (#1f2430 light / #9db1d4 dark in style.css).
Color tcMutedForeground(BuildContext context) =>
    context.isDark ? AppColors.darkMutedForeground : const Color(0xFF1F2430);

/// `bg-gradient-to-br from-emerald-500 to-emerald-700`
const emeraldGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Tw.emerald500, Tw.emerald700],
);

/// `v-html` content inside `<div class="preview">`, with the `.preview`
/// heading / paragraph / list rules of `src/style.css` and the page's text
/// colour (the web view otherwise follows the OS theme).
String previewHtml(Object? content, {required bool dark, bool breakWords = false}) => '''
<style>
  body{margin:0;font-size:16px;line-height:1.5;color:${dark ? '#e1e3e9' : '#1f2430'};
    font-family:${dark ? 'Inter' : "'Plus Jakarta Sans','Outfit',Inter"},ui-sans-serif,sans-serif,system-ui;}
  ${breakWords ? '.preview{overflow-wrap:break-word;}' : ''}
  ul{list-style-type:disc !important;margin-left:2rem;}
  ol{list-style-type:decimal !important;margin-left:2rem;}
  .preview h1{font-size:28px;font-weight:700;line-height:1.2;margin:.67em 0;}
  .preview h2{font-size:24px;font-weight:700;line-height:1.25;margin:.67em 0;}
  .preview h3{font-size:20px;font-weight:700;line-height:1.3;margin:.67em 0;}
  .preview h4{font-size:18px;font-weight:700;line-height:1.3;margin:.67em 0;}
  .preview h5{font-size:16px;font-weight:700;line-height:1.35;margin:.67em 0;}
  .preview h6{font-size:14px;font-weight:700;line-height:1.35;margin:.67em 0;}
  .preview p{font-size:15px;line-height:1.6;}
  .preview ul,.preview ol{padding-left:1.5rem;margin:.5rem 0;}
</style>
<div class="preview">${content ?? ''}</div>''';

/// The rounded square with the subject icon (`subjectBg` / `subjectColor` /
/// `subjectIconClass`). [radius] defaults to `rounded-xl` (20 with the
/// app's `--radius: 1rem`).
class SubjectIconBox extends StatelessWidget {
  const SubjectIconBox({super.key, required this.title, required this.size, this.radius = 20, this.iconSize = 16});
  final Object? title;
  final double size;
  final double radius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final theme = subjectThemeFor(title);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: theme.bg, borderRadius: BorderRadius.circular(radius)),
      child: Icon(theme.icon, size: iconSize, color: theme.color),
    );
  }
}

/// `published` emerald / `draft` amber / anything else slate.
Color courseStatusColor(Object? status) => switch (status) {
      'published' => Tw.emerald500,
      'draft' => Tw.amber400,
      _ => Tw.slate400,
    };

class StatusDot extends StatelessWidget {
  const StatusDot(this.status, {super.key, this.size = 8});
  final Object? status;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: courseStatusColor(status), shape: BoxShape.circle),
      );
}

/// `<Badge variant="secondary" class="bg-emerald-50 text-emerald-700 border
/// border-emerald-200 dark:bg-emerald-950 dark:text-emerald-400 gap-1
/// text-[11px]">`. The page never imports or registers `Badge` (and there is
/// no `ui/badge`), so the browser renders an unknown `<badge>` element: only
/// the utility classes apply — no padding, square corners, normal weight, the
/// emerald-200 border in dark mode too, and `icon + " " + label`.
class EmeraldBadge extends StatelessWidget {
  const EmeraldBadge({super.key, required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final fg = dark ? Tw.emerald400 : Tw.emerald700;
    return Container(
      decoration: BoxDecoration(
        color: dark ? TcTw.emerald950 : Tw.emerald50,
        border: Border.all(color: Tw.emerald200),
      ),
      child: Text.rich(
        TextSpan(children: [
          WidgetSpan(alignment: PlaceholderAlignment.middle, child: Icon(icon, size: 11, color: fg)),
          TextSpan(text: ' $label'),
        ]),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 11, height: 1.5, color: fg),
      ),
    );
  }
}

/// The round Edit / Delete buttons of the course cards
/// (`w-7 h-7 sm:w-8 sm:h-8 rounded-lg border border-blue-200 bg-blue-50
/// text-blue-600`; `rounded-lg` is 16px, so they render as circles).
class SquareActionButton extends StatelessWidget {
  const SquareActionButton({super.key, required this.delete, required this.onTap});
  final bool delete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = context.isSm ? 32.0 : 28.0;
    final fg = delete ? Tw.red500 : Tw.blue600;
    final bg = delete ? TcTw.red50 : Tw.blue50;
    final border = delete ? TcTw.red200 : TcTw.blue200;
    final hover = delete ? Tw.red100 : Tw.blue100;
    return Tooltip(
      message: delete ? 'Delete' : 'Edit',
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: border)),
        child: InkWell(
          onTap: onTap,
          hoverColor: hover,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(delete ? BootstrapIcons.trash3_fill : BootstrapIcons.pencil_square,
                size: context.isSm ? 12 : 11, color: fg),
          ),
        ),
      ),
    );
  }
}

/// A bare `<button><i class="bi …"></button>` with a hover colour.
class IconTapButton extends StatefulWidget {
  const IconTapButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
    this.hoverColor,
    this.size = 18,
    this.tooltip,
  });
  final IconData icon;
  final Color color;
  final Color? hoverColor;
  final double size;
  final String? tooltip;
  final VoidCallback? onTap;

  @override
  State<IconTapButton> createState() => _IconTapButtonState();
}

class _IconTapButtonState extends State<IconTapButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    Widget w = MouseRegion(
      cursor: widget.onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Icon(widget.icon,
              size: widget.size, color: _hover ? (widget.hoverColor ?? widget.color) : widget.color),
        ),
      ),
    );
    if (widget.tooltip != null) w = Tooltip(message: widget.tooltip!, child: w);
    return w;
  }
}

/// shadcn `<DropdownMenu>` opened by an outline button
/// (`w-full sm:w-64 justify-between`) with a `<DropdownMenuLabel>`, a
/// separator and one item per option.
class OutlineDropdown<T> extends StatefulWidget {
  const OutlineDropdown({
    super.key,
    required this.text,
    required this.menuLabel,
    required this.items,
    required this.onSelected,
  });

  final String text;
  final String menuLabel;
  final List<(T, String)> items;
  final ValueChanged<T> onSelected;

  @override
  State<OutlineDropdown<T>> createState() => _OutlineDropdownState<T>();
}

class _OutlineDropdownState<T> extends State<OutlineDropdown<T>> {
  final _menu = MenuController();

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final border = dark ? AppColors.darkBorder : AppColors.border;
    return MenuAnchor(
      controller: _menu,
      style: MenuStyle(
        minimumSize: const WidgetStatePropertyAll(Size(256, 0)),
        maximumSize: const WidgetStatePropertyAll(Size(256, 360)),
        backgroundColor: WidgetStatePropertyAll(dark ? Tw.slate900 : Colors.white),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        padding: const WidgetStatePropertyAll(EdgeInsets.all(4)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: border)),
        ),
      ),
      menuChildren: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(widget.menuLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ),
        Divider(height: 9, thickness: 1, color: border),
        for (final (value, label) in widget.items)
          MenuItemButton(
            onPressed: () => widget.onSelected(value),
            style: MenuItemButton.styleFrom(
              minimumSize: const Size(248, 34),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontSize: 14),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220),
              child: Text(label, overflow: TextOverflow.ellipsis),
            ),
          ),
      ],
      builder: (context, controller, _) => AppButton(
        variant: AppButtonVariant.outline,
        expand: !context.isSm,
        onPressed: () => controller.isOpen ? controller.close() : controller.open(),
        // `sm:w-64` = 256 including the button's 16px side padding.
        child: SizedBox(
          width: context.isSm ? 256 - 32 : null,
          child: Row(
            children: [
              Expanded(
                child: Text(widget.text,
                    overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
              ),
              const SizedBox(width: 8),
              // `<ChevronDown class="h-4 w-4 opacity-50" />`
              const Opacity(opacity: 0.5, child: Icon(BootstrapIcons.chevron_down, size: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

/// shadcn `<TabsList>` (`bg-muted rounded-lg` = 16px,
/// `flex gap-1 sm:gap-2 w-full sm:w-auto p-1`) + `<TabsTrigger>`s with icons
/// (`px-4 sm:px-6 py-2 rounded-xl` = 20px, `border border-transparent`,
/// active `bg-background shadow-sm`, dark active `bg-secondary border-input`).
class CourseTabs extends StatelessWidget {
  const CourseTabs({super.key, required this.tabs, required this.value, required this.onTap});

  final List<(String value, IconData icon, String label)> tabs;
  final String value;

  /// Called on every trigger click (the Preview trigger reloads even when
  /// already active).
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final wide = context.isSm;
    final muted = dark ? AppColors.darkMuted : AppColors.muted;
    final fontSize = wide ? 13.0 : 12.0;

    Widget trigger((String, IconData, String) t) {
      final (v, icon, label) = t;
      final active = v == value;
      final fg = dark
          ? (active ? AppColors.darkForeground : AppColors.darkMutedForeground)
          : AppColors.foreground;
      final radius = BorderRadius.circular(20);
      final child = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onTap(v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(horizontal: wide ? 24 : 16, vertical: 8),
            decoration: BoxDecoration(
              color: active ? (dark ? AppColors.secondary : Colors.white) : Colors.transparent,
              borderRadius: radius,
              border: Border.all(color: active && dark ? AppColors.darkBorder : Colors.transparent),
              boxShadow: active ? TcShadows.sm : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: fontSize, color: fg),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: fontSize, height: 1.5, fontWeight: FontWeight.w500, color: fg)),
                ),
              ],
            ),
          ),
        ),
      );
      return wide ? child : Expanded(child: child);
    }

    final gap = wide ? 8.0 : 4.0;
    final row = Row(
      mainAxisSize: wide ? MainAxisSize.min : MainAxisSize.max,
      children: [
        for (var i = 0; i < tabs.length; i++) ...[
          if (i > 0) SizedBox(width: gap),
          trigger(tabs[i]),
        ],
      ],
    );
    return Center(
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: muted, borderRadius: BorderRadius.circular(16)),
        child: row,
      ),
    );
  }
}

/// One shadcn `<AccordionItem>` (`border rounded-xl overflow-hidden`) whose
/// `<AccordionTrigger>` gets [headerColor] / [headerForeground]; [content]
/// is shown while [open].
///
/// The item keeps the kit's `last:border-b-0`, so the [last] item has no
/// bottom border. The trigger keeps the kit's `rounded-md` (14px) under the
/// item's clip ([headerRadius] overrides it), which leaves small notches at
/// the bottom corners of an open (coloured) header, as on the web.
class AccordionTile extends StatefulWidget {
  const AccordionTile({
    super.key,
    required this.open,
    required this.onTap,
    required this.header,
    required this.content,
    required this.headerColor,
    required this.headerForeground,
    required this.radius,
    required this.headerPadding,
    this.bold = false,
    this.last = false,
    this.headerRadius = const BorderRadius.all(Radius.circular(14)),
  });

  final bool open;
  final VoidCallback onTap;
  final Widget header;
  final Widget content;
  final Color headerColor;
  final Color headerForeground;
  final double radius;
  final EdgeInsets headerPadding;
  final bool bold;
  final bool last;
  final BorderRadius headerRadius;

  @override
  State<AccordionTile> createState() => _AccordionTileState();
}

class _AccordionTileState extends State<AccordionTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final side = BorderSide(color: dark ? Tw.slate700 : Tw.slate200);
    // The chevron keeps `text-muted-foreground`, even on the open header.
    final chevron = tcMutedForeground(context);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.radius),
        border: widget.last
            ? Border(top: side, left: side, right: side)
            : Border.fromBorderSide(side),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _hover = true),
            onExit: (_) => setState(() => _hover = false),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onTap,
              child: Container(
                decoration: BoxDecoration(color: widget.headerColor, borderRadius: widget.headerRadius),
                padding: widget.headerPadding,
                child: DefaultTextStyle.merge(
                  style: TextStyle(
                    color: widget.headerForeground,
                    fontSize: 14,
                    fontWeight: widget.bold ? FontWeight.w700 : FontWeight.w500,
                    decoration: _hover ? TextDecoration.underline : null,
                    decorationColor: widget.headerForeground,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: widget.header),
                      const SizedBox(width: 16),
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: AnimatedRotation(
                          turns: widget.open ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(BootstrapIcons.chevron_down, size: 16, color: chevron),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: widget.open ? widget.content : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

/// The black `url`-content box: image, `<video>`, YouTube / Vimeo / PDF
/// iframes, any embeddable site, or the "Cannot preview" fallback.
class UrlMediaBox extends StatelessWidget {
  const UrlMediaBox({super.key, required this.url, required this.height, required this.cannotPreviewText});
  final String url;
  final double height;
  final String cannotPreviewText;

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (isImageUrl(url)) {
      child = Image.network(url,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const Icon(BootstrapIcons.image, color: Tw.slate400, size: 30));
    } else if (isVideoUrl(url)) {
      child = WebContentView(
        html: '<video controls style="width:100%;max-height:96vh;background:#000">'
            '<source src="${_attr(url)}"></video>',
      );
    } else if (isYouTubeUrl(url)) {
      child = WebContentView(url: 'https://www.youtube.com/embed/${youTubeId(url)}');
    } else if (isVimeoUrl(url)) {
      child = WebContentView(url: 'https://player.vimeo.com/video/${vimeoId(url)}');
    } else if (isPdfUrl(url)) {
      child = WebContentView(url: pdfEmbedUrl(url), showOpenExternally: true);
    } else if (canEmbedUrl(url)) {
      child = WebContentView(url: url);
    } else {
      child = Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(cannotPreviewText,
                textAlign: TextAlign.center,
                style: const TextStyle(color: TcTw.red400, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => openExternal(url),
              child: Text(url,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: TcTw.blue300, decoration: TextDecoration.underline, decorationColor: TcTw.blue300)),
            ),
          ],
        ),
      );
    }
    // `bg-black rounded-xl overflow-hidden` (20px).
    return Container(
      height: height,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
      child: child,
    );
  }

  static String _attr(String s) => s.replaceAll('&', '&amp;').replaceAll('"', '&quot;');
}

/// The page's dialog footers are a plain
/// `<div class="flex justify-end gap-2 mt-4">` (not `<DialogFooter>`): a
/// right-aligned row at every width,
/// 16px (`mt-4`) + 16px (the content's `gap-4`) below the body, scrolling
/// with it in the `max-h-[90vh] overflow-y-auto` dialogs.
Widget tcDialogFooter(List<Widget> buttons) => Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          for (var i = 0; i < buttons.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Flexible(child: buttons[i]),
          ],
        ],
      ),
    );

/// The "Confirm Delete" / "Confirm Detach" dialogs: a title, a description
/// (rich, for the bold names), `No` (outline) and a red confirm button.
/// [onConfirm] runs with the button disabled; the dialog closes when it
/// returns `true` and stays open otherwise (like the web on errors).
Future<void> showTcConfirm(
  BuildContext context, {
  required String title,
  required InlineSpan message,
  required Future<bool> Function() onConfirm,
  String confirmLabel = 'Yes',
}) =>
    showAppDialog<void>(
      context,
      builder: (_) => _ConfirmDialog(title: title, message: message, onConfirm: onConfirm, confirmLabel: confirmLabel),
    );

class _ConfirmDialog extends StatefulWidget {
  const _ConfirmDialog({required this.title, required this.message, required this.onConfirm, required this.confirmLabel});
  final String title;
  final InlineSpan message;
  final Future<bool> Function() onConfirm;
  final String confirmLabel;

  @override
  State<_ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<_ConfirmDialog> {
  bool _busy = false;

  Future<void> _confirm() async {
    setState(() => _busy = true);
    final ok = await widget.onConfirm();
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // `<DialogDescription>`: `text-muted-foreground text-sm`.
    return AppDialogFrame(
      title: widget.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text.rich(widget.message, style: TextStyle(fontSize: 14, height: 1.43, color: tcMutedForeground(context))),
          tcDialogFooter([
            AppButton(label: 'No', variant: AppButtonVariant.outline, onPressed: () => Navigator.of(context).pop()),
            AppButton(
              label: widget.confirmLabel,
              backgroundColor: Tw.red500,
              foregroundColor: Colors.white,
              onPressed: _busy ? null : _confirm,
            ),
          ]),
        ],
      ),
    );
  }
}

/// The `<i class="bi bi-file-earmark-richtext text-indigo-500">` / pdf /
/// link icon of a content row.
Widget? contentTypeIcon(Object? type, double size) => switch (type) {
      'html' => Icon(BootstrapIcons.file_earmark_richtext, size: size, color: Tw.indigo500),
      'pdf' => Icon(BootstrapIcons.filetype_pdf, size: size, color: Tw.red500),
      'url' => Icon(BootstrapIcons.link_45deg, size: size, color: Tw.blue500),
      _ => null,
    };
