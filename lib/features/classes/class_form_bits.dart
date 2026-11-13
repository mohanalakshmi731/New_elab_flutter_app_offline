import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/network/upload_file.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/form_fields.dart';
import '../institutes/institute_widgets.dart' show SpinIcon;
import '../users/users_widgets.dart';
import 'class_list_logic.dart';
import 'class_list_vm.dart';

/// Shared pieces of the instructor / student dialogs.

/// `<Label>` (+ red `*`) above a control with `mt-2`.
class LabeledControl extends StatelessWidget {
  const LabeledControl({super.key, required this.label, required this.child, this.required = false, this.gap = 8});
  final String label;
  final Widget child;
  final bool required;
  final double gap;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [FieldLabel(label, required: required), SizedBox(height: gap), child],
      );
}

/// `grid grid-cols-1 sm:grid-cols-2 gap-4`
Widget twoCols(BuildContext context, Widget a, Widget b) => FormGrid(columns: context.isSm ? 2 : 1, children: [a, b]);

/// `@input` → digits only, max 10 (`validatePhone` / the inline handler).
final phoneFormatters = <TextInputFormatter>[
  FilteringTextInputFormatter.digitsOnly,
  LengthLimitingTextInputFormatter(10),
];

/// Country-code select + phone input.
class PhoneRow extends StatelessWidget {
  const PhoneRow({
    super.key,
    required this.vm,
    required this.code,
    required this.onCode,
    required this.phone,
    required this.hint,
    this.enabled = true,
    // `class="w-28"` sits on `<Select>` (renderless), so the trigger keeps
    // shadcn's `w-fit`: about the width of a short dial code.
    this.codeWidth = 80,
  });

  final ClassListVm vm;
  final String code;
  final ValueChanged<String> onCode;
  final TextEditingController phone;
  final String hint;
  final bool enabled;
  final double codeWidth;

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        width: codeWidth,
        child: AppSelect<String>(
          value: code,
          placeholder: '91',
          enabled: enabled,
          items: [for (final c in vm.dailCodes) AppSelectItem('${c['code']}', vueText(c['code']))],
          onChanged: (v) {
            if (v != null) onCode(v);
          },
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: AppTextField(
          controller: phone,
          hint: hint,
          enabled: enabled,
          keyboardType: TextInputType.phone,
          inputFormatters: phoneFormatters,
        ),
      ),
    ]);
  }
}

const genderItems = [
  AppSelectItem('male', 'Male'),
  AppSelectItem('female', 'Female'),
  AppSelectItem('other', 'Other'),
];

/// `<Input type="file" accept="image/*">` + 80px preview.
class PhotoField extends StatelessWidget {
  const PhotoField({super.key, required this.photo, required this.onPick, this.bordered = true});
  final Object? photo;
  final VoidCallback onPick;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final file = photo is UploadFile ? photo as UploadFile : null;
    return LabeledControl(
      label: 'Photo',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        FileInputField(fileName: file?.name, onTap: onPick),
        // `v-if="x.photo"` shows a preview of `URL.createObjectURL` (only for files).
        if (photo != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              width: 80,
              height: 80,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: bordered ? Border.all(color: context.isDark ? AppColors.darkBorder : AppColors.border) : null,
              ),
              child: file != null ? UploadPreview(file: file, width: 80, height: 80) : null,
            ),
          ),
      ]),
    );
  }
}

/// `<Button variant="ghost" class="text-primary">`
Widget ghostPrimary(BuildContext context, String label, VoidCallback onTap,
        {IconData? leading, IconData? trailing, AppButtonSize size = AppButtonSize.normal}) =>
    AppButton(
      variant: AppButtonVariant.ghost,
      size: size,
      onPressed: onTap,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (leading != null) Icon(leading, size: 16),
        Text(label, style: TextStyle(color: context.colors.primary)),
        if (trailing != null) Icon(trailing, size: 16, color: context.colors.primary),
      ]),
    );

/// The `absolute` search-results dropdown of the wizards (`bg-white` even in
/// dark mode, like the web).
class SearchResultsBox extends StatelessWidget {
  const SearchResultsBox({
    super.key,
    required this.searching,
    required this.results,
    required this.onPick,
    required this.emptyActions,
    this.emptyColor = Tw.gray600,
  });

  final bool searching;
  final List<SearchHit> results;
  final ValueChanged<SearchHit> onPick;
  final List<Widget> emptyActions;

  /// "No users found": `text-gray-600`, `text-gray-500` in the student search.
  final Color emptyColor;

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (searching) {
      body = const Padding(
        padding: EdgeInsets.all(12),
        child: Text('Searching…', style: TextStyle(fontSize: 14, color: Tw.gray500)),
      );
    } else if (results.isEmpty) {
      body = Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          Expanded(child: Text('No users found', style: TextStyle(fontSize: 14, color: emptyColor))),
          Wrap(spacing: 8, children: emptyActions),
        ]),
      );
    } else {
      body = ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 256),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 4),
          children: [for (final r in results) _ResultTile(hit: r, onTap: () => onPick(r))],
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.isDark ? AppColors.darkBorder : AppColors.border),
        // The theme's `shadow-lg`.
        boxShadow: const [
          BoxShadow(color: Color(0x1A000000), blurRadius: 3, offset: Offset(0, 1)),
          BoxShadow(color: Color(0x1A000000), blurRadius: 6, spreadRadius: -1, offset: Offset(0, 4)),
        ],
      ),
      child: Material(type: MaterialType.transparency, child: body),
    );
  }
}

class _ResultTile extends StatefulWidget {
  const _ResultTile({required this.hit, required this.onTap});
  final SearchHit hit;
  final VoidCallback onTap;

  @override
  State<_ResultTile> createState() => _ResultTileState();
}

class _ResultTileState extends State<_ResultTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            color: _hover ? Tw.gray100 : null,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.hit.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              Text(widget.hit.email,
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Tw.gray500)),
            ]),
          ),
        ),
      );
}

/// `relative` wrapper whose `absolute left-0 right-0` [dropdown] floats over
/// the content below [anchor] instead of pushing it down.
class AnchoredDropdown extends StatefulWidget {
  const AnchoredDropdown({super.key, required this.anchor, required this.dropdown, required this.show});
  final Widget anchor;
  final Widget dropdown;
  final bool show;

  @override
  State<AnchoredDropdown> createState() => _AnchoredDropdownState();
}

class _AnchoredDropdownState extends State<AnchoredDropdown> {
  final _portal = OverlayPortalController();
  final _link = LayerLink();

  @override
  void initState() {
    super.initState();
    _portal.show();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, c) => OverlayPortal(
          controller: _portal,
          overlayChildBuilder: (_) => !widget.show
              ? const SizedBox.shrink()
              : CompositedTransformFollower(
                  link: _link,
                  showWhenUnlinked: false,
                  targetAnchor: Alignment.bottomLeft,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(width: c.maxWidth, child: widget.dropdown),
                  ),
                ),
          child: CompositedTransformTarget(link: _link, child: widget.anchor),
        ),
      );
}

/// Search input + square search button (spinner while searching).
class WizardSearchRow extends StatelessWidget {
  const WizardSearchRow({
    super.key,
    required this.controller,
    required this.hint,
    required this.searching,
    required this.onSearch,
    this.onChanged,
    this.submitOnEnter = true,
  });

  final TextEditingController controller;
  final String hint;
  final bool searching;
  final VoidCallback onSearch;
  final ValueChanged<String>? onChanged;
  final bool submitOnEnter;

  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
          child: AppTextField(
            controller: controller,
            hint: hint,
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
            onSubmitted: submitOnEnter ? (_) => onSearch() : null,
          ),
        ),
        const SizedBox(width: 8),
        AppButton(
          size: AppButtonSize.icon,
          onPressed: searching ? null : onSearch,
          child: searching
              ? SpinIcon(size: 16, color: context.colors.onPrimary)
              : const Icon(BootstrapIcons.search, size: 16),
        ),
      ]);
}

/// Read-only `foundUser.full_name` input.
Widget readonlyName(String value, {String? hint}) =>
    AppTextField(key: ValueKey(value), initialValue: value, hint: hint, readOnly: true);
