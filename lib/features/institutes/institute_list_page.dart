import 'dart:io';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/upload_file.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/external_link.dart';
import '../../core/utils/files.dart';
import '../../core/utils/json.dart';
import '../../core/utils/pagination.dart';
import '../../data/services/js_compat.dart';
import '../../data/services/services.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_table.dart';
import '../../widgets/form_fields.dart';
import '../../widgets/skeleton.dart';
import '../common/lookups.dart';
import 'institute_payloads.dart';
import 'institute_widgets.dart';
import 'institutes_controller.dart';

/// Port of `src/pages/Institute/Institutelist.vue` (`/instituteslist`).
class InstituteListPage extends ConsumerStatefulWidget {
  const InstituteListPage({super.key});

  @override
  ConsumerState<InstituteListPage> createState() => _InstituteListPageState();
}

class _InstituteListPageState extends ConsumerState<InstituteListPage> {
  final _search = TextEditingController();
  String _searchText = '';
  bool _isLoading = false;
  Map<String, dynamic>? _selectedInstitute;

  /// Component-local `plans` (`{id, name}` only), filled by the page's own
  /// `loadInstitutePlans()`.
  List<Map<String, dynamic>> _plans = const [];

  InstitutesController get _ctrl => ref.read(institutesControllerProvider.notifier);
  InstitutesState get _state => ref.read(institutesControllerProvider);

  @override
  void initState() {
    super.initState();
    _search.addListener(_onSearchTextChanged);
    Future.microtask(_fetchInstitutes);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// `watch: searchText` — searches as soon as 2+ characters are typed.
  void _onSearchTextChanged() {
    final val = _search.text;
    if (val == _searchText) return;
    setState(() => _searchText = val);
    if (val.length >= 2) _ignore(_ctrl.searchInstitutes(val));
  }

  /// API errors were already toasted by the API client; the web only logged them.
  void _ignore(Future<void> f) => f.catchError((_) {});

  Future<void> _fetchInstitutes() async {
    setState(() => _isLoading = true);
    try {
      await _ctrl.getInstitutes(_state.institutePagination.currentPage);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSearch() async {
    if (_search.text.trim().isEmpty) {
      await _fetchInstitutes();
      return;
    }
    try {
      await _ctrl.searchInstitutes(_search.text);
    } catch (_) {}
  }

  /// The page's `changeInstitutePage(page)` — no skeleton, `per_page` 10.
  void _changeInstitutePage(int page) {
    if (page < 1 || page > _state.institutePagination.lastPage) return;
    _ignore(_ctrl.getInstitutes(page));
  }

  /// The page's own `loadInstitutePlans()` (keeps `{id, name}`).
  Future<void> _loadInstitutePlans() async {
    try {
      final response = await ref.read(instituteServiceProvider).getPlans();
      if (response is List) {
        setState(() {
          _plans = [
            for (final p in response)
              if (asMap(p) case final plan?) {'id': plan['id'], 'name': plan['name']},
          ];
        });
      }
    } catch (_) {}
  }

  Future<void> _loadDialCodes() async {
    try {
      await _ctrl.loadDialCodesForInstitute();
    } catch (_) {}
  }

  String _getStateName(Object? stateId, List<Map<String, dynamic>> states) {
    if (!jsTruthy(stateId)) return 'N/A';
    final id = jsNumber(stateId);
    final state = states.where((s) => s['id'] == id).firstOrNull;
    return state != null ? '${state['name']}' : 'N/A';
  }

  String _getCountryName(Object? countryId, List<Map<String, dynamic>> countries) {
    if (!jsTruthy(countryId)) return 'N/A';
    final id = jsNumber(countryId);
    final country = countries.where((c) => c['id'] == id).firstOrNull;
    return country != null ? '${country['name']}' : 'N/A';
  }

  String _getPlanName(Object? planId) {
    final fromApi = _selectedInstitute?['plan_name'];
    if (jsTruthy(fromApi)) return '$fromApi';
    final id = jsNumber(planId);
    final plan = _plans.where((p) => p['id'] == id).firstOrNull;
    return plan != null ? '${plan['name']}' : 'Standard';
  }

  Future<void> _viewInstituteDetails(Map<String, dynamic> inst) async {
    var open = false;
    var states = const <Map<String, dynamic>>[];
    var countries = const <Map<String, dynamic>>[];
    setState(() => _isLoading = true);
    try {
      states = await _ctrl.loadStates();
      await _ctrl.loadCountries();
      countries = ref.read(countriesProvider).valueOrNull ?? const [];
      if (_plans.isEmpty) await _loadInstitutePlans();
      final fullData = await _ctrl.getInstituteById(inst['id']);
      _selectedInstitute = asMap(fullData);
      open = true;
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
    if (!open || !mounted) return;
    final selected = _selectedInstitute;
    await showAppDialog<void>(
      context,
      builder: (_) => _InstituteDetailsDialog(
        institute: selected,
        planName: _getPlanName(selected?['institute_plan_id']),
        stateName: _getStateName(selected?['state_id'], states),
        countryName: _getCountryName(jsOr(selected?['country_id'], selected?['country']), countries),
      ),
    );
  }

  Future<void> _openDeleteInstituteDialog(Map<String, dynamic> inst) async {
    setState(() => _selectedInstitute = inst);
    await showAppDialog<void>(
      context,
      builder: (_) => _DeleteInstituteDialog(
        institute: inst,
        onCancel: () => _selectedInstitute = null,
        onDeleted: () => _selectedInstitute = null,
      ),
    );
  }

  Future<void> _editInstitute(Map<String, dynamic> inst) async {
    Map<String, dynamic>? form;
    String imagePreview = '';
    setState(() => _isLoading = true);
    try {
      await Future.wait([_loadDialCodes(), _loadInstitutePlans(), _ctrl.loadStates()]);
      final full = asMap(await _ctrl.getInstituteById(inst['id'])) ?? const <String, dynamic>{};
      form = {
        'id': full['id'],
        'user_id': full['user_id'],
        'plan_id': full['institute_plan_id'],
        'state_id': full['state_id'],
        'name': jsOr(full['name'], ''),
        'email': jsOr(full['email'], ''),
        'phone': jsOr(full['phone'], ''),
        'country_code': '+${full['country_code']}',
        'address': jsOr(full['address'], ''),
        'is_math_zoro': jsTruthy(full['is_math_zoro']),
        'image': null,
      };
      imagePreview = asString(jsOr(full['logo'], '')) ?? '';
    } catch (_) {
      form = null;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
    if (form == null || !mounted) return;
    await showAppDialog<void>(
      context,
      builder: (_) => _EditInstituteDialog(
        initialForm: form!,
        initialPreview: imagePreview,
        plans: _plans,
      ),
    );
  }

  static const _columns = [
    AppTableColumn('Institute Name', flex: 1.4),
    AppTableColumn('Email', flex: 1.6),
    AppTableColumn('Phone Number'),
    AppTableColumn('Total Instructors'),
    AppTableColumn('Total Students'),
    AppTableColumn('Plan Name'),
    AppTableColumn('Expires On'),
    AppTableColumn('Actions', flex: 0.7, alignEnd: true),
  ];

  /// A row whose first cell is `<TableCell colspan="4">` (the skeleton and
  /// "No data" rows); the other cells stay empty.
  List<Widget> _spanRow(double height, Widget Function(double width) build) => [
        _ColSpan(
          flexes: [for (final c in _columns) c.flex],
          span: 4,
          height: height,
          builder: build,
        ),
        for (var i = 1; i < _columns.length; i++) const SizedBox.shrink(),
      ];

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(institutesControllerProvider);
    final institutes = _searchText.isNotEmpty ? s.searchedInstitutes : s.allInstitutes;
    final wide = context.isSm;

    // `text-lg sm:text-xl font-semibold` (both with a 28px line).
    final title = Text(
      'Institute List',
      softWrap: false,
      style: TextStyle(fontSize: wide ? 20 : 18, height: 28 / (wide ? 20 : 18), fontWeight: FontWeight.w600),
    );
    final search = AppSearchBar(controller: _search, hint: 'Search Institute...', onSearch: _handleSearch);
    final create = AppButton(
      label: 'Create Institute',
      expand: !wide,
      onPressed: () => context.go('/Institutescreate'),
    );

    // sm+: `flex-row justify-between`; the title's `mb-2` wrapper is
    // stretched to the row, so the heading sits 4px above the buttons'
    // centre line. The search box is `sm:w-[60%] md:w-[70%]` of the
    // content-sized button group (≈ 256 / 286px with Chrome's 20-character
    // input).
    final header = wide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: const EdgeInsets.only(bottom: 8), child: title),
              const SizedBox(width: 16),
              const Spacer(),
              SizedBox(
                height: 36,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: context.isMd ? 286 : 256, child: search),
                    const SizedBox(width: 12),
                    create,
                  ],
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(padding: const EdgeInsets.only(bottom: 8), child: title),
              const SizedBox(height: 16),
              search,
              const SizedBox(height: 12),
              create,
            ],
          );

    final List<List<Widget>> rows;
    if (_isLoading) {
      // 6 × `<TableCell colspan="4" class="py-3"><Skeleton class="h-5 w-full rounded-md">`.
      rows = [
        for (var i = 0; i < 6; i++)
          _spanRow(28, (w) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Skeleton(width: w, height: 20),
              )),
      ];
    } else if (institutes.isEmpty) {
      // `<TableCell colspan="4" class="text-center py-4 text-gray-500">No data`.
      rows = [
        _spanRow(36, (w) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                width: w,
                child: const Text('No data', textAlign: TextAlign.center, style: TextStyle(color: Tw.gray500)),
              ),
            )),
      ];
    } else {
      rows = [
        for (final inst in institutes)
          [
            _LinkText('${inst['name'] ?? ''}', onTap: () => _viewInstituteDetails(inst)),
            GestureDetector(
              onTap: () => _viewInstituteDetails(inst),
              child: Text('${jsOr(inst['email'], 'N/A')}'),
            ),
            Text('${inst['phone'] ?? ''}'),
            Text('${jsOr(inst['instructors_count'], '0')}'),
            Text('${jsOr(inst['students_count'], '0')}'),
            Text('${jsOr(inst['plan_name'], 'N/A')}'),
            Text('${jsOr(inst['expires_on'], 'N/A')}'),
            // `<i class="bi …">` without `cursor-pointer` (style.css: `table .bi` 18px).
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => _editInstitute(inst),
                  child: const Icon(BootstrapIcons.pencil_square, size: 18, color: Tw.green600),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _openDeleteInstituteDialog(inst),
                  child: const Icon(BootstrapIcons.trash, size: 18, color: Tw.red600),
                ),
              ],
            ),
          ],
      ];
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          const SizedBox(height: 24),
          // `<Table>` without a size class: `text-sm` at every width.
          AppTable(fontSize: 14, minWidth: 900, columns: _columns, rows: rows),
          _InstitutePagination(meta: s.institutePagination, onPageChanged: _changeInstitutePage),
        ],
      ),
    );
  }
}

/// A `colspan` cell inside an [AppTable] row: lays [builder]'s content over
/// the first [span] columns (the other cells of the row are empty).
class _ColSpan extends StatelessWidget {
  const _ColSpan({required this.flexes, required this.span, required this.height, required this.builder});

  final List<double> flexes;
  final int span;
  final double height;
  final Widget Function(double width) builder;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, c) {
          // AppTable cells are `Expanded(flex: flex * 100)` with `px-2`.
          final first = (flexes.first * 100).round();
          var spanFlex = 0;
          for (var i = 0; i < span && i < flexes.length; i++) {
            spanFlex += (flexes[i] * 100).round();
          }
          final width = (c.maxWidth + 16) * spanFlex / first - 16;
          return SizedBox(
            width: c.maxWidth,
            height: height,
            child: OverflowBox(
              alignment: Alignment.centerLeft,
              minWidth: width,
              maxWidth: width,
              child: builder(width),
            ),
          );
        },
      );
}

/// The page's own `<Pagination>` markup (`mt-4 flex justify-end` around an
/// `inline-block m-2`): `Prev`/`Next` ghost buttons and `<PaginationItem>`s
/// that keep the kit's `size-9` ghost button with `rounded-md px-3 py-1
/// text-xs sm:text-sm`; the current page is `bg-blue-500 text-white`, the
/// others `border hover:bg-gray-100`. Groups of 5 (<640px) / 10 pages.
class _InstitutePagination extends StatelessWidget {
  const _InstitutePagination({required this.meta, required this.onPageChanged});
  final PageMeta meta;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final current = meta.currentPage;
    final last = meta.lastPage;
    final pages = visiblePageGroup(current, last, context.isSm ? 10 : 5);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16 + 8, 8, 8),
      child: LayoutBuilder(
        builder: (context, c) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: c.maxWidth.isFinite ? c.maxWidth : 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _PageNav(
                  label: 'Prev',
                  enabled: current > 1,
                  onTap: () {
                    if (current - 1 >= 1) onPageChanged(current - 1);
                  },
                ),
                const SizedBox(width: 4),
                for (final p in pages) ...[
                  // `changeInstitutePage(page)` reloads even the current page.
                  _PageItem(page: p, active: p == current, onTap: () => onPageChanged(p)),
                  const SizedBox(width: 4),
                ],
                _PageNav(
                  label: 'Next',
                  enabled: current < last,
                  onTap: () {
                    if (current + 1 <= last) onPageChanged(current + 1);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PageItem extends StatefulWidget {
  const _PageItem({required this.page, required this.active, required this.onTap});
  final int page;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_PageItem> createState() => _PageItemState();
}

class _PageItemState extends State<_PageItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    Color bg;
    Color? fg;
    if (_hover) {
      // ghost `hover:bg-accent dark:hover:bg-accent/50 hover:text-accent-foreground`;
      // `hover:bg-gray-100` replaces the light one on the other pages.
      bg = dark ? AppColors.accent.withValues(alpha: 0.5) : (widget.active ? AppColors.accent : Tw.gray100);
      fg = AppColors.accentForeground;
    } else {
      bg = widget.active ? Tw.blue500 : Colors.transparent;
      fg = widget.active ? Colors.white : null;
    }
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: widget.active ? null : Border.all(color: context.borderColor),
          ),
          child: Text(
            '${widget.page}',
            softWrap: false,
            overflow: TextOverflow.visible,
            style: TextStyle(fontSize: context.isSm ? 14 : 12, fontWeight: FontWeight.w500, color: fg),
          ),
        ),
      ),
    );
  }
}

/// `<PaginationPrevious>Prev</PaginationPrevious>`: ghost `h-9 px-2.5 text-sm
/// font-medium rounded-md`, `hover:bg-accent`, `opacity-50` when disabled.
class _PageNav extends StatefulWidget {
  const _PageNav({required this.label, required this.enabled, required this.onTap});
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  State<_PageNav> createState() => _PageNavState();
}

class _PageNavState extends State<_PageNav> {
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

/// `text-blue-600 hover:underline cursor-pointer`
class _LinkText extends StatefulWidget {
  const _LinkText(this.text, {required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  State<_LinkText> createState() => _LinkTextState();
}

class _LinkTextState extends State<_LinkText> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Text(
            widget.text,
            style: TextStyle(
              color: Tw.blue600,
              decoration: _hover ? TextDecoration.underline : null,
              decorationColor: Tw.blue600,
            ),
          ),
        ),
      );
}

/// `<DialogHeader>` text: centred below 640px, left-aligned (clear of the
/// close button, like [AppDialogFrame]'s title) above.
Widget _dialogHeading(BuildContext context, String text, TextStyle style) => Padding(
      padding: EdgeInsets.only(right: context.isSm ? 28 : 0),
      child: Text(text, textAlign: context.isSm ? TextAlign.left : TextAlign.center, style: style),
    );

/// `max-h-[90vh]`: keeps 5vh above and below the dialog.
EdgeInsets _dialogInset(BuildContext context) =>
    EdgeInsets.symmetric(horizontal: 16, vertical: MediaQuery.sizeOf(context).height * 0.05);

/// The delete confirmation (`w-[90%] sm:max-w-sm dark:bg-primary-foreground`):
/// a `<DialogDescription>` and a `flex justify-end gap-2 mt-4` button row.
/// Stays open when the request fails, like the web.
class _DeleteInstituteDialog extends ConsumerWidget {
  const _DeleteInstituteDialog({required this.institute, required this.onCancel, required this.onDeleted});
  final Map<String, dynamic> institute;
  final VoidCallback onCancel;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppDialogFrame(
      maxWidth: 384,
      widthFactor: 0.9,
      backgroundColor: context.isDark ? AppColors.darkPrimaryForeground : null,
      stackActionsOnMobile: false,
      // `gap-4` + `mt-4`
      actionsGap: 32,
      actions: [
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.outline,
          onPressed: () {
            onCancel();
            Navigator.of(context).pop();
          },
        ),
        AppButton(
          label: 'Delete',
          backgroundColor: Tw.red600,
          foregroundColor: Colors.white,
          onPressed: () async {
            final ctrl = ref.read(institutesControllerProvider.notifier);
            final nav = Navigator.of(context);
            try {
              await ctrl.deleteInstitute(institute['id'] as Object);
            } catch (_) {
              return;
            }
            onDeleted();
            nav.pop();
          },
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.only(right: 28),
        child: Text.rich(
          TextSpan(children: [
            const TextSpan(text: 'Are you sure you want to delete this institute? '),
            TextSpan(
              text: '${institute['name'] ?? ''}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ]),
          style: TextStyle(fontSize: 14, height: 20 / 14, color: context.mutedFgColor),
        ),
      ),
    );
  }
}

/// "Institute Details" (`w-[95%] sm:max-w-md p-4 sm:p-6`).
class _InstituteDetailsDialog extends StatelessWidget {
  const _InstituteDetailsDialog({
    required this.institute,
    required this.planName,
    required this.stateName,
    required this.countryName,
  });

  final Map<String, dynamic>? institute;
  final String planName;
  final String stateName;
  final String countryName;

  @override
  Widget build(BuildContext context) {
    final wide = context.isSm;
    final w = context.screenWidth;
    final dark = context.isDark;
    final border = dark ? AppColors.darkBorder : AppColors.border;
    final inst = institute;
    final logo = asString(inst?['logo']);
    final website = asString(inst?['institute_website']);

    Widget line(String label, Widget value) => Container(
          padding: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: border))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(width: 12),
              Expanded(child: Align(alignment: Alignment.centerRight, child: value)),
            ],
          ),
        );

    // The `<h5>`/`<p>` pair has no size class: the body's 16px (24px line).
    // `flex justify-between`, so the value sits at the right edge and is
    // only left-aligned inside its own box (`sm:text-left`) when it wraps.
    const h5 = TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w700);
    const p = TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w500);
    final nameEmail = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.only(bottom: wide ? 0 : 4),
          decoration: wide ? null : BoxDecoration(border: Border(bottom: BorderSide(color: border))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Name:', softWrap: false, style: h5),
              const SizedBox(width: 12),
              Flexible(
                child: Text('${inst?['name'] ?? ''}', textAlign: wide ? TextAlign.left : TextAlign.right, style: p),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Email:', style: h5),
              const SizedBox(width: 12),
              Flexible(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: wide ? double.infinity : 150),
                  child: Text(
                    '${jsOr(inst?['email'], 'N/A')}',
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    textAlign: wide ? TextAlign.left : TextAlign.right,
                    style: p,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final logoImg = jsTruthy(logo)
        ? Container(
            width: 112,
            height: 80,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(border: Border.all(color: border), borderRadius: BorderRadius.circular(4)),
            child: Image.network(logo!, fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox.shrink()),
          )
        : null;

    // `w-[95%] sm:max-w-md bg-white dark:bg-card p-4 sm:p-6 max-h-[90vh]`.
    return AppDialogFrame(
      maxWidth: w < 640 ? w * 0.95 : 448,
      padding: EdgeInsets.all(wide ? 24 : 16),
      backgroundColor: dark ? AppColors.darkCard : Colors.white,
      insetPadding: _dialogInset(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _dialogHeading(
            context,
            'Institute Details',
            const TextStyle(fontSize: 18, height: 28 / 18, fontWeight: FontWeight.w600),
          ),
          if (inst != null) ...[
            // `gap-4` + `mt-4`
            const SizedBox(height: 32),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (logoImg != null) ...[logoImg, const SizedBox(width: 16)],
                  Expanded(child: nameEmail),
                ],
              )
            else
              Column(
                children: [
                  if (logoImg != null) ...[logoImg, const SizedBox(height: 16)],
                  nameEmail,
                ],
              ),
            const SizedBox(height: 16),
            Divider(height: 1, color: border),
            const SizedBox(height: 16),
            DefaultTextStyle.merge(
              style: const TextStyle(fontSize: 14, height: 20 / 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  line('Plan:', Text(planName, textAlign: TextAlign.right)),
                  const SizedBox(height: 12),
                  line('Phone:', Text('${inst['phone'] ?? ''}', textAlign: TextAlign.right)),
                  const SizedBox(height: 12),
                  line(
                    'Website:',
                    jsTruthy(website)
                        ? ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 200),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () => openExternal(website),
                                child: Text(
                                  website!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Tw.blue600,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Tw.blue600,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const Text('N/A'),
                  ),
                  const SizedBox(height: 12),
                  line('City:', Text('${jsOr(inst['city'], 'N/A')}', textAlign: TextAlign.right)),
                  const SizedBox(height: 12),
                  line('State:', Text(stateName, textAlign: TextAlign.right)),
                  const SizedBox(height: 12),
                  line('Country:', Text(countryName, textAlign: TextAlign.right)),
                  const SizedBox(height: 12),
                  _AddressRow(address: '${jsOr(inst['address'], 'N/A')}'),
                ],
              ),
            ),
          ],
          // `gap-4` + `mt-6`
          const SizedBox(height: 16 + 24),
          Align(
            alignment: Alignment.centerRight,
            child: AppButton(
              label: 'Close',
              variant: AppButtonVariant.secondary,
              expand: !wide,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

/// `flex flex-col sm:flex-row justify-between` address line.
class _AddressRow extends StatelessWidget {
  const _AddressRow({required this.address});
  final String address;

  @override
  Widget build(BuildContext context) {
    final color = context.isDark ? Tw.gray400 : Tw.gray600;
    const label = Text('Address:', style: TextStyle(fontWeight: FontWeight.w500));
    if (!context.isSm) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [label, const SizedBox(height: 4), Text(address, style: TextStyle(color: color))],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: LayoutBuilder(
        builder: (context, c) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            label,
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: c.maxWidth * 0.6),
              child: Text(address, textAlign: TextAlign.right, style: TextStyle(color: color)),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Edit Institute" (`sm:max-w-2xl max-h-[90vh]`). Holds the page's
/// `editInstituteForm` / `imagePreview` / `isCreateBtnLoading` while open;
/// closing it discards them (the web's `isEditDialogOpen` watcher).
class _EditInstituteDialog extends ConsumerStatefulWidget {
  const _EditInstituteDialog({required this.initialForm, required this.initialPreview, required this.plans});
  final Map<String, dynamic> initialForm;
  final String initialPreview;
  final List<Map<String, dynamic>> plans;

  @override
  ConsumerState<_EditInstituteDialog> createState() => _EditInstituteDialogState();
}

class _EditInstituteDialogState extends ConsumerState<_EditInstituteDialog> {
  late final Map<String, dynamic> _form = {...widget.initialForm};
  late final _name = TextEditingController(text: '${_form['name']}');
  late final _email = TextEditingController(text: '${_form['email']}');
  late final _phone = TextEditingController(text: '${_form['phone']}');
  late final _address = TextEditingController(text: '${_form['address']}');
  late String _imagePreview = widget.initialPreview;
  UploadFile? _pickedImage;
  bool _isCreateBtnLoading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _handleEditImageUpload() async {
    final file = await pickImageFile();
    if (file == null || !mounted) return;
    setState(() {
      _pickedImage = file;
      _form['image'] = file;
      _imagePreview = '';
    });
  }

  Future<void> _submitEditInstitute() async {
    final ctrl = ref.read(institutesControllerProvider.notifier);
    final nav = Navigator.of(context);
    setState(() => _isCreateBtnLoading = true);
    try {
      await ctrl.updateInstitute({
        ..._form,
        'name': _name.text,
        'email': _email.text,
        'phone': _phone.text,
        'address': _address.text,
      });
      nav.pop();
      await ctrl.getInstitutes();
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isCreateBtnLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final states = ref.watch(statesProvider).valueOrNull ?? const [];
    final dialCodes = ref.watch(dialCodesProvider).valueOrNull ?? const [];
    final dark = context.isDark;
    final border = dark ? AppColors.darkBorder : AppColors.border;
    final w = context.screenWidth;

    final preview = _pickedImage != null
        ? (_pickedImage!.path != null
            ? Image.file(File(_pickedImage!.path!), fit: BoxFit.contain)
            : Image.memory(_pickedImage!.bytes!, fit: BoxFit.contain))
        : (_imagePreview.isNotEmpty
            ? Image.network(_imagePreview, fit: BoxFit.contain, errorBuilder: (_, _, _) => const SizedBox.shrink())
            : null);

    final codeItems = [for (final c in dialCodes) AppSelectItem('+${c['code']}', '${c['code']}')];
    final codeLabel =
        codeItems.where((i) => i.value == '${_form['country_code']}').firstOrNull?.label ?? 'Code';

    // Inputs are `h-10`; the selects' `h-10` loses to the kit's
    // `data-[size=default]:h-9`, so they stay 36px.
    final fields = <FormGridItem>[
      FormGridItem(AppTextField(label: 'Institute Name', controller: _name, hint: 'Institute Name', height: 40)),
      FormGridItem(AppTextField(
        label: 'Institute Email',
        controller: _email,
        hint: 'Email',
        keyboardType: TextInputType.emailAddress,
        height: 40,
      )),
      FormGridItem(LabeledField(
        label: 'Phone',
        // `flex gap-2`: the content-sized code trigger (36px) sits at the
        // top of the 40px phone input.
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: selectFitWidth(context, codeLabel),
              child: AppSelect<String>(
                value: '${_form['country_code']}',
                placeholder: 'Code',
                items: codeItems,
                onChanged: (v) => setState(() => _form['country_code'] = v),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppTextField(
                controller: _phone,
                hint: 'Phone Number',
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                height: 40,
              ),
            ),
          ],
        ),
      )),
      FormGridItem(AppTextField(label: 'Address', controller: _address, hint: 'Address', height: 40)),
      FormGridItem(AppSelect<Object>(
        label: 'State',
        value: _form['state_id'] as Object?,
        placeholder: 'Select State',
        items: [
          for (final st in states)
            if (st['id'] != null) AppSelectItem(st['id'] as Object, '${st['name']}'),
        ],
        onChanged: (v) => setState(() => _form['state_id'] = v),
      )),
      FormGridItem(AppSelect<Object>(
        label: 'Subscription Plan',
        value: _form['plan_id'] as Object?,
        placeholder: 'Select Plan',
        items: [
          for (final p in widget.plans)
            if (p['id'] != null) AppSelectItem(p['id'] as Object, '${p['name']}'),
        ],
        onChanged: (v) => setState(() => _form['plan_id'] = v),
      )),
      FormGridItem(LabeledField(
        label: 'Institute Logo / Image',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilePickField(onPick: _handleEditImageUpload, fileName: _pickedImage?.name, height: 40),
            const SizedBox(height: 8),
            // `<Card class="p-2">`: `rounded-xl border shadow-sm bg-card`.
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: dark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                border: Border.all(color: border),
                boxShadow: AppShadows.sm,
              ),
              // `h-40 bg-gray-50 rounded-md` (no dark variant).
              child: Container(
                height: 160,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Tw.gray50, borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                child: preview,
              ),
            ),
          ],
        ),
      )),
      // `<input type="checkbox" class="h-4 w-4">` (no accent) + `<label>`.
      FormGridItem(Padding(
        padding: const EdgeInsets.only(top: 8),
        child: LabeledCheckbox(
          value: _form['is_math_zoro'] == true,
          label: 'Is Math Zoro',
          labelStyle: const TextStyle(fontWeight: FontWeight.w500),
          nativeStyle: true,
          exactSize: true,
          onChanged: (v) => setState(() => _form['is_math_zoro'] = v),
        ),
      )),
    ];

    // `sm:max-w-2xl bg-primary-foreground max-h-[90vh] overflow-y-auto`.
    return PopScope(
      canPop: !_isCreateBtnLoading,
      child: AppDialogFrame(
        maxWidth: w < 640 ? w - 32 : 672,
        backgroundColor: dark ? AppColors.darkPrimaryForeground : AppColors.primaryForeground,
        insetPadding: _dialogInset(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // A bare `<h1 class="text-primary font-bold">`: 16px, 24px line.
            _dialogHeading(
              context,
              'Edit Institute',
              TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w700, color: context.colors.primary),
            ),
            // `gap-4` + `mt-4`
            const SizedBox(height: 32),
            FormGrid(twoColumns: context.isMd, items: fields),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerRight,
              child: AppButton(
                onPressed: _isCreateBtnLoading ? null : _submitEditInstitute,
                child: _isCreateBtnLoading
                    ? SpinIcon(size: 14, color: context.colors.onPrimary)
                    : const Text('Update'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
