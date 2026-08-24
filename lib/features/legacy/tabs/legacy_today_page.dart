part of '../../../app.dart';

class _TodayPage extends StatefulWidget {
  const _TodayPage();
  @override
  State<_TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<_TodayPage> {
  final Set<int> _done = {1};

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          sliver: SliverList.list(
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE2B878),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'LF',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4A3519),
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton.filledTonal(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                'MONDAY, 24 AUGUST',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  letterSpacing: 1.5,
                  color: const Color(0xFF6C756F),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Good morning, Luke.',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.08,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Here’s a gentle plan for a focused day.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: const Color(0xFF6C756F)),
              ),
              const SizedBox(height: 28),
              const _FocusCard(),
              const SizedBox(height: 30),
              Row(
                children: [
                  Text(
                    'Today’s tasks',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_done.length} of 3 done',
                    style: const TextStyle(
                      color: Color(0xFF6C756F),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _TaskTile(
                index: 0,
                title: 'Review project direction',
                meta: '9:30 AM  ·  Work',
                icon: Icons.arrow_outward_rounded,
                done: _done.contains(0),
                onTap: _toggle,
              ),
              _TaskTile(
                index: 1,
                title: 'Morning walk',
                meta: '30 min  ·  Personal',
                icon: Icons.directions_walk_rounded,
                done: _done.contains(1),
                onTap: _toggle,
              ),
              _TaskTile(
                index: 2,
                title: 'Sketch onboarding ideas',
                meta: '2:00 PM  ·  Creative',
                icon: Icons.draw_outlined,
                done: _done.contains(2),
                onTap: _toggle,
              ),
              const SizedBox(height: 26),
              const _QuoteCard(),
              const SizedBox(height: 110),
            ],
          ),
        ),
      ],
    );
  }

  void _toggle(int index) => setState(
    () => _done.contains(index) ? _done.remove(index) : _done.add(index),
  );
}
