import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: 'Smart Noise Intelligence',
      subtitle: 'Real-time environmental noise pollution monitoring powered by digital MEMS acoustics and cloud analytics.',
      icon: Icons.graphic_eq_rounded,
      tag: 'MONITOR',
      gradientColors: [const Color(0xFFA3E635), const Color(0xFF22C55E)],
    ),
    OnboardingItem(
      title: 'ESP32 & AI Sound Classification',
      subtitle: 'TinyML acoustic intelligence identifies traffic, horns, construction, sirens, and machinery instantly.',
      icon: Icons.psychology_rounded,
      tag: 'AI CLASSIFY',
      gradientColors: [const Color(0xFF3B82F6), const Color(0xFF8B5CF6)],
    ),
    OnboardingItem(
      title: 'Live Heatmaps & Instant Alerts',
      subtitle: 'Track noise hotspots on Google Maps, enforce legal decibel limits, and generate official PDF reports.',
      icon: Icons.map_rounded,
      tag: 'ENFORCE',
      gradientColors: [const Color(0xFFF97316), const Color(0xFFEF4444)],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (mounted) {
      context.go('/login');
    }
  }

  void _onNext() {
    if (_currentIndex < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA3E635).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.shield_rounded, color: Color(0xFFA3E635), size: 22),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'NoiseGuard',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      'Skip',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF9CA3AF),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // PageView Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _items.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated Hero Artwork Container
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                item.gradientColors[0].withOpacity(0.25),
                                item.gradientColors[1].withOpacity(0.02),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E2C),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: item.gradientColors[0].withOpacity(0.3),
                                    blurRadius: 30,
                                    spreadRadius: 2,
                                  ),
                                ],
                                border: Border.all(
                                  color: item.gradientColors[0].withOpacity(0.5),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                item.icon,
                                size: 64,
                                color: item.gradientColors[0],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Tag Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: item.gradientColors[0].withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: item.gradientColors[0].withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            item.tag,
                            style: GoogleFonts.jetBrainsMono(
                              color: item.gradientColors[0],
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Subtitle
                        Text(
                          item.subtitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF9CA3AF),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicator Dots
                  Row(
                    children: List.generate(
                      _items.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        width: _currentIndex == index ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? const Color(0xFFA3E635)
                              : const Color(0xFF2A2A3C),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // Next / Get Started Button
                  ElevatedButton(
                    onPressed: _onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA3E635),
                      foregroundColor: const Color(0xFF0F0F1A),
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: const Color(0xFFA3E635).withOpacity(0.4),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _currentIndex == _items.length - 1 ? 'Get Started' : 'Next',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _currentIndex == _items.length - 1
                              ? Icons.arrow_forward_rounded
                              : Icons.chevron_right_rounded,
                          size: 20,
                        ),
                      ],
                    ),
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

class OnboardingItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String tag;
  final List<Color> gradientColors;

  OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tag,
    required this.gradientColors,
  });
}
