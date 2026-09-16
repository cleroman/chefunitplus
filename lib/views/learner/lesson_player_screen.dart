import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/lesson.dart';

class LessonPlayerScreen extends StatefulWidget {
  final Lesson lesson;

  const LessonPlayerScreen({super.key, required this.lesson});

  @override
  State<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends State<LessonPlayerScreen> {
  int? _selectedQuizIndex;
  bool _quizChecked = false;

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          lesson.title,
          style: const TextStyle(fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ============================================================
          // HEADER
          // ============================================================
          _buildHeader(lesson),
          const SizedBox(height: 20),

          // ============================================================
          // VIDEO
          // ============================================================
          if (lesson.hasVideo) ...[
            const _SectionTitle(title: 'Video'),
            const SizedBox(height: 10),
            _buildVideoPlaceholder(lesson),
            const SizedBox(height: 20),
          ],

          // ============================================================
          // PDF
          // ============================================================
          if (lesson.hasPdf) ...[
            const _SectionTitle(title: 'Document PDF'),
            const SizedBox(height: 10),
            _buildPdfCard(lesson),
            const SizedBox(height: 20),
          ],

          // ============================================================
          // CONTENU
          // ============================================================
          if (lesson.hasContent) ...[
            const _SectionTitle(title: 'Contenu de la lecon'),
            const SizedBox(height: 10),
            _buildContentCard(lesson.content ?? ''),
            const SizedBox(height: 20),
          ],

          // ============================================================
          // QUIZ
          // ============================================================
          if (lesson.hasQuiz) ...[
            const _SectionTitle(title: 'Quiz'),
            const SizedBox(height: 10),
            ...lesson.quiz.asMap().entries.map((entry) {
              return _buildQuizQuestion(entry.key, entry.value);
            }),
          ],

          const SizedBox(height: 40),

          // ============================================================
          // BOUTON TERMINER
          // ============================================================
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => _finishLesson(),
              icon: const Icon(Icons.check),
              label: const Text('Marquer comme terminee'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================
  Widget _buildHeader(Lesson lesson) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.mauve, AppColors.kaki],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_iconForType(lesson.type),
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.type.label,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lesson.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if ((lesson.description ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              lesson.description!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.schedule,
                  size: 14, color: Colors.white.withValues(alpha: 0.9)),
              const SizedBox(width: 4),
              Text(
                lesson.durationLabel,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // VIDEO
  // ============================================================
  Widget _buildVideoPlaceholder(Lesson lesson) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.play_circle_outline,
              size: 60, color: Colors.white),
          const SizedBox(height: 12),
          const Text(
            'Lecteur video',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            lesson.videoUrl ?? '',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PDF
  // ============================================================
  Widget _buildPdfCard(Lesson lesson) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf,
              color: AppColors.danger, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Support PDF',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  lesson.pdfPath ?? '',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download, color: AppColors.mauve),
            onPressed: () => _showSnack('Telechargement bientot disponible'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONTENU
  // ============================================================
  Widget _buildContentCard(String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        content,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
          height: 1.6,
        ),
      ),
    );
  }

  // ============================================================
  // QUIZ
  // ============================================================
  Widget _buildQuizQuestion(int index, QuizQuestion q) {
    final answered = _selectedQuizIndex != null && index == 0;
    final isCorrect = answered && _selectedQuizIndex == q.correctIndex;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _quizChecked && index == 0
              ? (isCorrect ? AppColors.success : AppColors.danger)
              : AppColors.divider,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.mauve.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Q${index + 1}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mauve,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  q.question,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...q.options.asMap().entries.map((entry) {
            final optIndex = entry.key;
            final selected = index == 0 && _selectedQuizIndex == optIndex;
            final showCorrect = _quizChecked && index == 0;
            final isCorrectOpt = optIndex == q.correctIndex;

            Color borderColor = AppColors.divider;
            if (showCorrect && isCorrectOpt) {
              borderColor = AppColors.success;
            } else if (showCorrect && selected && !isCorrectOpt) {
              borderColor = AppColors.danger;
            } else if (selected) {
              borderColor = AppColors.mauve;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () {
                  if (index != 0 || _quizChecked) return;
                  setState(() {
                    _selectedQuizIndex = optIndex;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.mauve.withValues(alpha: 0.08)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        size: 18,
                        color: selected
                            ? AppColors.mauve
                            : AppColors.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      if (showCorrect && isCorrectOpt)
                        const Icon(Icons.check_circle,
                            size: 18, color: AppColors.success),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (index == 0 && !_quizChecked) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedQuizIndex == null
                    ? null
                    : () => setState(() => _quizChecked = true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mauve,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Verifier'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================
  IconData _iconForType(LessonType type) {
    switch (type) {
      case LessonType.video:
        return Icons.play_circle_outline;
      case LessonType.pdf:
        return Icons.picture_as_pdf;
      case LessonType.text:
        return Icons.article_outlined;
      case LessonType.quiz:
        return Icons.quiz_outlined;
      case LessonType.mixed:
        return Icons.dashboard_customize_outlined;
    }
  }

  void _finishLesson() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: 8),
            Text('Lecon terminee'),
          ],
        ),
        content: const Text(
          'Felicitations ! Cette lecon a ete marquee comme terminee.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.mauve),
    );
  }
}

// ============================================================
// WIDGET : Titre de section
// ============================================================
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.mauve,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}