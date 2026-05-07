import 'package:flutter/material.dart';
import '../utils/app_text.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final String language;
  final VoidCallback? onProfile;
  final VoidCallback? onLogout;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.language,
    this.onProfile,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final background = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final shadow = isDark
        ? Colors.black.withOpacity(0.4)
        : Colors.black.withOpacity(0.08);

    final selectedColor = Colors.blueAccent;
    final unselectedColor = isDark ? Colors.grey[400] : Colors.grey;

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: shadow, blurRadius: 20, offset: const Offset(0, 5)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Row(
          children: [
            Expanded(
              child: BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: onTap,
                type: BottomNavigationBarType.fixed,
                backgroundColor: background,
                elevation: 0,

                selectedItemColor: selectedColor,
                unselectedItemColor: unselectedColor,

                selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),

                items: [
                  _buildItem(Icons.home, AppText.get(language, "home"), 0),
                  _buildItem(Icons.camera_alt, AppText.get(language, "scan"), 1),
                  _buildItem(Icons.history, AppText.get(language, "history"), 2),
                  _buildItem(Icons.settings, AppText.get(language, "settings"), 3),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.menu, color: unselectedColor, size: 26),
              offset: const Offset(0, -120),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              color: background,
              onSelected: (value) {
                if (value == 'profile') onProfile?.call();
                if (value == 'logout') onLogout?.call();
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline, size: 20),
                      const SizedBox(width: 10),
                      Text(AppText.get(language, 'auth_profile')),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20, color: Colors.red.shade400),
                      const SizedBox(width: 10),
                      Text(
                        AppText.get(language, 'auth_logout'),
                        style: TextStyle(color: Colors.red.shade400),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildItem(IconData icon, String label, int index) {
    final isActive = index == currentIndex;

    return BottomNavigationBarItem(
      label: label,
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: isActive ? 28 : 24),
      ),
    );
  }
}
