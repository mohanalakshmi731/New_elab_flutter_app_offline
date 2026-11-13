import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/widgets.dart';

import '../../data/models/session.dart';

/// Sidebar entry — port of `LeftSidebarItem` in LeftSidebar.vue.
class NavItem {
  const NavItem({
    required this.key,
    required this.label,
    required this.icon,
    this.route,
    this.children = const [],
    this.shortLabel,
  });

  final String key;
  final String label;
  final IconData icon;
  final String? route;
  final List<NavChild> children;

  /// Label under the icon in the mobile bottom bar.
  final String? shortLabel;

  bool isActive(String path) {
    if (route != null) return _matches(path, route!);
    return children.any((c) => _matches(path, c.route));
  }
}

class NavChild {
  const NavChild(this.key, this.label, this.route);
  final String key;
  final String label;
  final String route;

  bool isActive(String path) => _matches(path, route);
}

bool _matches(String path, String route) =>
    path == route || path.startsWith('$route/');

/// Items per role, exactly as LeftSidebar.vue builds them.
List<NavItem> sidebarItemsFor(String role) {
  final r = role.toLowerCase();
  if (r == Role.admin) {
    return const [
      NavItem(
          key: 'dashboard',
          label: 'Dashboard',
          shortLabel: 'Home',
          icon: BootstrapIcons.house_door,
          route: '/dashboard'),
      NavItem(
        key: 'user',
        label: 'User Management',
        shortLabel: 'Users',
        icon: BootstrapIcons.person_fill,
        children: [
          NavChild('user-list', 'Users List', '/userlist'),
          NavChild('user-activity', 'User Activity Log', '/useractivitylog'),
        ],
      ),
      NavItem(
        key: 'institute',
        label: 'Institute Management',
        shortLabel: 'Institutes',
        icon: BootstrapIcons.building,
        children: [
          NavChild('institute-list', 'Institute List', '/instituteslist'),
          NavChild('invitations-list', 'Invitation List', '/Invitationslist'),
          NavChild('institute-plan', 'Subscription plans', '/institutesplanCreate'),
          NavChild('AppSubscription', 'Role wise Subscriptions', '/subscription'),
          NavChild('institute-zsl-plan', 'Class Access Types', '/zslplan'),
        ],
      ),
    ];
  }

  // Standard items for other roles.
  return [
    const NavItem(
        key: 'dashboard',
        label: 'Dashboard',
        shortLabel: 'Home',
        icon: BootstrapIcons.grid_fill,
        route: '/dashboard'),
    const NavItem(key: 'classes', label: 'Classes', icon: BootstrapIcons.book, route: '/classlist'),
    const NavItem(
        key: 'library',
        label: 'Activity Library',
        shortLabel: 'Library',
        icon: BootstrapIcons.journal_bookmark_fill,
        route: '/library'),
    const NavItem(
        key: 'math',
        label: 'Math Zone',
        shortLabel: 'Math',
        icon: BootstrapIcons.plus_slash_minus,
        route: '/elabsmathzone'),
    const NavItem(
        key: 'science',
        label: 'Science Zone',
        shortLabel: 'Science',
        icon: BootstrapIcons.flask,
        route: '/elabssciencezone'),
    const NavItem(key: 'exams', label: 'Exams', icon: BootstrapIcons.pencil_square, route: '/exams'),
    const NavItem(
        key: 'questions',
        label: 'Question Bank',
        icon: BootstrapIcons.question_circle_fill,
        route: '/questions'),
    const NavItem(
        key: 'schedules',
        label: 'Schedules',
        icon: BootstrapIcons.calendar2_plus_fill,
        route: '/schedules'),
    const NavItem(
        key: 'settings',
        label: 'Profile Settings',
        shortLabel: 'Profile',
        icon: BootstrapIcons.gear_fill,
        route: '/MyProfile'),
    if (r == Role.instructor || r == Role.institute)
      const NavItem(
          key: 'activityreports',
          label: 'Activity Reports',
          icon: BootstrapIcons.bar_chart_line,
          route: '/activityreport'),
  ];
}
