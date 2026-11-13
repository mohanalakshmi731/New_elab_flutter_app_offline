import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_pagination.dart';
import '../../widgets/app_table.dart';
import '../../widgets/form_fields.dart';
import '../../widgets/skeleton.dart';
import 'users_controller.dart';

/// Port of `src/pages/user/userlist.vue` (`/userlist`).
class UserListPage extends ConsumerStatefulWidget {
  const UserListPage({super.key});

  @override
  ConsumerState<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends ConsumerState<UserListPage> {
  final _search = TextEditingController();
  String _status = 'all';
  bool _loading = false;

  UsersController get _ctrl => ref.read(usersControllerProvider.notifier);
  UsersState get _state => ref.read(usersControllerProvider);

  @override
  void initState() {
    super.initState();
    // `displayUser` switches to the search results as soon as a term is typed.
    _search.addListener(() => setState(() {}));
    Future.microtask(_fetchUsers);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// Runs [fn] with the skeleton rows on. API errors were already toasted by
  /// the API client; the web only logged them.
  Future<void> _busy(Future<void> Function() fn) async {
    setState(() => _loading = true);
    try {
      await fn();
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _fetchUsers([int page = 1]) =>
      _busy(() => _ctrl.loadUsers(page, _state.userPagination.perPage));

  /// `watch: status`
  void _onStatusChanged(String? value) {
    if (value == null || value == _status) return;
    setState(() => _status = value);
    _search.clear();
    _busy(() => value == 'all'
        ? _ctrl.loadUsers(1, _state.userPagination.perPage)
        : _ctrl.filterUsersByStatus(value, 1));
  }

  Future<void> _onSearch() => _busy(() async {
        final term = _search.text.trim();
        if (term.isNotEmpty) {
          await _ctrl.searchUsers(_search.text, '1');
        } else if (_status != 'all') {
          await _ctrl.filterUsersByStatus(_status);
        } else {
          await _ctrl.loadUsers(1, _state.userPagination.perPage);
        }
      });

  Future<void> _changePage(int page) async {
    if (page < 1 || page > _state.userPagination.lastPage) return;
    await _busy(() async {
      if (_search.text.trim().isNotEmpty) {
        await _ctrl.searchUsers(_search.text, page.toString());
      } else if (_status != 'all') {
        await _ctrl.filterUsersByStatus(_status, page);
      } else {
        await _ctrl.loadUsers(page, _state.userPagination.perPage);
      }
    });
  }

  /// Flip the status first, call lock/unlock, revert on failure.
  Future<void> _toggleStatus(Map<String, dynamic> user) async {
    final id = user['id'] as Object;
    final current = asBool(user['status'], fallback: true);
    _ctrl.setStatusLocally(id, !current);
    setState(() => _loading = true);
    try {
      if (current) {
        await _ctrl.lockUser(id);
      } else {
        await _ctrl.unlockUser(id);
      }
    } catch (_) {
      _ctrl.setStatusLocally(id, current);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmDelete(Map<String, dynamic> user) async {
    final ok = await showConfirmDialog(context, message: 'Are you sure you want to delete this user?');
    if (!ok) return;
    try {
      await _ctrl.deleteUser(user['id'] as Object);
    } catch (_) {
      return;
    }
    await _fetchUsers(_state.userPagination.currentPage);
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(usersControllerProvider);
    final users = _search.text.trim().isNotEmpty ? s.searchUser : s.allUsers;
    final wide = context.isSm;

    final title = Text('User List',
        style: TextStyle(fontSize: wide ? 20 : 18, fontWeight: FontWeight.w600));
    // `<SelectTrigger class="w-full bg-white">` (`dark:bg-input/30` still wins in dark mode).
    final filter = AppSelect<String>(
      value: _status,
      fillColor: context.isDark ? null : Colors.white,
      leadingIcon: BootstrapIcons.funnel,
      placeholder: 'All Status',
      items: const [
        AppSelectItem('all', 'All Status'),
        AppSelectItem('true', 'Active'),
        AppSelectItem('false', 'Inactive'),
      ],
      onChanged: _onStatusChanged,
    );
    final search = AppSearchBar(controller: _search, hint: 'Search User...', onSearch: _onSearch);
    final create = AppButton(label: 'Create User', onPressed: () => context.go('/userscreate'));

    // sm+: the left block (`flex justify-between gap-3`, filter `w-[60%]`)
    // and the right block (search `sm:w-[40%] md:w-[80%]`, Create User)
    // size to their content, so the filter ends up ~148px and the search
    // block ~240px wide. Below 640px both blocks are full width.
    final header = wide
        ? Row(
            children: [
              title,
              const SizedBox(width: 12),
              SizedBox(width: 148, child: filter),
              const Spacer(),
              SizedBox(width: 240, child: search),
              const SizedBox(width: 12),
              create,
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LayoutBuilder(
                builder: (context, c) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    const Spacer(),
                    SizedBox(width: c.maxWidth * 0.6, child: filter),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              search,
              const SizedBox(height: 12),
              create,
            ],
          );

    return SingleChildScrollView(
      padding: EdgeInsets.all(wide ? 24 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          const SizedBox(height: 24),
          AppTable(
            columns: const [
              AppTableColumn('User Id', flex: 0.7),
              AppTableColumn('Name', flex: 1.4),
              AppTableColumn('Email', flex: 1.8),
              AppTableColumn('Phone'),
              AppTableColumn('Status', flex: 0.8),
              AppTableColumn('Email Verified'),
              AppTableColumn('Actions', alignEnd: true),
            ],
            rows: _loading
                // The web's skeleton rows have six cells: the sixth
                // (`text-right`, `w-10 ml-auto`) lands under "Email
                // Verified" and the Actions column stays empty.
                ? [
                    for (var i = 0; i < 6; i++)
                      const [
                        Skeleton(width: 80),
                        Skeleton(width: 160),
                        Skeleton(width: 128),
                        Skeleton(width: 64),
                        Skeleton(width: 96),
                        Align(alignment: Alignment.centerRight, child: Skeleton(width: 40)),
                        SizedBox.shrink(),
                      ],
                  ]
                : [
                    for (final u in users)
                      [
                        Text('${u['id'] ?? ''}'),
                        Text('${u['first_name'] ?? ''} ${u['last_name'] ?? ''}'),
                        Text('${u['email'] ?? ''}'),
                        Text('${u['phone'] ?? ''}'),
                        StatusText(asBool(u['status'], fallback: true)),
                        Text(u['email_verified_at'] != null ? 'Verified' : 'Not Verified'),
                        _actions(u),
                      ],
                  ],
          ),
          AppPagination(meta: s.userPagination, onPageChanged: _changePage),
        ],
      ),
    );
  }

  Widget _actions(Map<String, dynamic> u) {
    final active = asBool(u['status'], fallback: true);
    final color = active ? Tw.green600 : Tw.red500;
    // `flex justify-end items-center gap-3`; style.css sizes `table .bi` at 18px.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => _toggleStatus(u),
            behavior: HitTestBehavior.opaque,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(active ? BootstrapIcons.unlock_fill : BootstrapIcons.lock_fill, size: 18, color: color),
              const SizedBox(width: 4),
              Text(active ? 'Unlock' : 'Lock', style: TextStyle(fontSize: 14, height: 20 / 14, color: color)),
            ]),
          ),
        ),
        const SizedBox(width: 12),
        TableActionIcon(
          icon: BootstrapIcons.trash,
          color: Tw.red600,
          onTap: () => _confirmDelete(u),
        ),
      ],
    );
  }
}
