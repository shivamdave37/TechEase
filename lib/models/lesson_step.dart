class LessonStep {
  final int order;
  final String text;
  final String image; // asset path

  LessonStep({required this.order, required this.text, required this.image});

  factory LessonStep.fromJson(Map<String, dynamic> json) {
    return LessonStep(
      order: json['order'] as int,
      text: json['text'] as String,
      image: json['image'] as String,
    );
  }
}
