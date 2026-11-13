import 'dart:io';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import '../../core/network/upload_file.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/form_fields.dart';

/// shadcn `<Card>` (`src/components/ui/card/Card.vue`):
/// `bg-card text-card-foreground flex flex-col gap-6 rounded-xl border py-6
/// shadow-sm`. Pass [padding]/[radius] for `class="p-6 rounded-2xl"` etc.
class ShadCard extends StatelessWidget {
  const ShadCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(vertical: 24),
    this.margin = EdgeInsets.zero,
    this.radius = 20,
    this.darkBorderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  /// `rounded-xl` = `--radius` + 4px = 20.
  final double radius;

  /// `dark:border-(--border-color)` → `AppColors.sidebarText` (#95a3ff).
  final Color? darkBorderColor;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: dark ? AppColors.darkCard : AppColors.card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: dark ? (darkBorderColor ?? AppColors.darkBorder) : AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 3, offset: const Offset(0, 1)),
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.1), blurRadius: 2, spreadRadius: -1, offset: const Offset(0, 1)),
        ],
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: dark ? AppColors.darkForeground : AppColors.foreground),
        child: child,
      ),
    );
  }
}

/// Marks a cell of a [FormGrid] that spans every column (`sm:col-span-2`).
class GridSpan extends StatelessWidget {
  const GridSpan({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

/// `grid grid-cols-{n} gap-4`: lays [children] out [columns] per row
/// (a [GridSpan] child takes a whole row).
class FormGrid extends StatelessWidget {
  const FormGrid({super.key, required this.columns, required this.children, this.gap = 16});

  final int columns;
  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    var pending = <Widget>[];

    void flush() {
      if (pending.isEmpty) return;
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < columns; i++) ...[
            if (i > 0) SizedBox(width: gap),
            Expanded(child: i < pending.length ? pending[i] : const SizedBox.shrink()),
          ],
        ],
      ));
      pending = [];
    }

    for (final child in children) {
      if (columns <= 1) {
        rows.add(child);
      } else if (child is GridSpan) {
        flush();
        rows.add(child);
      } else {
        pending.add(child);
        if (pending.length == columns) flush();
      }
    }
    flush();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) SizedBox(height: gap),
          rows[i],
        ],
      ],
    );
  }
}

/// `disabled` / `readonly` inputs: `disabled:opacity-50 pointer-events-none`.
class DisabledLook extends StatelessWidget {
  const DisabledLook({super.key, required this.child, this.disabled = true});
  final Widget child;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    if (!disabled) return child;
    return IgnorePointer(child: Opacity(opacity: 0.5, child: child));
  }
}

/// `<Input :type="show ? 'text' : 'password'">` with the
/// `bi-eye` / `bi-eye-slash` toggle (`text-gray-500`) on the right.
class PasswordInput extends StatefulWidget {
  const PasswordInput({
    super.key,
    required this.controller,
    required this.hint,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool _show = false;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      hint: widget.hint,
      obscureText: !_show,
      onChanged: widget.onChanged,
      suffix: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => setState(() => _show = !_show),
          child: Icon(_show ? BootstrapIcons.eye_slash : BootstrapIcons.eye, size: 16, color: Tw.gray500),
        ),
      ),
    );
  }
}

/// `<Input type="file" accept="image/*">`: the browser's "Choose File" button
/// and the chosen file name ("No file chosen" until one is picked).
class FileInputField extends StatelessWidget {
  const FileInputField({super.key, required this.fileName, required this.onTap});

  final String? fileName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final muted = context.isDark ? AppColors.darkMutedForeground : Tw.slate500;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: const InputDecoration(),
        child: Row(
          children: [
            const Text('Choose File', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                fileName ?? 'No file chosen',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: fileName == null ? muted : null),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Preview of a picked [UploadFile] (`URL.createObjectURL(file)`).
class UploadPreview extends StatelessWidget {
  const UploadPreview({super.key, required this.file, this.width, this.height, this.fit = BoxFit.cover});

  final UploadFile file;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    Widget broken(BuildContext _, Object _, StackTrace? _) =>
        SizedBox(width: width ?? height, height: height, child: const Icon(BootstrapIcons.image, size: 20));
    if (file.bytes != null) {
      return Image.memory(file.bytes!, width: width, height: height, fit: fit, errorBuilder: broken);
    }
    return Image.file(File(file.path!), width: width, height: height, fit: fit, errorBuilder: broken);
  }
}

/// Keeps text controllers in step with a map held by a controller
/// (`v-model="userForm.firstName"` on `mapWritableState`). Typing is pushed
/// with the fields' `onChanged`; call [sync] when the map changes elsewhere.
class MapTextBinding {
  MapTextBinding(Iterable<String> keys, Map<String, dynamic> initial)
      : controllers = {for (final k in keys) k: TextEditingController(text: _str(initial[k]))};

  final Map<String, TextEditingController> controllers;

  TextEditingController operator [](String key) => controllers[key]!;

  static String _str(Object? v) => v == null ? '' : '$v';

  void sync(Map<String, dynamic> values) {
    for (final e in controllers.entries) {
      final v = _str(values[e.key]);
      if (e.value.text != v) e.value.text = v;
    }
  }

  void dispose() {
    for (final c in controllers.values) {
      c.dispose();
    }
  }
}
