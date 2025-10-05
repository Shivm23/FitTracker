import 'package:flutter/material.dart';
import 'package:opennutritracker/core/styles/color_schemes.dart';

void main() {
  runApp(const ColorDemoApp());
}

class ColorDemoApp extends StatelessWidget {
  const ColorDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Instagram Color Palette Demo',
      theme: ThemeData(
        colorScheme: lightColorScheme,
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      darkTheme: ThemeData(
        colorScheme: darkColorScheme,
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      themeMode: ThemeMode.system,
      home: const ColorDemoScreen(),
    );
  }
}

class ColorDemoScreen extends StatefulWidget {
  const ColorDemoScreen({super.key});

  @override
  State<ColorDemoScreen> createState() => _ColorDemoScreenState();
}

class _ColorDemoScreenState extends State<ColorDemoScreen> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Instagram Color Palette'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              setState(() {
                isDarkMode = !isDarkMode;
              });
            },
          ),
        ],
      ),
      body: Theme(
        data: isDarkMode
            ? ThemeData(
                colorScheme: darkColorScheme,
                useMaterial3: true,
                fontFamily: 'Poppins',
              )
            : ThemeData(
                colorScheme: lightColorScheme,
                useMaterial3: true,
                fontFamily: 'Poppins',
              ),
        child: Builder(
          builder: (context) {
            final scheme = Theme.of(context).colorScheme;
            return Container(
              color: scheme.surface,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      'Instagram-Inspired Colors',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vibrant gradient palette: Pink, Purple, Orange, Yellow',
                      style: TextStyle(
                        fontSize: 16,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Color Swatches
                    Text(
                      'Primary Colors',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ColorCard(
                            color: scheme.primary,
                            label: 'Primary\n(Instagram Pink)',
                            textColor: scheme.onPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ColorCard(
                            color: scheme.secondary,
                            label: 'Secondary\n(Instagram Orange)',
                            textColor: scheme.onSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ColorCard(
                            color: scheme.tertiary,
                            label: 'Tertiary\n(Instagram Purple)',
                            textColor: scheme.onTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Buttons Demo
                    Text(
                      'Buttons',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.favorite),
                          label: const Text('Like'),
                        ),
                        FilledButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add),
                          label: const Text('Follow'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.share),
                          label: const Text('Share'),
                        ),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.comment),
                          label: const Text('Comment'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Cards Demo
                    Text(
                      'Cards & Content',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: scheme.primary,
                                  child: Icon(
                                    Icons.fastfood,
                                    color: scheme.onPrimary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Nutrition Tracker',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: scheme.onSurface,
                                        ),
                                      ),
                                      Text(
                                        'Track your meals and activities',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: scheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            LinearProgressIndicator(
                              value: 0.65,
                              backgroundColor: scheme.surfaceContainerHighest,
                              color: scheme.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '1,450 / 2,200 calories',
                              style: TextStyle(
                                fontSize: 12,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      color: scheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              color: scheme.onPrimaryContainer,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Daily Goal',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: scheme.onPrimaryContainer,
                                    ),
                                  ),
                                  Text(
                                    'You\'re on track today!',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: scheme.onPrimaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Chips Demo
                    Text(
                      'Filter Chips',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('Breakfast'),
                          selected: true,
                          onSelected: (_) {},
                        ),
                        FilterChip(
                          label: const Text('Lunch'),
                          selected: false,
                          onSelected: (_) {},
                        ),
                        FilterChip(
                          label: const Text('Dinner'),
                          selected: false,
                          onSelected: (_) {},
                        ),
                        FilterChip(
                          label: const Text('Snacks'),
                          selected: true,
                          onSelected: (_) {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Floating Action Button
                    Text(
                      'Action Button',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        FloatingActionButton(
                          onPressed: () {},
                          child: const Icon(Icons.add),
                        ),
                        const SizedBox(width: 16),
                        FloatingActionButton.extended(
                          onPressed: () {},
                          icon: const Icon(Icons.restaurant),
                          label: const Text('Add Meal'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ColorCard extends StatelessWidget {
  final Color color;
  final String label;
  final Color textColor;

  const ColorCard({
    super.key,
    required this.color,
    required this.label,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
