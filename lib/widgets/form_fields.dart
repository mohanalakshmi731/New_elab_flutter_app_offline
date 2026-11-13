import 'dart:math' as math;

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import 'app_button.dart';
import 'lucide_icon.dart';

/// shadcn `<Label>` / `<FormLabel>`: `flex items-center gap-2 text-sm
/// leading-none font-medium`, `text-destructive` when the field has an
/// error, optional `<span class="text-red-500">*</span>` (8px gap).
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key, this.required = false, this.error = false});
  final String text;
  final bool required;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1,
        color: error ? context.destructiveColor : null,
      ),
    );
    if (!required) return label;
    return Text.rich(
      TextSpan(children: [
        TextSpan(text: text),
        const WidgetSpan(child: SizedBox(width: 8)),
        const TextSpan(text: '*', style: TextStyle(color: Tw.red500)),
      ]),
      style: label.style,
    );
  }
}

/// Wraps any control with a [FieldLabel] above it (`<FormItem>` = `grid gap-2`).
class LabeledField extends StatelessWidget {
  const LabeledField({super.key, required this.label, required this.child, this.required = false});
  final String label;
  final Widget child;
  final bool required;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(alignment: AlignmentDirectional.centerStart, child: FieldLabel(label, required: required)),
          const SizedBox(height: 8),
          child,
        ],
      );
}

/// Text style of a shadcn `<Input>`: `text-base md:text-sm` (16px/24 on
/// phones, 14px/20 from 768px).
TextStyle appInputTextStyle(BuildContext context, {double? fontSize}) {
  final md = context.isMd;
  final size = fontSize ?? (md ? 14.0 : 16.0);
  return TextStyle(
    fontSize: size,
    // text-sm → 20px line, text-base → 24px, others ×1.5
    height: size == 14 ? 20 / 14 : (size == 12 ? 16 / 12 : 1.5),
    leadingDistribution: TextLeadingDistribution.even,
    color: context.colors.onSurface,
  );
}

/// shadcn `<Input>` / `<Textarea>` inside a `<FormItem>`: optional label,
/// validator (for `Form.validate()`), and the error text below
/// (`<FormMessage>`, `text-destructive text-sm`).
///
/// Input: `h-9 rounded-md border border-input px-3 py-1 bg-transparent
/// dark:bg-input/30`, placeholder #9ca3af, focus `border-ring ring-[3px]
/// ring-ring/50`. Textarea (`maxLines != 1`): `min-h-16 px-3 py-2`, grows
/// with the content.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.label,
    this.required = false,
    this.hint,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.suffix,
    this.errorText,
    this.autofillHints,
    this.onTap,
    this.focusNode,
    this.fillColor,
    this.height,
    this.fontSize,
    this.iconSize = 16,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final String? label;

  /// Adds the red `*` after the label (does not validate by itself).
  final bool required;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;

  /// Use `maxLines: null` / `minLines: 3` for a `<Textarea>`.
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final IconData? prefixIcon;
  final Widget? suffix;

  /// Server-side / manual error (shown like a validator error).
  final String? errorText;
  final Iterable<String>? autofillHints;
  final VoidCallback? onTap;
  final FocusNode? focusNode;

  /// `bg-…` override (e.g. `bg-white`); default transparent / dark `input/30`.
  final Color? fillColor;

  /// `h-…` override for single-line inputs (default `h-9` = 36).
  final double? height;

  /// `text-…` override (default `text-base md:text-sm`).
  final double? fontSize;

  /// Size of [prefixIcon].
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final style = appInputTextStyle(context, fontSize: fontSize);
    final lineHeight = style.fontSize! * style.height!;
    final multiline = !obscureText && maxLines != 1;
    final h = height ?? 36;
    final field = TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      keyboardType: keyboardType ?? (multiline ? TextInputType.multiline : null),
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      readOnly: readOnly,
      enabled: enabled,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      maxLength: maxLength,
      autofillHints: autofillHints,
      onTap: onTap,
      focusNode: focusNode,
      style: style,
      textAlignVertical: multiline ? TextAlignVertical.top : TextAlignVertical.center,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: style.copyWith(color: AppColors.placeholder),
        errorText: errorText,
        fillColor: fillColor,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: multiline ? 8 : math.max(0.0, (h - lineHeight) / 2),
        ),
        // `min-h-16` for textareas.
        constraints: multiline ? const BoxConstraints(minHeight: 64) : null,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: iconSize),
        prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 20),
        suffixIcon: suffix,
        suffixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 20),
        counterText: '',
      ),
    );
    // `disabled:opacity-50`
    final control = enabled ? field : Opacity(opacity: 0.5, child: field);
    if (label == null) return control;
    return LabeledField(label: label!, required: required, child: control);
  }
}

/// One `<SelectItem :value>` of an [AppSelect].
class AppSelectItem<T> {
  const AppSelectItem(this.value, this.label, {this.enabled = true, this.isLabel = false})
      : isMessage = false,
        messagePadding = null,
        messageFontSize = null,
        messageColor = null;

  /// A plain, centred, undimmed note row inside the menu, e.g. the web's
  /// `<div v-else class="py-3 text-center text-sm text-muted-foreground">No
  /// batches available</div>`. Not selectable; [value] is ignored. Defaults:
  /// `px-3 py-2 text-sm text-muted-foreground`.
  const AppSelectItem.message(
    this.value,
    this.label, {
    this.messagePadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.messageFontSize = 14,
    this.messageColor,
  })  : enabled = false,
        isLabel = false,
        isMessage = true;

  final T value;
  final String label;
  final bool enabled;

  /// A `<SelectLabel>` group heading (`px-2 py-1.5 text-sm font-medium`):
  /// not selectable and not dimmed; [value] is ignored.
  final bool isLabel;

  /// See [AppSelectItem.message].
  final bool isMessage;
  final EdgeInsets? messagePadding;
  final double? messageFontSize;

  /// Defaults to `text-muted-foreground`.
  final Color? messageColor;
}

/// shadcn `<Select>`: a bordered trigger with a chevron that opens a menu of
/// [items]; the selected one shows a check. Controlled: pass [value] and
/// update it in [onChanged]. Works inside a [Form] when [validator] is set.
///
/// Trigger: `h-9 rounded-md border border-input px-3 py-2 text-sm shadow-xs
/// bg-transparent dark:bg-input/30 dark:hover:bg-input/50`, placeholder
/// #9ca3af, `ChevronDown size-4 opacity-50`. Content: `bg-popover border
/// rounded-md p-1 shadow-md`, 4px below the trigger and at least as wide;
/// items `rounded-sm py-1.5 pl-2 pr-8` turn `bg-accent` (#f49148) when
/// highlighted.
class AppSelect<T> extends StatefulWidget {
  const AppSelect({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.placeholder = 'Select',
    this.label,
    this.required = false,
    this.validator,
    this.leadingIcon,
    this.enabled = true,
    this.menuMaxHeight = double.infinity,
    this.errorText,
    this.height = 36,
    this.fillColor,
    this.radius = AppTheme.radiusMd,
    this.borderColor,
    this.textColor,
    this.fontSize = 14,
    this.iconSize = 14,
    this.menuLabel,
  });

  final T? value;
  final List<AppSelectItem<T>> items;
  final ValueChanged<T?>? onChanged;

  /// `<SelectValue placeholder>`
  final String placeholder;
  final String? label;
  final bool required;
  final FormFieldValidator<T>? validator;

  /// e.g. `bi-funnel` in the list filters (`<i class="bi … mr-2">`).
  final IconData? leadingIcon;
  final bool enabled;

  /// The web limits the list only by the space left on screen.
  final double menuMaxHeight;
  final String? errorText;

  /// `data-[size=default]:h-9` (36) / `size="sm"` → 32, or a page's `h-…`.
  final double height;

  /// `bg-…` override on the trigger (e.g. `bg-white`).
  final Color? fillColor;

  /// `rounded-…` override on the trigger (default `rounded-md` = 14).
  final double radius;

  /// `border-…` override on the trigger (default `border-input`).
  final Color? borderColor;

  /// `text-…` colour of the selected value (the placeholder stays #9ca3af).
  final Color? textColor;

  /// `text-…` size of the trigger (default `text-sm`).
  final double fontSize;

  /// Size of [leadingIcon] (a `bi` icon inherits the trigger's 14px).
  final double iconSize;

  /// A `<SelectLabel>` heading at the top of the menu (e.g. "Years").
  final String? menuLabel;

  @override
  State<AppSelect<T>> createState() => _AppSelectState<T>();
}

class _AppSelectState<T> extends State<AppSelect<T>> {
  final _menu = MenuController();
  bool _focused = false;
  bool _hovered = false;

  void _toggle() => _menu.isOpen ? _menu.close() : _menu.open();

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final mutedFg = context.mutedFgColor;
    final input = context.inputColor;
    final destructive = context.destructiveColor;
    final interactive = widget.enabled && widget.onChanged != null;
    AppSelectItem<T>? selected;
    for (final it in widget.items) {
      if (!it.isLabel && !it.isMessage && it.value == widget.value) selected = it;
    }

    final field = FormField<T>(
      initialValue: widget.value,
      // Validate the controlled value, not the FormField's internal copy.
      validator: widget.validator == null ? null : (_) => widget.validator!(widget.value),
      builder: (state) => LayoutBuilder(
        builder: (context, c) {
          final width = c.maxWidth.isFinite ? c.maxWidth : 220.0;
          final screenW = MediaQuery.sizeOf(context).width;
          // Content is `min-w-[8rem]`, at least the trigger's width, and grows
          // with long items up to the space available.
          final minW = math.max(128.0, width);
          final maxW = math.max(minW, screenW - 16);
          final error = widget.errorText ?? state.errorText;

          final menu = MenuAnchor(
            controller: _menu,
            crossAxisUnconstrained: false,
            alignmentOffset: const Offset(0, 4),
            style: MenuStyle(
              minimumSize: WidgetStatePropertyAll(Size(minW, 0)),
              maximumSize: WidgetStatePropertyAll(Size(maxW, widget.menuMaxHeight)),
              backgroundColor: WidgetStatePropertyAll(context.popoverColor),
              surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
              elevation: const WidgetStatePropertyAll(2),
              padding: const WidgetStatePropertyAll(EdgeInsets.all(4)),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  side: BorderSide(color: context.borderColor),
                ),
              ),
              // shadow-md
              shadowColor: WidgetStatePropertyAll(Colors.black.withValues(alpha: 0.5)),
            ),
            menuChildren: [
              if (widget.menuLabel != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Text(
                    widget.menuLabel!,
                    style: const TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500),
                  ),
                ),
              for (final it in widget.items)
                if (it.isLabel)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Text(it.label, style: const TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500)),
                  )
                else if (it.isMessage)
                  Padding(
                    padding: it.messagePadding!,
                    child: Align(
                      child: Text(
                        it.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: it.messageFontSize,
                          // text-sm → 20px line, text-xs → 16px line.
                          height: (it.messageFontSize! <= 12 ? 16 : 20) / it.messageFontSize!,
                          color: it.messageColor ?? mutedFg,
                        ),
                      ),
                    ),
                  )
                else
                MenuItemButton(
                  onPressed: it.enabled
                      ? () {
                          widget.onChanged?.call(it.value);
                          // Marks the field as touched (re-validates under
                          // AutovalidateMode.onUserInteraction).
                          state.didChange(it.value);
                        }
                      : null,
                  style: appMenuItemStyle(context),
                  // Gives the label a bounded width, so long items wrap.
                  overflowAxis: Axis.vertical,
                  child: Row(
                    children: [
                      Expanded(child: Text(it.label)),
                      const SizedBox(width: 10),
                      // `absolute right-2 size-3.5` check indicator.
                      SizedBox.square(
                        dimension: 14,
                        child: it.value == widget.value
                            ? OverflowBox(
                                maxWidth: 16,
                                maxHeight: 16,
                                child: LucideIcon(Lucide.check, size: 16, color: mutedFg),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
            ],
            builder: (context, controller, _) {
              final placeholder = selected == null;
              final textColor =
                  placeholder ? AppColors.placeholder : (widget.textColor ?? context.colors.onSurface);
              final showRing = _focused && interactive;
              final ring = error != null
                  ? destructive.withValues(alpha: dark ? 0.4 : 0.2)
                  : context.ringColor.withValues(alpha: 0.5);
              final borderColor =
                  error != null ? destructive : (showRing ? context.ringColor : (widget.borderColor ?? input));
              final fill = widget.fillColor ??
                  (dark ? input.withValues(alpha: _hovered && interactive ? 0.5 : 0.3) : Colors.transparent);
              return FocusableActionDetector(
                enabled: interactive,
                mouseCursor: interactive ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
                onShowFocusHighlight: (v) => setState(() => _focused = v),
                onShowHoverHighlight: (v) => setState(() => _hovered = v),
                actions: {
                  ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
                    _toggle();
                    return null;
                  }),
                },
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: interactive ? _toggle : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: widget.height,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: fill,
                      borderRadius: BorderRadius.circular(widget.radius),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        ...AppShadows.xs,
                        if (showRing) BoxShadow(color: ring, spreadRadius: 3),
                      ],
                    ),
                    child: Row(
                      children: [
                        if (widget.leadingIcon != null) ...[
                          Icon(widget.leadingIcon, size: widget.iconSize, color: textColor),
                          const SizedBox(width: 16),
                        ],
                        Expanded(
                          child: Text(
                            selected?.label ?? widget.placeholder,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: widget.fontSize, color: textColor),
                          ),
                        ),
                        const SizedBox(width: 8),
                        LucideIcon(Lucide.chevronDown, size: 16, color: mutedFg.withValues(alpha: 0.5)),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
          if (error == null) return menu;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              menu,
              const SizedBox(height: 8),
              Text(error, style: TextStyle(fontSize: 14, height: 20 / 14, color: destructive)),
            ],
          );
        },
      ),
    );

    // `disabled:opacity-50`
    final control = widget.enabled ? field : Opacity(opacity: 0.5, child: field);
    if (widget.label == null) return control;
    return LabeledField(label: widget.label!, required: widget.required, child: control);
  }
}

/// shadcn `<SelectItem>` / `<DropdownMenuItem>` style for [MenuItemButton]s:
/// `rounded-sm px-2 py-1.5 text-sm`, `focus:bg-accent
/// focus:text-accent-foreground` (reka highlights the hovered item).
ButtonStyle appMenuItemStyle(BuildContext context, {Color? foreground}) {
  final fg = foreground ?? context.colors.onSurface;
  bool hot(Set<WidgetState> s) =>
      s.contains(WidgetState.hovered) || s.contains(WidgetState.focused) || s.contains(WidgetState.pressed);
  return ButtonStyle(
    minimumSize: const WidgetStatePropertyAll(Size(0, 32)),
    padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
    shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm))),
    backgroundColor: WidgetStateProperty.resolveWith((s) => hot(s) ? AppColors.accent : Colors.transparent),
    foregroundColor: WidgetStateProperty.resolveWith((s) => hot(s) ? AppColors.accentForeground : fg),
    iconColor: WidgetStateProperty.resolveWith((s) => hot(s) ? AppColors.accentForeground : context.mutedFgColor),
    overlayColor: const WidgetStatePropertyAll(Colors.transparent),
    textStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 14, height: 20 / 14)),
    iconSize: const WidgetStatePropertyAll(16),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.standard,
    mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.basic),
  );
}

/// `<Input type="date">`: the value is the `YYYY-MM-DD` string the API
/// expects (empty / null = no date). Opens the platform date picker.
class AppDateField extends StatelessWidget {
  const AppDateField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.required = false,
    this.hint = 'dd-mm-yyyy',
    this.firstDate,
    this.lastDate,
    this.validator,
    this.enabled = true,
  });

  final String? value;
  final ValueChanged<String> onChanged;
  final String? label;
  final bool required;
  final String hint;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final FormFieldValidator<String>? validator;
  final bool enabled;

  static final _api = DateFormat('yyyy-MM-dd');
  static final _display = DateFormat('dd-MM-yyyy');

  @override
  Widget build(BuildContext context) {
    final parsed = value == null || value!.isEmpty ? null : DateTime.tryParse(value!);
    return AppTextField(
      // Rebuild the field when the value changes from outside.
      key: ValueKey(value),
      initialValue: parsed == null ? '' : _display.format(parsed),
      label: label,
      required: required,
      hint: hint,
      readOnly: true,
      enabled: enabled,
      validator: validator == null ? null : (_) => validator!(value),
      suffix: Icon(BootstrapIcons.calendar3, size: 14, color: context.colors.onSurface),
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: parsed ?? now,
          firstDate: firstDate ?? DateTime(1900),
          lastDate: lastDate ?? DateTime(now.year + 50),
        );
        if (picked != null) onChanged(_api.format(picked));
      },
    );
  }
}

/// The search box + square search button on the list pages:
/// `<input placeholder="Search User..." class="flex-1 px-2 py-1 border
/// rounded-md bg-white focus:ring-2 focus:ring-blue-500 dark:bg-card">
/// <Button class="px-3"><i class="bi bi-search"/></Button>` (`gap-2`).
/// Enter also searches.
class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
    this.hint = 'Search...',
  });

  final TextEditingController controller;
  final VoidCallback onSearch;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final side = BorderSide(color: context.borderColor);
    OutlineInputBorder border({bool focused = false}) => RingInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: side,
          ringWidth: 2,
          ringColor: focused ? Tw.blue500 : Colors.transparent,
        );
    // A native input: 16px text with a 24px line, `px-2 py-1` (34px tall).
    final style = TextStyle(
      fontSize: 16,
      height: 1.5,
      leadingDistribution: TextLeadingDistribution.even,
      color: context.colors.onSurface,
    );
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => onSearch(),
            style: style,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: style.copyWith(color: AppColors.placeholder),
              filled: true,
              fillColor: dark ? AppColors.darkCard : Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              border: border(),
              enabledBorder: border(),
              focusedBorder: border(focused: true),
            ),
          ),
        ),
        const SizedBox(width: 8),
        AppButton(
          icon: BootstrapIcons.search,
          iconSize: 14,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          onPressed: onSearch,
        ),
      ],
    );
  }
}
