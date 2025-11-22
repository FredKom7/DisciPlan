import 'package:flutter/material.dart';
import '../../core/themes/app_theme.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.rocket_launch,
      'title': 'Welcome to DisciPlan',
      'desc': 'Master your discipline and boost productivity with a futuristic dashboard.'
    },
    {
      'icon': Icons.calendar_month,
      'title': 'Plan & Organize',
      'desc': 'Use weekly and monthly planners to structure your days and weeks.'
    },
    {
      'icon': Icons.checklist,
      'title': 'Stay on Track',
      'desc': 'Manage your to-dos, build habits, and track your progress easily.'
    },
    {
      'icon': Icons.trending_up,
      'title': 'See Your Growth',
      'desc': 'Visualize your achievements and stay motivated every day.'
    },
  ];

  void _next() {
    if (_page < _pages.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  void _skip() => _finish();

  void _finish() {
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _pages.length,
                itemBuilder: (context, i) {
                  final p = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      decoration: AppTheme.glassBox(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(p['icon'], size: 90, color: AppTheme.primaryColor),
                          const SizedBox(height: 32),
                          Text(
                            p['title'],
                            style: AppTheme.glassTitle.copyWith(color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            p['desc'],
                            style: AppTheme.glassSubtitle.copyWith(color: Colors.black87),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _skip,
                    child: const Text('Skip'),
                  ),
                  Row(
                    children: List.generate(_pages.length, (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _page == i ? 16 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _page == i ? AppTheme.primaryColor : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )),
                  ),
                  ElevatedButton(
                    onPressed: _next,
                    child: Text(_page == _pages.length - 1 ? 'Get Started' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 