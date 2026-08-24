part of '../../app.dart';

class LegacyHomeScreen extends StatefulWidget {
  const LegacyHomeScreen({super.key});

  @override
  State<LegacyHomeScreen> createState() => _LegacyHomeScreenState();
}

class _LegacyHomeScreenState extends State<LegacyHomeScreen> {
  int _selectedIndex = 0;
  static const _pages = ['Today', 'Learn', 'Logbook', 'Insights', 'Profile'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _buildPage()),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _showAddTask,
              backgroundColor: const Color(0xFF28634A),
              foregroundColor: Colors.white,
              elevation: 2,
              child: const Icon(Icons.add_rounded),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        backgroundColor: const Color(0xFFFBFAF6),
        indicatorColor: const Color(0xFFDCEADD),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Learn',
          ),
          NavigationDestination(
            icon: Icon(Icons.flight_takeoff_outlined),
            selectedIcon: Icon(Icons.flight_takeoff_rounded),
            label: 'Logbook',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildPage() {
    if (_selectedIndex == 0) return const _TodayPage();
    if (_selectedIndex == 1) return const LearningPage();
    if (_selectedIndex == 2) return const FlightLogbookPage();
    return _PlaceholderPage(title: _pages[_selectedIndex]);
  }

  void _showAddTask() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          8,
          24,
          MediaQuery.viewInsetsOf(context).bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add a new task',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 18),
            const TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'What needs doing?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Add to today'),
            ),
          ],
        ),
      ),
    );
  }
}

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

class _FocusCard extends StatelessWidget {
  const _FocusCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF28634A),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3028634A),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DAILY FOCUS',
                  style: TextStyle(
                    color: Color(0xFFBFD8C8),
                    letterSpacing: 1.4,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Make space for\nwhat matters.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0x66FFFFFF)),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: const Text('Start 25 min'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const SizedBox(
            width: 82,
            height: 82,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: .72,
                  strokeWidth: 8,
                  backgroundColor: Color(0xFF477963),
                  color: Color(0xFFE2B878),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '72%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'ready',
                      style: TextStyle(color: Color(0xFFBFD8C8), fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.index,
    required this.title,
    required this.meta,
    required this.icon,
    required this.done,
    required this.onTap,
  });
  final int index;
  final String title;
  final String meta;
  final IconData icon;
  final bool done;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: const Color(0xFFFBFAF6),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => onTap(index),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9E7DE),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: const Color(0xFF28634A)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          decoration: done ? TextDecoration.lineThrough : null,
                          color: done ? const Color(0xFF8B918C) : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        meta,
                        style: const TextStyle(
                          color: Color(0xFF7A827C),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  done ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: done
                      ? const Color(0xFF28634A)
                      : const Color(0xFFADB1AD),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFFECE1CD),
      borderRadius: BorderRadius.circular(22),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.format_quote_rounded, color: Color(0xFF8D6335)),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            'Small steps, taken with intention, create meaningful change.',
            style: TextStyle(
              fontSize: 16,
              height: 1.45,
              color: Color(0xFF55432E),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    ),
  );
}
