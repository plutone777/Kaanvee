import 'package:flutter/material.dart';
import 'package:fyp_application/viewmodels/auth_viewmodel.dart';
import 'package:fyp_application/views/admin_reports_view.dart';
import 'package:fyp_application/views/admin_vendor_approval_view.dart';
import 'package:fyp_application/views/discussion_view.dart';
import 'package:fyp_application/views/vendor_view.dart';
import 'package:provider/provider.dart';

class AdminHomeView extends StatefulWidget {
  const AdminHomeView({super.key});

  @override
  State<AdminHomeView> createState() => _AdminHomeViewState();
}

class _AdminHomeViewState extends State<AdminHomeView> {
  int _selectedIndex = 0;

final List<Widget> _pages = const [
  VendorApprovalView(),
  VendorHomeView(adminMode: true),
  DiscussionView(adminMode: true),
  AdminReportsView(),
];

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

String get _appBarTitle {
  switch (_selectedIndex) {
    case 0:
      return 'Approval Dashboard';
    case 1:
      return 'Vendors';
    case 2:
      return 'Discussions';
    case 3:
      return 'Reports';
    default:
      return 'Admin';
  }
}

  Future<void> _showLogoutConfirmation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Log Out?'),

          content: const Text(
            'Are you sure you want to log out of your account?',
          ),

          actions: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cancel
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                  child: const Text('Cancel'),
                ),

                const SizedBox(height: 8),

                // Log Out
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, true);
                  },
                  child: const Text('Log Out'),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;

    await context.read<AuthViewModel>().logout();

    if (!mounted) return;

    Navigator.of(context).popUntil(
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        title: Text(_appBarTitle),

        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Log Out',
            onPressed: _showLogoutConfirmation,
          ),
        ],
      ),

      // ==========================================================
      // PAGE
      // ==========================================================

      body: _pages[_selectedIndex],

      // ==========================================================
      // BOTTOM NAVIGATION
      // ==========================================================

      bottomNavigationBar: NavigationBar(
  selectedIndex: _selectedIndex,

  onDestinationSelected: _onNavItemTapped,

  destinations: const [
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),

    NavigationDestination(
      icon: Icon(Icons.store_outlined),
      selectedIcon: Icon(Icons.store),
      label: 'Vendors',
    ),

    NavigationDestination(
      icon: Icon(Icons.forum_outlined),
      selectedIcon: Icon(Icons.forum),
      label: 'Discussions',
    ),

    NavigationDestination(
      icon: Icon(Icons.flag_outlined),
      selectedIcon: Icon(Icons.flag),
      label: 'Reports',
    ),
  ],
),
    );
  }
}