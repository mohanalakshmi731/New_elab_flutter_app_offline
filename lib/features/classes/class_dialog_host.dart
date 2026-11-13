import 'package:flutter/material.dart';

import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/form_fields.dart';
import 'class_list_vm.dart';

/// Wraps one `<Dialog v-model:open="flag">`: rebuilds with the page's
/// [ClassListVm], closes itself when the flag is cleared by a method
/// (`this.isXxxOpen = false`) and, when [guardBusy] is set, ignores outside
/// clicks / Escape while `isCreateBtnLoading` (`@pointer-down-outside`).
class VmDialogHost extends StatefulWidget {
  const VmDialogHost({
    super.key,
    required this.vm,
    required this.dialog,
    required this.builder,
    this.guardBusy = false,
  });

  final ClassListVm vm;
  final ClassDialog dialog;
  final WidgetBuilder builder;
  final bool guardBusy;

  @override
  State<VmDialogHost> createState() => _VmDialogHostState();
}

class _VmDialogHostState extends State<VmDialogHost> {
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    widget.vm.addListener(_changed);
  }

  @override
  void dispose() {
    widget.vm.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (!mounted) return;
    if (!widget.vm.isOpen(widget.dialog) && !_closing) {
      _closing = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.builder(context);
    if (!widget.guardBusy) return child;
    return PopScope(canPop: !widget.vm.isCreateBtnLoading, child: child);
  }
}

/// `window.alert(message)`
Future<void> showClassAlert(BuildContext context, String message) => showAppDialog<void>(
      context,
      builder: (ctx) => AppDialogFrame(
        maxWidth: 420,
        description: message,
        actions: [AppButton(label: 'OK', onPressed: () => Navigator.of(ctx).pop())],
      ),
    );

/// `window.prompt(message, initial)` — null when cancelled.
Future<String?> showClassPrompt(BuildContext context, String message, String initial) {
  final controller = TextEditingController(text: initial);
  return showAppDialog<String>(
    context,
    builder: (ctx) => AppDialogFrame(
      maxWidth: 420,
      description: message,
      actions: [
        AppButton(label: 'Cancel', variant: AppButtonVariant.outline, onPressed: () => Navigator.of(ctx).pop()),
        AppButton(label: 'OK', onPressed: () => Navigator.of(ctx).pop(controller.text)),
      ],
      child: AppTextField(controller: controller, onSubmitted: (v) => Navigator.of(ctx).pop(v)),
    ),
  );
  // The controller is left to the GC: disposing it here would race the
  // route's exit animation, which still builds the field.
}
