import 'package:flutter/material.dart';

class BriefingOperationalWarning extends StatelessWidget {
  const BriefingOperationalWarning({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: const Color(0xFFFFE9D2),
      borderRadius: BorderRadius.circular(13),
    ),
    child: const Text(
      'Sample data only. Use approved operational sources and current company procedures before flight.',
      style: TextStyle(
        color: Color(0xFF6E451B),
        fontWeight: FontWeight.w600,
        fontSize: 11,
      ),
    ),
  );
}

class BriefingSectionCard extends StatelessWidget {
  const BriefingSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.status,
    required this.children,
  });

  final String title, status;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: const Color(0xFFFBFAF6),
    margin: const EdgeInsets.only(bottom: 10),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF28634A)),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                status,
                style: const TextStyle(
                  color: Color(0xFF28634A),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Divider(height: 22),
          ...children,
        ],
      ),
    ),
  );
}

class BriefingDataRow extends StatelessWidget {
  const BriefingDataRow({super.key, required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: Color(0xFF6C756F))),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    ),
  );
}

class BriefingCheckRow extends StatelessWidget {
  const BriefingCheckRow({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(
      children: [
        const Icon(Icons.circle_outlined, size: 18, color: Color(0xFF6C756F)),
        const SizedBox(width: 9),
        Text(text),
      ],
    ),
  );
}
