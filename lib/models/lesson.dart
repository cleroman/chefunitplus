// ChefUnitPlus - Modele Lesson
enum LessonType {
  video,
  pdf,
  text,
  quiz,
  mixed,
}

extension LessonTypeX on LessonType {
  String get label => switch (this) {
        LessonType.video => 'Video',
        LessonType.pdf => 'PDF',
        LessonType.text => 'Texte',
        LessonType.quiz => 'Quiz',
        LessonType.mixed => 'Mixte',
      };

  String get value => name;

  static LessonType fromValue(String? v) {
    if (v == null) return LessonType.text;
    for (final t in LessonType.values) {
      if (t.name == v) return t;
    }
    return LessonType.text;
  }
}

class Lesson {
  final String id;
  final String moduleId;
  final String title;
  final String? description;
  final String? content;
  final String? videoUrl;
  final String? pdfPath;
  final int duration; // en minutes
  final int order;
  final List<QuizQuestion> quiz;
  final bool isPreview;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Lesson({
    required this.id,
    required this.moduleId,
    required this.title,
    this.description,
    this.content,
    this.videoUrl,
    this.pdfPath,
    this.duration = 0,
    this.order = 0,
    this.quiz = const [],
    this.isPreview = false,
    this.createdAt,
    this.updatedAt,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    final quizData = json['quiz'];
    List<QuizQuestion> quizList = [];
    if (quizData is List) {
      quizList = quizData
          .map((q) => QuizQuestion.fromJson(Map<String, dynamic>.from(q as Map)))
          .toList();
    }
    return Lesson(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      moduleId: (json['moduleId'] ?? json['module_id'] ?? '').toString(),
      title: json['title'] ?? '',
      description: json['description'],
      content: json['content'],
      videoUrl: json['videoUrl'] ?? json['video_url'],
      pdfPath: json['pdfPath'] ?? json['pdf_path'],
      duration: json['duration'] ?? 0,
      order: json['order'] ?? 0,
      quiz: quizList,
      isPreview: json['isPreview'] ?? json['is_preview'] ?? false,
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']),
      updatedAt: _parseDate(json['updatedAt'] ?? json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'moduleId': moduleId,
        'title': title,
        if (description != null) 'description': description,
        if (content != null) 'content': content,
        if (videoUrl != null) 'videoUrl': videoUrl,
        if (pdfPath != null) 'pdfPath': pdfPath,
        'duration': duration,
        'order': order,
        'quiz': quiz.map((q) => q.toJson()).toList(),
        'isPreview': isPreview,
      };

  // ============================================================
  // GETTERS
  // ============================================================
  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;
  bool get hasPdf => pdfPath != null && pdfPath!.isNotEmpty;
  bool get hasQuiz => quiz.isNotEmpty;
  bool get hasContent => content != null && content!.isNotEmpty;

  /// Determine le type de la lecon en fonction de son contenu
  LessonType get type {
    final hasVideoContent = hasVideo;
    final hasPdfContent = hasPdf;
    final hasTextContent = hasContent;
    final hasQuizContent = hasQuiz;

    final count = [
      hasVideoContent,
      hasPdfContent,
      hasTextContent,
      hasQuizContent,
    ].where((x) => x).length;

    if (count == 0) return LessonType.text;
    if (count > 1) return LessonType.mixed;

    if (hasVideoContent) return LessonType.video;
    if (hasPdfContent) return LessonType.pdf;
    if (hasQuizContent) return LessonType.quiz;
    return LessonType.text;
  }

  String get durationLabel {
    if (duration <= 0) return 'Non definie';
    if (duration < 60) return '${duration}min';
    final h = duration ~/ 60;
    final m = duration % 60;
    return m > 0 ? '${h}h${m}min' : '${h}h';
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
        question: json['question'] ?? '',
        options:
            (json['options'] as List? ?? []).map((e) => e.toString()).toList(),
        correctIndex: json['correctIndex'] ?? json['correct_index'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'question': question,
        'options': options,
        'correctIndex': correctIndex,
      };
}