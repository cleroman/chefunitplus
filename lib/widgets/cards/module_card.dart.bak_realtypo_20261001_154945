// =============================================================
// ChefUnitPlus - ModuleCard
// Carte de prsentation d'un module
// =============================================================

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../models/module.dart';

class ModuleCard extends StatelessWidget {
  final Module module;
  final VoidCallback? onTap;
  final Widget? trailing;
  final int? index;

  const ModuleCard({
    super.key,
    required this.module,
    this.onTap,
    this.trailing,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // ------------------ INDEX / IC"NE ------------------
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.mauveSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: index != null
                        ? Text(
                            '${index! + 1}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.mauve,
                            ),
                          )
                        : const Icon(
                            Icons.menu_book_outlined,
                            color: AppColors.mauve,
                          ),
                  ),
                ),
                const SizedBox(width: 12),

                // ------------------ INFOS ------------------
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        module.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (module.description != null &&
                          module.description!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          module.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _MiniStat(
                            icon: Icons.play_lesson_outlined,
                            label: '${module.lessonCount} leons',
                          ),
                          const SizedBox(width: 10),
                          _MiniStat(
                            icon: Icons.access_time,
                            label: module.durationLabel,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ------------------ TRAILING / STATUT ------------------
                if (trailing != null)
                  trailing!
                else ...[
                  Icon(
                    module.hasTrainer
                        ? Icons.check_circle_outline
                        : Icons.person_off_outlined,
                    color: module.hasTrainer
                        ? AppColors.success
                        : AppColors.warning,
                    size: 20,
                  ),
                  if (onTap != null)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.chevron_right,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniStat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}