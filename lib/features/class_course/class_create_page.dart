import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/html_editor.dart';
import '../../widgets/web_content_view.dart';
import 'class_course_logic.dart' show previewHtml;

/// Port of `src/pages/class/classcreate.vue` (`/classcreate`): a Tiptap editor
/// (`class="w-140"`) and a live "Preview:" card rendering its HTML.
class ClassCreatePage extends StatefulWidget {
  const ClassCreatePage({super.key});

  @override
  State<ClassCreatePage> createState() => _ClassCreatePageState();
}

class _ClassCreatePageState extends State<ClassCreatePage> {
  String _content = '<p>Start typing class description…</p>';

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return SingleChildScrollView(
      padding: EdgeInsets.all(context.isSm ? 24 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Unstyled `<h1>` (preflight): 16px, normal weight.
          const Text('Create Class', style: TextStyle(fontSize: 16, height: 1.5)),
          Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: HtmlEditor(
                initialHtml: _content,
                onChanged: (html) => setState(() => _content = html),
              ),
            ),
          ),
          // <Card class="px-4">: shadcn card (`py-6 gap-6 rounded-xl border shadow-sm`).
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            decoration: BoxDecoration(
              color: dark ? AppColors.darkCard : AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: dark ? AppColors.darkBorder : AppColors.border),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 3, offset: const Offset(0, 1)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Preview:', style: TextStyle(fontSize: 16, height: 1.5)),
                const SizedBox(height: 24),
                SizedBox(
                  height: 320,
                  child: WebContentView(
                    html: '<style>.preview{list-style:disc inside}</style>${previewHtml(_content)}',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
