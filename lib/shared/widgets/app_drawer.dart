import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/route_names.dart';
import '../../core/theme/app_theme.dart';
import '../../features/auth/data/sources/auth_local_source.dart';
import '../../core/di/injection.dart';

// App navigation drawer — used on HomeScreen
class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});
  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String _name = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await sl<AuthLocalSource>().getUser();
    if (user != null && mounted) {
      setState(() {
        _name = user.name;
        _email = user.email;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    _name.isNotEmpty ? _name[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
                    Text(_email, style: Theme.of(context).textTheme.bodySmall),
                  ]),
                ),
              ]),
            ),
            const Divider(),
            _drawerItem(context, Icons.home_outlined, 'Home', route: RouteNames.home),
            _drawerItem(
              context,
              Icons.add_location_alt_outlined,
              'Add destination',
              route: RouteNames.addDestination,
              usePush: true,
            ),
            _drawerItem(context, Icons.map_outlined, 'Map', route: RouteNames.map),
            _drawerItem(context, Icons.favorite_border, 'Favorites', route: RouteNames.favorites),
            _drawerItem(context, Icons.settings_outlined, 'Settings', route: RouteNames.settings),
            const Spacer(),
            const Divider(),
            _drawerItem(
              context,
              Icons.help_outline,
              'Help & Support',
              action: () => context.push(RouteNames.helpSupport),
            ),
            _drawerItem(
              context,
              Icons.info_outline,
              'About',
              action: () => context.push(RouteNames.about),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext ctx,
    IconData icon,
    String label, {
    String? route,
    bool usePush = false,
    VoidCallback? action,
  }) {
    assert(route != null || action != null, 'Provide route or action');
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: Theme.of(ctx).textTheme.bodyMedium),
      onTap: () {
        Navigator.pop(ctx);
        if (action != null) {
          action();
        } else if (route != null) {
          if (usePush) {
            ctx.push(route);
          } else {
            ctx.go(route);
          }
        }
      },
    );
  }
}
