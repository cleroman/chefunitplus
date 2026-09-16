// =============================================================
// ChefUnitPlus - OnboardingScreen
// 3 pages d'introduction, puis redirection vers Login
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../services/storage_service.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _current = 0;

  static const List<_OnboardingPage> _pages = [
    _OnboardingPage(
      icon: Icons.school_outlined,
      title: AppStrings.onboardingTitle1,
      description: AppStrings.onboardingDesc1,
      color: AppColors.mauve,
    ),
    _OnboardingPage(
      icon: Icons.cast_for_education_outlined,
      title: AppStrings.onboardingTitle2,
      description: AppStrings.onboardingDesc2,
      color: AppColors.kaki,
    ),
    _OnboardingPage(
      icon: Icons.payment_outlined,
      title: AppStrings.onboardingTitle3,
      description: AppStrings.onboardingDesc3,
      color: AppColors.success,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await context.read<StorageService>().markOnboardingSeen();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  void _next() {
    if (_current == _pages.length - 1) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _current == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Bouton "Passer"
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text(
                  AppStrings.skip,
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _current = i),
                itemBuilder: (_, i) => _PageContent(page: _pages[i]),
              ),
            ),

            // Indicateurs de page
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) {
                  final active = _current == i;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: active ? 28 : 8,
                    decoration: BoxDecoration(
                      color: active ? AppColors.mauve : AppColors.divider,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),

            // Bouton principal
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(isLast ? AppStrings.start : AppStrings.next),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// x} MODf?LE DE PAGE
// =============================================================
class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

// =============================================================
// x} WIDGET D'UNE PAGE
// =============================================================
class _PageContent extends StatelessWidget {
  final _OnboardingPage page;
  const _PageContent({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          Container(
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  page.color.withValues(alpha: 0.15),
                  page.color.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(page.icon, size: 110, color: page.color),
          ),
          const SizedBox(height: 48),

          // Titre
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}