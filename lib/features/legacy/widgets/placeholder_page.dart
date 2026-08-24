part of '../../../app.dart';

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.spa_outlined, size: 56, color: Color(0xFF28634A)),
        const SizedBox(height: 16),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const Text(
          'This space is ready for your next idea.',
          style: TextStyle(color: Color(0xFF6C756F)),
        ),
      ],
    ),
  );
}
