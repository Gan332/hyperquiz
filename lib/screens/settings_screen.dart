import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/animations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _presetColors = [
    Color(0xFF6750A4), // Purple
    Color(0xFF1976D2), // Blue
    Color(0xFF388E3C), // Green
    Color(0xFFD32F2F), // Red
    Color(0xFFF57C00), // Orange
    Color(0xFF00796B), // Teal
    Color(0xFF5C6BC0), // Indigo
    Color(0xFFAFB42B), // Lime
    Color(0xFF6D4C41), // Brown
    Color(0xFF000000), // Black
  ];

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          StaggeredFadeIn(
            index: 0,
            child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.palette_outlined, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        'Theme Color',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _presetColors.map((color) {
                      final isSelected = app.themeColor.value == color.value;
                      return GestureDetector(
                        onTap: () => app.setThemeColor(color),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: theme.colorScheme.primary, width: 3)
                                : null,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    )
                                  ]
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white, size: 20)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  // Custom color picker
                  Row(
                    children: [
                      Text('Custom', style: theme.textTheme.bodySmall),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(9),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: () => _pickColor(context),
                                    child: const Text('Pick a color...', style: TextStyle(fontSize: 12)),
                                  ),
                                ),
                                Container(
                                  width: 36,
                                  color: app.themeColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          ),
          const SizedBox(height: 16),

          StaggeredFadeIn(
            index: 1,
            child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.display_settings_outlined, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        'Display',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Switch between light and dark theme'),
                    value: app.darkMode,
                    onChanged: (v) => app.setDarkMode(v),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Enable Timer'),
                    subtitle: const Text('Show countdown timer during practice'),
                    value: app.enableTimer,
                    onChanged: (v) => app.setEnableTimer(v),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          ),
          const SizedBox(height: 16),

          StaggeredFadeIn(
            index: 2,
            child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.book_outlined, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        'Default Subject',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: app.defaultSubject.isEmpty ? null : app.defaultSubject,
                    decoration: const InputDecoration(
                      hintText: 'All Subjects',
                    ),
                    items: [
                      const DropdownMenuItem(value: '', child: Text('All Subjects')),
                      ...app.subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))),
                    ],
                    onChanged: (v) => app.setDefaultSubject(v ?? ''),
                  ),
                ],
              ),
            ),
          ),
          ),
          const SizedBox(height: 16),

          StaggeredFadeIn(
            index: 3,
            child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        'About',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _aboutRow('App', 'QuizMaster'),
                  _aboutRow('Version', '1.0.0'),
                  _aboutRow('Framework', 'Flutter + Rust'),
                  _aboutRow('Design', 'HyperOS Style'),
                ],
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _aboutRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Future<void> _pickColor(BuildContext context) async {
    final app = context.read<AppProvider>();

    Color? picked = await showDialog<Color>(
      context: context,
      builder: (ctx) {
        double r = app.themeColor.red / 255;
        double g = app.themeColor.green / 255;
        double b = app.themeColor.blue / 255;

        return StatefulBuilder(
          builder: (context, setDState) {
            return AlertDialog(
              title: const Text('Pick a Color'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(
                        (r * 255).round(),
                        (g * 255).round(),
                        (b * 255).round(),
                        1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _colorSlider('Red', r, (v) {
                    setDState(() => r = v);
                  }, Colors.red),
                  _colorSlider('Green', g, (v) {
                    setDState(() => g = v);
                  }, Colors.green),
                  _colorSlider('Blue', b, (v) {
                    setDState(() => b = v);
                  }, Colors.blue),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(
                    ctx,
                    Color.fromRGBO((r * 255).round(), (g * 255).round(), (b * 255).round(), 1),
                  ),
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );

    if (picked != null) {
      app.setThemeColor(picked);
    }
  }

  Widget _colorSlider(String label, double value, ValueChanged<double> onChanged, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 44, child: Text(label, style: TextStyle(fontSize: 12))),
          Expanded(
            child: Slider(value: value, onChanged: onChanged, activeColor: color),
          ),
          SizedBox(
            width: 32,
            child: Text('${(value * 255).round()}', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
