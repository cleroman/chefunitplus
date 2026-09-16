// =============================================================
// ChefUnitPlus - GradientHeader
// En-tête avec gradient (mauve â†’ kaki)
// =============================================================

import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/theme/gradients.dart';

class GradientHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final Gradient? gradient;
  final EdgeInsets padding;
  final bool centerTitle;
  final double bottomRadius;

  const GradientHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.leading,
    this.gradient,
    this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 24),
    this.centerTitle = false,
    this.bottomRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? AppGradients.header,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(bottomRadius),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barre supérieure : leading + trailing
              if (leading != null || trailing != null)
                Row(
                  children: [
                    if (leading != null) leading!,
                    const Spacer(),
                    if (trailing != null) trailing!,
                  ],
                ),

              // Titre + sous-titre
              if (leading != null || trailing != null)
                const SizedBox(height: 8),
              if (centerTitle)
                Center(
                  child: _buildTitleBlock(),
                )
              else
                _buildTitleBlock(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleBlock() {
    return Column(
      crossAxisAlignment:
          centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: centerTitle ? TextAlign.center : TextAlign.start,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            textAlign: centerTitle ? TextAlign.center : TextAlign.start,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

// =============================================================
// ðŸŽ VARIANTE : GradientHeader avec statistiques
// =============================================================
class GradientHeaderWithStats extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> stats;
  final Widget? leading;
  final Widget? trailing;
  final Gradient? gradient;

  const GradientHeaderWithStats({
    super.key,
    required this.title,
    this.subtitle,
    required this.stats,
    this.leading,
    this.trailing,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? AppGradients.header,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leading != null || trailing != null)
                Row(
                  children: [
                    if (leading != null) leading!,
                    const Spacer(),
                    if (trailing != null) trailing!,
                  ],
                ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
              if (stats.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(
                  children: stats
                      .asMap()
                      .entries
                      .map(
                        (e) => Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: e.key < stats.length - 1 ? 10 : 0,
                            ),
                            child: e.value,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}