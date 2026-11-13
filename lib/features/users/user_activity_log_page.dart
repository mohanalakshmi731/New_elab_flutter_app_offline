import 'package:flutter/material.dart';

import '../../widgets/app_table.dart';

/// Port of `src/pages/user/UserActivityLog.vue` (`/useractivitylog`).
///
/// The web screen is a static mock (hard-coded rows, no API call); kept as is.
class UserActivityLogPage extends StatelessWidget {
  const UserActivityLogPage({super.key});

  // data() → users
  static const _users = [
    (username: 'Prakash', email: 'prakash@example.com', action: 'Profile Update', timestamp: '2025-09-16 12:22:15'),
    (username: 'John Doe', email: 'john@example.com', action: 'Profile Update', timestamp: '2025-09-16 12:22:15'),
    (username: 'Jane Smith', email: 'jane.smith@example.com', action: 'Log out', timestamp: '2025-09-16 12:22:15'),
    (
      username: 'Michael Lee',
      email: 'michael.lee@example.com',
      action: 'Password Changed',
      timestamp: '2025-09-16 12:22:15'
    ),
    (
      username: 'Emily Davis',
      email: 'emily.davis@example.com',
      action: 'Profile Update',
      timestamp: '2025-09-16 12:22:15'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('User Activity Log', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          // A bare shadcn <Table> (no card, `text-sm` at every width); cells
          // are `whitespace-nowrap`.
          AppTable(
            card: false,
            fontSize: 14,
            minWidth: 560,
            columns: const [
              AppTableColumn('Username'),
              AppTableColumn('Email', flex: 1.6),
              AppTableColumn('Actions'),
              AppTableColumn('Time Stamp', flex: 1.2),
            ],
            rows: [
              for (final u in _users)
                [
                  Text(u.username, softWrap: false),
                  Text(u.email, softWrap: false),
                  Text(u.action, softWrap: false),
                  Text(u.timestamp, softWrap: false),
                ],
            ],
          ),
        ],
      ),
    );
  }
}
