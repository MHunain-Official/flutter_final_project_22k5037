import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_names.dart';
import '../../../core/theme/app_theme.dart';
import '../presentation/bloc/settings_bloc.dart';
import '../presentation/bloc/settings_event.dart';
import '../presentation/bloc/settings_state.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../auth/presentation/bloc/auth_event.dart';
import '../../auth/presentation/bloc/auth_state.dart';
import '../../../core/di/injection.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (ctx, state) {
          if (state is AuthLoggedOut) ctx.go(RouteNames.login);
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: BlocBuilder<SettingsBloc, SettingsState>(
            builder: (ctx, settings) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _sectionHeader(ctx, 'Appearance'),
                  _tile(
                    ctx,
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark mode',
                    trailing: Switch(
                      value: settings.isDark,
                      activeThumbColor: AppColors.primary,
                      onChanged: (_) => ctx.read<SettingsBloc>().add(ToggleTheme()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _sectionHeader(ctx, 'Account'),
                  _tile(
                    ctx,
                    icon: Icons.favorite_border,
                    title: 'My Favorites',
                    onTap: () => ctx.push(RouteNames.favorites),
                  ),
                  _tile(
                    ctx,
                    icon: Icons.map_outlined,
                    title: 'Explore Map',
                    onTap: () => ctx.push(RouteNames.map),
                  ),
                  const SizedBox(height: 16),
                  _sectionHeader(ctx, 'Info'),
                  _tile(
                    ctx,
                    icon: Icons.info_outline,
                    title: 'About',
                    onTap: () => ctx.push(RouteNames.about),
                  ),
                  _tile(
                    ctx,
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () => ctx.push(RouteNames.helpSupport),
                  ),
                  const SizedBox(height: 24),
                  // Logout button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                    onPressed: () => ctx.read<AuthBloc>().add(LogoutRequested()),
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext ctx, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      );

  Widget _tile(
    BuildContext ctx, {
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) =>
      Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Theme.of(ctx).cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(title, style: Theme.of(ctx).textTheme.bodyMedium),
          trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
          onTap: onTap,
        ),
      );
}
