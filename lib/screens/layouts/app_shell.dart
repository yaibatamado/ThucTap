import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_provider.dart';
import '../../theme/app_theme.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.child,
    required this.title,
    required this.menuItems,
    this.backgroundColor,
  });

  final Widget child;
  final String title;
  final List<Map<String, dynamic>> menuItems;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userRole = authProvider.role ?? 'USER';

    return Scaffold(
      drawer: _AppDrawer(
        title: title,
        userRole: userRole,
        menuItems: menuItems,
        onLogout: () async {
          await authProvider.logout();
          if (context.mounted) context.go('/login');
        },
      ),
      body: Stack(
        children: [
          child,
          Positioned(right: 18, bottom: 92, child: _ChatButton()),
        ],
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({
    required this.title,
    required this.userRole,
    required this.menuItems,
    required this.onLogout,
  });

  final String title;
  final String userRole;
  final List<Map<String, dynamic>> menuItems;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 310,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.local_hospital_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userRole,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: context.appBorder, height: 1),
            _DrawerItem(
              icon: FontAwesomeIcons.house,
              label: 'Trang chủ',
              route: _homeRouteForRole(userRole),
            ),
            _DrawerItem(
              icon: FontAwesomeIcons.robot,
              label: 'Trợ lý AI',
              route: '/chatbot',
            ),
            _DrawerItem(
              icon: FontAwesomeIcons.comments,
              label: 'Chat nội bộ',
              route: '/chat/list',
            ),
            Divider(color: context.appBorder, height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: menuItems
                    .map((block) => _MenuBlock(block: block))
                    .toList(),
              ),
            ),
            Divider(color: context.appBorder, height: 1),
            ListTile(
              leading: const FaIcon(
                FontAwesomeIcons.rightFromBracket,
                size: 18,
              ),
              title: const Text('Đăng xuất'),
              onTap: () async {
                Navigator.of(context).pop();
                await onLogout();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _homeRouteForRole(String role) {
    switch (role) {
      case 'ADMIN':
        return '/admin';
      case 'BACSI':
        return '/doctor';
      case 'BENHNHAN':
        return '/patient';
      case 'NHANSU':
        return '/tiepnhan';
      default:
        return '/login';
    }
  }
}

class _MenuBlock extends StatelessWidget {
  const _MenuBlock({required this.block});

  final Map<String, dynamic> block;

  @override
  Widget build(BuildContext context) {
    final title = block['title'] as String;
    final items = block['items'] as List<Map<String, dynamic>>;

    return ExpansionTile(
      initiallyExpanded: true,
      tilePadding: const EdgeInsets.symmetric(horizontal: 18),
      childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
      title: Text(
        title.toUpperCase(),
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: context.appMuted, fontSize: 13),
      ),
      children: items
          .map(
            (item) => _DrawerItem(
              icon: item['icon'] as FaIconData? ?? FontAwesomeIcons.circle,
              label: item['label'] as String,
              route: item['route'] as String,
            ),
          )
          .toList(),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  final FaIconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    final isSelected = GoRouterState.of(context).matchedLocation == route;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: ListTile(
        minLeadingWidth: 26,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        leading: FaIcon(
          icon,
          size: 18,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : context.appMuted,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : context.appText,
          ),
        ),
        selected: isSelected,
        selectedTileColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          context.go(route);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

class _ChatButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Mở chat',
      offset: const Offset(0, -112),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'ai',
          child: ListTile(
            leading: FaIcon(FontAwesomeIcons.robot),
            title: Text('Trợ lý AI'),
          ),
        ),
        PopupMenuItem(
          value: 'socket',
          child: ListTile(
            leading: FaIcon(FontAwesomeIcons.comments),
            title: Text('Chat nội bộ'),
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'ai') {
          context.go('/chatbot');
        } else {
          context.go('/chat/list');
        }
      },
      child: FloatingActionButton(
        onPressed: null,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const FaIcon(FontAwesomeIcons.solidCommentDots),
      ),
    );
  }
}
