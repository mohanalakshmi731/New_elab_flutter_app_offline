part of 'schedules_page.dart';

Color _borderColor(BuildContext context) => context.isDark ? AppColors.darkBorder : AppColors.border;

/// `text-muted-foreground` (#1f2430 light — the web's quirk — / #9db1d4 dark).
Color _mutedFg(BuildContext context) =>
    context.isDark ? AppColors.darkMutedForeground : AppColors.mutedForeground;

/// `text-foreground`
Color _fg(BuildContext context) => context.isDark ? AppColors.darkForeground : AppColors.foreground;

/// `bg-card`
Color _cardBg(BuildContext context) => context.isDark ? AppColors.darkCard : AppColors.card;

/// The placeholder / chevron colour of the shared `AppSelect` trigger, so the
/// page's own select triggers look the same.
Color _selectMuted(BuildContext context) => context.isDark ? AppColors.darkMutedForeground : Tw.slate500;

/// Width of [text] in [style] (for the web's content-sized `w-fit` boxes).
double _textWidth(BuildContext context, String text, TextStyle style) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: DefaultTextStyle.of(context).style.merge(style)),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
    maxLines: 1,
  )..layout();
  final w = painter.width;
  painter.dispose();
  return w;
}

/// A `<SelectTrigger class="w-full">` inside a content-sized flex item: as
/// wide as its text + `px-3`, `gap-2`, the 16 px chevron and the border.
double _selectFitWidth(BuildContext context, String text) =>
    _textWidth(context, text, const TextStyle(fontSize: 14)) + 50;

/// The page's big glass card (`bg-white/75 dark:bg-slate-900/80
/// backdrop-blur-2xl border-2 rounded-[32px] p-4 sm:p-5 md:p-6`).
class _PageCard extends StatelessWidget {
  const _PageCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final pad = context.isMd
        ? 24.0
        : context.isSm
            ? 20.0
            : 16.0;
    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: dark ? Tw.slate900.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          width: 2,
          color: dark ? Tw.slate800.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.15),
            blurRadius: 50,
            spreadRadius: -12,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// One `<AccordionItem>`: the trigger (`rounded-sm px-5 py-4 text-sm
/// font-medium hover:underline`, open → `bg-primary text-white`, chevron
/// `text-muted-foreground` rotated; a `<button>`, so the default cursor) and
/// the content (`p-2`).
class _AccordionItem extends StatefulWidget {
  const _AccordionItem({
    required this.open,
    required this.onToggle,
    required this.header,
    required this.content,
    this.bottomBorder = false,
  });

  final bool open;
  final VoidCallback onToggle;
  final Widget Function(bool open) header;
  final Widget Function() content;

  /// `border-b` (every item but the last of an accordion).
  final bool bottomBorder;

  @override
  State<_AccordionItem> createState() => _AccordionItemState();
}

class _AccordionItemState extends State<_AccordionItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final open = widget.open;
    final fg = open ? Colors.white : null;
    final trigger = MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: open ? context.colors.primary : context.colors.primary.withValues(alpha: 0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: fg,
              decoration: _hover ? TextDecoration.underline : TextDecoration.none,
              decorationColor: fg ?? _fg(context),
            ),
            child: IconTheme.merge(
              data: IconThemeData(color: fg),
              child: Row(
                children: [
                  Expanded(child: widget.header(open)),
                  const SizedBox(width: 16),
                  Transform.translate(
                    offset: const Offset(0, 2),
                    child: AnimatedRotation(
                      turns: open ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(BootstrapIcons.chevron_down, size: 16, color: _mutedFg(context)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return Container(
      decoration:
          widget.bottomBorder ? BoxDecoration(border: Border(bottom: BorderSide(color: _borderColor(context)))) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          trigger,
          if (open) Padding(padding: const EdgeInsets.all(8), child: widget.content()),
        ],
      ),
    );
  }
}

/// The ongoing trigger's pills (`px-3 py-1 rounded-full font-medium`,
/// `w-full sm:w-auto`).
class _Pill extends StatelessWidget {
  const _Pill(this.text, {required this.bg, required this.fg, this.bold = false});
  final String text;
  final Color bg;
  final Color fg;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, color: fg, fontWeight: bold ? FontWeight.w600 : FontWeight.w500),
      ),
    );
    return context.isSm ? pill : SizedBox(width: double.infinity, child: pill);
  }
}

/// `.badge` (`px-3 py-2 rounded-full font-medium text-center w-[180px]
/// break-words`); `.badge-indigo` also turns `bg-indigo-200` on hover.
class _Badge extends StatefulWidget {
  const _Badge(this.text, {required this.bg, required this.fg, this.bold = false, this.hoverBg});
  final String text;
  final Color bg;
  final Color fg;
  final bool bold;
  final Color? hoverBg;

  @override
  State<_Badge> createState() => _BadgeState();
}

class _BadgeState extends State<_Badge> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final w = widget;
    Widget badge = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 180,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _hover && w.hoverBg != null ? w.hoverBg : w.bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        w.text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14, color: w.fg, fontWeight: w.bold ? FontWeight.w600 : FontWeight.w500),
      ),
    );
    if (w.hoverBg != null) {
      badge = MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: badge,
      );
    }
    return badge;
  }
}

/// A clickable `<i class="bi …">` that does not toggle the accordion
/// (`@click.stop`). [pointer]: `cursor-pointer`.
class _IconAction extends StatelessWidget {
  const _IconAction(this.icon, {required this.onTap, this.color, this.size = 14, this.pointer = true});
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final double size;
  final bool pointer;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: pointer ? SystemMouseCursors.click : MouseCursor.defer,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Icon(icon, size: size, color: color),
        ),
      );
}

/// Colours of an active shadcn `TabsTrigger` whose page class sets
/// `data-[state=active]:bg-… text-white`: in dark mode the trigger's own
/// `dark:data-[state=active]:bg-input/30 text-foreground border-input` are
/// more specific and win.
({Color bg, Color fg, Color border}) _activeTabColors(BuildContext context, Color lightBg) => context.isDark
    ? (bg: AppColors.darkInput.withValues(alpha: 0.3), fg: AppColors.darkForeground, border: AppColors.darkInput)
    : (bg: lightBg, fg: Colors.white, border: Colors.transparent);

/// Inactive `TabsTrigger` text (`text-foreground dark:text-muted-foreground`).
Color _inactiveTabFg(BuildContext context) =>
    context.isDark ? AppColors.darkMutedForeground : AppColors.foreground;

/// The ≥2xl schedule-type tabs (`TabsList h-9 bg-white/85 border rounded-xl
/// p-1 gap-3`, triggers `h-[calc(100%-1px)] rounded-lg px-4 py-2 font-bold
/// text-xs cursor-pointer`, active `bg-indigo-600 text-white shadow-sm`).
class _OuterTabs extends StatelessWidget {
  const _OuterTabs({required this.tabs, required this.value, required this.onChanged});
  final List<(String, String)> tabs;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Container(
      height: 36,
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 5),
      decoration: BoxDecoration(
        color: dark ? Tw.slate900.withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dark ? Tw.slate800.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < tabs.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            _tab(context, tabs[i].$1, tabs[i].$2),
          ],
        ],
      ),
    );
  }

  Widget _tab(BuildContext context, String v, String label) {
    final active = v == value;
    final a = _activeTabColors(context, Tw.indigo600);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onChanged(v),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: active ? a.bg : a.bg.withValues(alpha: 0),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: active ? a.border : Colors.transparent),
            boxShadow: active ? AppShadows.sm : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w700,
              color: active ? a.fg : _inactiveTabFg(context),
            ),
          ),
        ),
      ),
    );
  }
}

/// The schedule section tabs (`TabsList bg-muted h-9 p-[3px] rounded-lg
/// gap-4`, triggers `h-[calc(100%-1px)] rounded-md px-4 py-2 text-sm
/// font-medium`, active `bg-primary text-white shadow-sm`).
class _SectionTabsList extends StatelessWidget {
  const _SectionTabsList({required this.tabs, required this.value, required this.onTap});
  final List<(String, String)> tabs;
  final String value;
  final ValueChanged<String> onTap;

  /// The list's natural width (the panel's min-content on the web).
  static double naturalWidth(BuildContext context, List<String> labels) {
    var w = 6.0 + 16.0 * (labels.length - 1);
    for (final l in labels) {
      w += _textWidth(context, l, const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)) + 34;
    }
    return w;
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Container(
      height: 36,
      padding: const EdgeInsets.fromLTRB(3, 3, 3, 4),
      decoration: BoxDecoration(
        color: dark ? AppColors.darkMuted : AppColors.muted,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < tabs.length; i++) ...[
            if (i > 0) const SizedBox(width: 16),
            _tab(context, tabs[i].$1, tabs[i].$2),
          ],
        ],
      ),
    );
  }

  Widget _tab(BuildContext context, String v, String label) {
    final active = v == value;
    final a = _activeTabColors(context, context.colors.primary);
    return GestureDetector(
      onTap: () => onTap(v),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: active ? a.bg : a.bg.withValues(alpha: 0),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: active ? a.border : Colors.transparent),
          boxShadow: active ? AppShadows.sm : null,
        ),
        child: Text(
          label,
          softWrap: false,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: active ? a.fg : _inactiveTabFg(context),
          ),
        ),
      ),
    );
  }
}

/// `<Input type="time">` — the value is `HH:mm` (24 h); shown as `hh:mm AM`.
class _TimeInput extends StatelessWidget {
  const _TimeInput({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  static TimeOfDay? _parse(String v) {
    final m = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(v.trim());
    if (m == null) return null;
    final h = int.parse(m.group(1)!);
    final min = int.parse(m.group(2)!);
    if (h > 23 || min > 59) return null;
    return TimeOfDay(hour: h, minute: min);
  }

  @override
  Widget build(BuildContext context) {
    final t = _parse(value);
    String two(int n) => n.toString().padLeft(2, '0');
    return AppTextField(
      key: ValueKey('time-$value'),
      initialValue: t == null ? '' : DateFormat('hh:mm a', 'en_US').format(DateTime(2000, 1, 1, t.hour, t.minute)),
      hint: '--:-- --',
      readOnly: true,
      suffix: const Icon(BootstrapIcons.clock, size: 14),
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: t ?? TimeOfDay.now());
        if (picked != null) onChanged('${two(picked.hour)}:${two(picked.minute)}');
      },
    );
  }
}

/// The `<Popover><Calendar>` date buttons (`<Button variant="outline"
/// class="w-full justify-start text-left font-normal">`): the `YYYY-MM-DD`
/// value or the placeholder.
class _DateButton extends StatelessWidget {
  const _DateButton({required this.value, required this.placeholder, required this.onChanged});
  final String value;
  final String placeholder;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => AppButton(
        variant: AppButtonVariant.outline,
        expand: true,
        fontWeight: FontWeight.w400,
        onPressed: () async {
          final now = DateTime.now();
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.tryParse(value) ?? now,
            firstDate: DateTime(1900),
            lastDate: DateTime(now.year + 50),
          );
          if (picked != null) onChanged(DateFormat('yyyy-MM-dd').format(picked));
        },
        child: SizedBox(
          width: double.infinity,
          child: Text(value.isEmpty ? placeholder : value, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      );
}

/// `<Select multiple>` with the selected labels joined in the trigger and an
/// optional empty-state row ("No batches available").
class _MultiSelect extends StatefulWidget {
  const _MultiSelect({
    required this.values,
    required this.items,
    required this.onChanged,
    required this.placeholder,
    this.emptyText,
    this.groupLabel,
  });

  final List<String> values;
  final List<(String, String)> items;
  final ValueChanged<List<String>> onChanged;
  final String placeholder;
  final String? emptyText;

  /// `<SelectLabel>` above the items (`px-2 py-1.5 text-sm font-medium`).
  final String? groupLabel;

  @override
  State<_MultiSelect> createState() => _MultiSelectState();
}

class _MultiSelectState extends State<_MultiSelect> {
  final _menu = MenuController();

  @override
  Widget build(BuildContext context) {
    final labels = [
      for (final (v, l) in widget.items)
        if (widget.values.contains(v)) l,
    ];
    final text = labels.isEmpty ? widget.placeholder : labels.join(', ');
    return LayoutBuilder(builder: (context, c) {
      final width = c.maxWidth.isFinite ? c.maxWidth : 260.0;
      return MenuAnchor(
        controller: _menu,
        crossAxisUnconstrained: false,
        style: _menuStyle(context, width),
        menuChildren: [
          if (widget.groupLabel != null)
            SizedBox(
              width: width - 8,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Text(widget.groupLabel!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ),
            ),
          if (widget.items.isEmpty && widget.emptyText != null)
            SizedBox(
              width: width - 8,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(widget.emptyText!,
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: _mutedFg(context))),
              ),
            ),
          for (final (value, label) in widget.items)
            MenuItemButton(
              closeOnActivate: false,
              onPressed: () => widget.onChanged(widget.values.contains(value)
                  ? [for (final v in widget.values) if (v != value) v]
                  : [...widget.values, value]),
              style: _menuItemStyle(width),
              trailingIcon: widget.values.contains(value) ? const Icon(Icons.check, size: 16) : null,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: width - 48),
                child: Text(label, overflow: TextOverflow.ellipsis),
              ),
            ),
        ],
        builder: (context, controller, _) => _SelectTrigger(
          text: text,
          placeholder: labels.isEmpty,
          open: controller.isOpen,
          onTap: () => controller.isOpen ? controller.close() : controller.open(),
        ),
      );
    });
  }
}

MenuStyle _menuStyle(BuildContext context, double width) {
  final dark = context.isDark;
  return MenuStyle(
    minimumSize: WidgetStatePropertyAll(Size(width, 0)),
    maximumSize: WidgetStatePropertyAll(Size(width < 200 ? 240 : width, 320)),
    backgroundColor: WidgetStatePropertyAll(dark ? Tw.slate900 : Colors.white),
    surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
    padding: const WidgetStatePropertyAll(EdgeInsets.all(4)),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: dark ? AppColors.darkBorder : AppColors.border),
      ),
    ),
  );
}

ButtonStyle _menuItemStyle(double width) => MenuItemButton.styleFrom(
      minimumSize: Size(width - 8, 34),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontSize: 14),
    );

/// `<SelectTrigger class="w-full">`
class _SelectTrigger extends StatelessWidget {
  const _SelectTrigger({required this.text, required this.placeholder, required this.open, required this.onTap});
  final String text;
  final bool placeholder;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final muted = _selectMuted(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        isEmpty: placeholder,
        isFocused: open,
        decoration: InputDecoration(
          suffixIcon: Icon(BootstrapIcons.chevron_down, size: 14, color: muted.withValues(alpha: 0.8)),
          suffixIconConstraints: const BoxConstraints(minWidth: 34, minHeight: 20),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 14, color: placeholder ? muted : null),
        ),
      ),
    );
  }
}

/// The slot dialog's Instructor `<Select>` with the "Search Instructor..."
/// box inside its menu (`filteredInstructors`: 5 matches by email).
class _InstructorSelect extends StatefulWidget {
  const _InstructorSelect({
    required this.value,
    required this.selectedLabel,
    required this.options,
    required this.search,
    required this.onChanged,
  });

  final String? value;
  final String? selectedLabel;
  final List<(String, String)> options;
  final TextEditingController search;
  final ValueChanged<String> onChanged;

  @override
  State<_InstructorSelect> createState() => _InstructorSelectState();
}

class _InstructorSelectState extends State<_InstructorSelect> {
  final _menu = MenuController();

  @override
  Widget build(BuildContext context) {
    final label = widget.selectedLabel;
    return LayoutBuilder(builder: (context, c) {
      final width = c.maxWidth.isFinite ? c.maxWidth : 260.0;
      return MenuAnchor(
        controller: _menu,
        crossAxisUnconstrained: false,
        style: _menuStyle(context, width),
        menuChildren: [
          SizedBox(
            width: width - 8,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                controller: widget.search,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(hintText: 'Search Instructor...', isDense: true),
              ),
            ),
          ),
          for (final (value, text) in widget.options)
            MenuItemButton(
              onPressed: () => widget.onChanged(value),
              style: _menuItemStyle(width),
              trailingIcon: value == widget.value ? const Icon(Icons.check, size: 16) : null,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: width - 48),
                child: Text(text, overflow: TextOverflow.ellipsis),
              ),
            ),
          if (widget.options.isEmpty)
            SizedBox(
              width: width - 8,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Text('No Instructor', textAlign: TextAlign.center, style: TextStyle(color: Tw.gray500)),
              ),
            ),
        ],
        builder: (context, controller, _) => _SelectTrigger(
          text: label ?? 'Select Instructor',
          placeholder: label == null,
          open: controller.isOpen,
          onTap: () => controller.isOpen ? controller.close() : controller.open(),
        ),
      );
    });
  }
}

/// The dialogs' "Link to LMS" toggle (`bi-toggle-on text-green-600` /
/// `bi-toggle-off text-gray-500`, `text-4xl`). The label's own click handler
/// toggled a second time on the web, so only the icon switches the mode.
class _LmsToggle extends StatelessWidget {
  const _LmsToggle({required this.on, required this.onToggle});
  final bool on;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  on ? BootstrapIcons.toggle_on : BootstrapIcons.toggle_off,
                  size: 36,
                  color: on ? Tw.green600 : Tw.gray500,
                ),
              ),
            ),
          ),
          const Text('Link to LMS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      );
}

/// A bordered `h-[500px] rounded-lg p-4 shadow-sm|shadow-md` panel of the
/// schedule details (no background of its own).
class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.shadowMd = false, this.width});
  final Widget child;
  final bool shadowMd;
  final double? width;

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: 500,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor(context)),
          boxShadow: shadowMd ? AppShadows.md : AppShadows.sm,
        ),
        child: child,
      );
}

/// `<Card class="… p-0 rounded-md border shadow-sm|shadow-md overflow-hidden">`
/// around a table.
class _TableCard extends StatelessWidget {
  const _TableCard({required this.child, this.shadowMd = false});
  final Widget child;
  final bool shadowMd;

  @override
  Widget build(BuildContext context) => Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: _cardBg(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _borderColor(context)),
          boxShadow: shadowMd ? AppShadows.md : AppShadows.sm,
        ),
        child: child,
      );
}

/// A shadcn `<Table>` (`text-sm`; `thead th` = `bg-primary
/// text-primary-foreground px-4 py-2` from style.css; cells `p-2`; rows
/// `border-b hover:bg-…`) whose empty state is a full-width `colspan` cell.
class _SchedTable extends StatelessWidget {
  const _SchedTable({
    required this.columns,
    required this.rows,
    required this.emptyText,
    this.emptyColor = Tw.gray500,
    this.emptyPadding = 24,
    this.minWidth = 0,
    this.hoverColor,
  });

  /// `(label, flex, alignEnd)`
  final List<(String, double, bool)> columns;
  final List<List<Widget>> rows;
  final String emptyText;
  final Color emptyColor;

  /// `py-6` / `py-8` of the empty cell.
  final double emptyPadding;

  /// `min-w-[…]`; the table scrolls horizontally below it.
  final double minWidth;

  /// Row hover (`hover:bg-muted/50` when null).
  final Color? hoverColor;

  @override
  Widget build(BuildContext context) {
    final border = _borderColor(context);
    Widget row(List<Widget> cells, {bool header = false, bool last = false}) {
      final r = Row(
        children: [
          for (var i = 0; i < columns.length; i++)
            Expanded(
              flex: (columns[i].$2 * 100).round(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: header ? 16 : 8, vertical: 8),
                child: Align(
                  alignment: columns[i].$3 ? Alignment.centerRight : Alignment.centerLeft,
                  child: cells[i],
                ),
              ),
            ),
        ],
      );
      final decoration = BoxDecoration(
        color: header ? context.colors.primary : null,
        border: last ? null : Border(bottom: BorderSide(color: border)),
      );
      return _HoverBox(
        hover: !header,
        hoverColor: hoverColor ?? (context.isDark ? AppColors.darkMuted : AppColors.muted).withValues(alpha: 0.5),
        decoration: decoration,
        child: ConstrainedBox(constraints: BoxConstraints(minHeight: header ? 40 : 0), child: r),
      );
    }

    return LayoutBuilder(builder: (context, c) {
      final width = c.maxWidth.isFinite ? math.max(c.maxWidth, minWidth) : minWidth;
      final table = DefaultTextStyle.merge(
        style: const TextStyle(fontSize: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            row([
              for (final col in columns)
                Text(col.$1,
                    softWrap: false,
                    style: TextStyle(fontWeight: FontWeight.w500, color: context.colors.onPrimary)),
            ], header: true, last: false),
            if (rows.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: emptyPadding, horizontal: 8),
                child: Text(emptyText, textAlign: TextAlign.center, style: TextStyle(color: emptyColor)),
              )
            else
              for (var i = 0; i < rows.length; i++) row(rows[i], last: i == rows.length - 1),
          ],
        ),
      );
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(width: width, child: table),
      );
    });
  }
}

/// A row that tints on hover.
class _HoverBox extends StatefulWidget {
  const _HoverBox({required this.child, required this.decoration, required this.hoverColor, this.hover = true});
  final Widget child;
  final BoxDecoration decoration;
  final Color hoverColor;
  final bool hover;

  @override
  State<_HoverBox> createState() => _HoverBoxState();
}

class _HoverBoxState extends State<_HoverBox> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final box = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: _hovered ? widget.decoration.copyWith(color: widget.hoverColor) : widget.decoration,
      child: widget.child,
    );
    if (!widget.hover) return box;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: box,
    );
  }
}

/// `<i class="bi … cursor-pointer hover:scale-110 transition">` in a table
/// (`table .bi { font-size: 18px }`).
class _ScaleIcon extends StatefulWidget {
  const _ScaleIcon(this.icon, {required this.color, required this.onTap});
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  State<_ScaleIcon> createState() => _ScaleIconState();
}

class _ScaleIconState extends State<_ScaleIcon> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _hover ? 1.1 : 1,
            duration: const Duration(milliseconds: 150),
            child: Icon(widget.icon, size: 18, color: widget.color),
          ),
        ),
      );
}

/// The chat messages (`flex-1 overflow-y-auto p-3 space-y-3`), scrolled to
/// the newest message whenever one arrives.
class _ChatList extends StatefulWidget {
  const _ChatList({required this.messages, required this.headerGap});
  final List<ChatMessage> messages;

  /// `mb-4` (ongoing) / `mb-1` between the sender row and the text.
  final double headerGap;

  @override
  State<_ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<_ChatList> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _toEnd();
  }

  @override
  void didUpdateWidget(covariant _ChatList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.messages, widget.messages)) _toEnd();
  }

  void _toEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, c) => ListView.separated(
          controller: _scroll,
          padding: const EdgeInsets.all(12),
          itemCount: widget.messages.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) => _bubble(widget.messages[i], c.maxWidth * 0.75),
        ),
      );

  /// `max-w-[75%] px-3 py-2 rounded-lg text-sm shadow`, `rounded-br-none` /
  /// `rounded-bl-none`; the sender / time row is `justify-between` across the
  /// bubble's content width.
  Widget _bubble(ChatMessage msg, double maxWidth) {
    final mine = msg.mine;
    const r = Radius.circular(16);
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: mine ? Tw.blue500 : Tw.gray200,
            borderRadius: BorderRadius.only(
              topLeft: r,
              topRight: r,
              bottomLeft: mine ? r : Radius.zero,
              bottomRight: mine ? Radius.zero : r,
            ),
            boxShadow: AppShadows.sm,
          ),
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        msg.sender,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: mine ? Tw.blue100 : Tw.gray600,
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: 0.7,
                      child: Text(msg.time, style: TextStyle(fontSize: 10, color: mine ? Tw.blue100 : Tw.gray500)),
                    ),
                  ],
                ),
                SizedBox(height: widget.headerGap),
                Text(vText(msg.text), style: TextStyle(fontSize: 14, color: mine ? Colors.white : Tw.gray800)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A card with the `group-hover` blue border of the preview slots.
class _HoverBorderCard extends StatefulWidget {
  const _HoverBorderCard({required this.child, required this.onTap, required this.radius, this.hoverBorder = true});
  final Widget child;
  final VoidCallback onTap;
  final double radius;
  final bool hoverBorder;

  @override
  State<_HoverBorderCard> createState() => _HoverBorderCardState();
}

class _HoverBorderCardState extends State<_HoverBorderCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Stack(
            children: [
              widget.child,
              if (widget.hoverBorder)
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      opacity: _hover ? 1 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(widget.radius),
                          border: Border.all(color: Tw.blue500, width: 2),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
}

/// A `Label / value` row of the slot cards.
class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow(this.label, this.value, {this.valueColor, this.bold = true, this.center = false});
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  /// `items-center` (preview cards) instead of `items-start`.
  final bool center;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: context.colors.primary)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
                color: valueColor ?? Tw.gray700,
              ),
            ),
          ),
        ],
      );
}

/// `<Label>` + control with the `space-y-1` / `space-y-2` gap (0 when the
/// template has none). [required]: `Label<span class="text-red-500">*</span>`
/// — the star is a second flex item of the `gap-2` label.
Widget _labeled(String label, Widget child, {double gap = 8, bool required = false}) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (required)
          Row(
            children: [
              Flexible(child: FieldLabel(label)),
              const SizedBox(width: 8),
              const Text('*', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1, color: Tw.red500)),
            ],
          )
        else
          FieldLabel(label),
        SizedBox(height: gap),
        child,
      ],
    );

/// `<DialogHeader>` (`flex flex-col gap-2 text-center sm:text-left`) with its
/// `<DialogTitle>` (`text-lg leading-none font-semibold`) and optional
/// `<DialogDescription>` (`text-muted-foreground text-sm`), or [plain] text
/// placed straight in the header.
Widget _dialogHeader(BuildContext context, String title, {String? description, Color? titleColor, bool plain = false}) {
  final sm = context.isSm;
  final align = sm ? TextAlign.left : TextAlign.center;
  return Padding(
    // Keeps left-aligned text clear of the close button.
    padding: EdgeInsets.only(right: sm ? 28 : 0),
    child: Column(
      crossAxisAlignment: sm ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          textAlign: align,
          style: plain
              ? const TextStyle(fontSize: 16)
              : TextStyle(fontSize: 18, height: 1, fontWeight: FontWeight.w600, color: titleColor),
        ),
        if (description != null) ...[
          const SizedBox(height: 8),
          Text(description, textAlign: align, style: TextStyle(fontSize: 14, color: _mutedFg(context))),
        ],
      ],
    ),
  );
}

/// A fixed-width form block (`w-72` / `w-80`), full width on narrow screens.
Widget _fixedWidth(BuildContext context, double width, Widget child) => Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(width: math.min(width, MediaQuery.sizeOf(context).width - 96), child: child),
    );
