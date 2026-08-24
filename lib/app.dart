import 'package:flutter/material.dart';

import 'flight_logbook_page.dart';
import 'features/home/pilot_hub.dart';

class FocusApp extends StatelessWidget {
  const FocusApp({super.key});

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF17211B);
    const green = Color(0xFF28634A);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sage',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F3EC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: green,
          primary: green,
          surface: const Color(0xFFFBFAF6),
        ),
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: ink,
          displayColor: ink,
          fontFamily: 'Georgia',
        ),
      ),
      home: const CreateAccountScreen(),
    );
  }
}

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCEADD),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.spa_rounded,
                          color: Color(0xFF28634A),
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Create your account',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.08,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'A calmer, more focused day starts here.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF6C756F),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 34),
                    TextFormField(
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: _fieldDecoration(
                        label: 'Full name',
                        hint: 'Your name',
                        icon: Icons.person_outline_rounded,
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Please enter your name'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: _fieldDecoration(
                        label: 'Email address',
                        hint: 'you@example.com',
                        icon: Icons.mail_outline_rounded,
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) return 'Please enter your email';
                        if (!email.contains('@') || !email.contains('.')) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _createAccount(),
                      decoration:
                          _fieldDecoration(
                            label: 'Password',
                            hint: 'At least 8 characters',
                            icon: Icons.lock_outline_rounded,
                          ).copyWith(
                            suffixIcon: IconButton(
                              tooltip: _obscurePassword
                                  ? 'Show password'
                                  : 'Hide password',
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                      validator: (value) => (value?.length ?? 0) < 8
                          ? 'Use at least 8 characters'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 54,
                      child: FilledButton(
                        onPressed: _createAccount,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Create account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          'Already have an account?',
                          style: TextStyle(color: Color(0xFF6C756F)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const SignInScreen(),
                            ),
                          ),
                          child: const Text('Sign in'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'By continuing, you agree to our Terms of Service and Privacy Policy.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF8A908B),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFFBFAF6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFD8D8D0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFD8D8D0)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    );
  }

  void _createAccount() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
    );
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        IconButton.filledTonal(
                          tooltip: 'Back',
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        const Spacer(),
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCEADD),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.spa_rounded,
                            color: Color(0xFF28634A),
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Welcome back',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.08,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Sign in to continue your day with intention.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF6C756F),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 34),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: _fieldDecoration(
                        label: 'Email address',
                        hint: 'you@example.com',
                        icon: Icons.mail_outline_rounded,
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) return 'Please enter your email';
                        if (!email.contains('@') || !email.contains('.')) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _signIn(),
                      decoration:
                          _fieldDecoration(
                            label: 'Password',
                            hint: 'Enter your password',
                            icon: Icons.lock_outline_rounded,
                          ).copyWith(
                            suffixIcon: IconButton(
                              tooltip: _obscurePassword
                                  ? 'Show password'
                                  : 'Hide password',
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter your password'
                          : null,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showResetMessage,
                        child: const Text('Forgot password?'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 54,
                      child: FilledButton(
                        onPressed: _signIn,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Sign in',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          'New to Sage?',
                          style: TextStyle(color: Color(0xFF6C756F)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Create account'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFFBFAF6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFD8D8D0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFD8D8D0)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    );
  }

  void _signIn() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  void _showResetMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset instructions are coming.')),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => const PilotHub();
}

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

class LearningPage extends StatefulWidget {
  const LearningPage({super.key});

  @override
  State<LearningPage> createState() => _LearningPageState();
}

class _LearningPageState extends State<LearningPage> {
  static const _definitions = [
    _Definition(
      term: 'Neuroplasticity',
      category: 'Mind',
      meaning:
          'The brain’s ability to reorganize itself by forming new neural connections.',
      example: 'Practising a new skill regularly encourages neuroplasticity.',
    ),
    _Definition(
      term: 'Compound interest',
      category: 'Money',
      meaning:
          'Interest calculated on both the initial amount and the interest already accumulated.',
      example:
          'Time makes compound interest especially powerful for long-term saving.',
    ),
    _Definition(
      term: 'Ecosystem',
      category: 'Science',
      meaning:
          'A community of organisms interacting with each other and their environment.',
      example:
          'A pond is an ecosystem containing plants, animals, water, and soil.',
    ),
    _Definition(
      term: 'Opportunity cost',
      category: 'Ideas',
      meaning:
          'The value of the best alternative you give up when making a choice.',
      example:
          'The opportunity cost of studying tonight might be missing a film.',
    ),
  ];

  String _query = '';
  String _category = 'All';

  @override
  Widget build(BuildContext context) {
    final results = _definitions.where((item) {
      final matchesCategory = _category == 'All' || item.category == _category;
      final search = _query.toLowerCase();
      final matchesSearch =
          item.term.toLowerCase().contains(search) ||
          item.meaning.toLowerCase().contains(search);
      return matchesCategory && matchesSearch;
    }).toList();

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
          sliver: SliverList.list(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LEARN SOMETHING NEW',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                letterSpacing: 1.4,
                                color: const Color(0xFF6C756F),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your learning library',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Saved definitions',
                    onPressed: () {},
                    icon: const Icon(Icons.bookmark_outline_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'Search a word or idea',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: const Color(0xFFFBFAF6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Mind', 'Science', 'Money', 'Ideas']
                      .map(
                        (category) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: _category == category,
                            onSelected: (_) =>
                                setState(() => _category = category),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF28634A),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WORD OF THE DAY',
                      style: TextStyle(
                        color: Color(0xFFBFD8C8),
                        letterSpacing: 1.3,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Curiosity',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'A strong desire to know or learn something.',
                      style: TextStyle(
                        color: Color(0xFFE4F0E7),
                        height: 1.45,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Text(
                    'Definitions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${results.length} topics',
                    style: const TextStyle(color: Color(0xFF6C756F)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (results.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 42),
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 42,
                        color: Color(0xFF8A908B),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No definitions found',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                )
              else
                ...results.map((item) => _DefinitionCard(definition: item)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Definition {
  const _Definition({
    required this.term,
    required this.category,
    required this.meaning,
    required this.example,
  });
  final String term;
  final String category;
  final String meaning;
  final String example;
}

class _DefinitionCard extends StatelessWidget {
  const _DefinitionCard({required this.definition});
  final _Definition definition;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFFFBFAF6),
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFDCEADD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.lightbulb_outline_rounded,
            color: Color(0xFF28634A),
          ),
        ),
        title: Text(
          definition.term,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          definition.category,
          style: const TextStyle(color: Color(0xFF6C756F)),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              definition.meaning,
              style: const TextStyle(height: 1.5),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Example: ${definition.example}',
              style: const TextStyle(
                color: Color(0xFF6C756F),
                height: 1.45,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
