import 'package:flutter/material.dart';

class DynamicOntLogo extends StatelessWidget {
  const DynamicOntLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<String>(
      future: DefaultAssetBundle.of(context)
          .loadString('assets/icon/ont_logo_square.svg'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox();
        } else {
          // fallback PNG si besoin
          return Image.asset(theme.brightness == Brightness.light
              ? 'assets/icon/ont_logo_square_light.png'
              : 'assets/icon/ont_logo_square.png');
        }
      },
    );
  }
}
