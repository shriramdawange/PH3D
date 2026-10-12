import '../../catalogue/domain/practical_definition.dart';

class AssessmentResult {
  final int correct;
  final int total;
  final double score;
  final bool passed;
  const AssessmentResult({
    required this.correct,
    required this.total,
    required this.score,
    required this.passed,
  });
}

class AssessmentEngine {
  /// Pure function: does not mutate source question list.
  static AssessmentResult evaluate(
    AssessmentDefinition def,
    Map<String, String> answers,
  ) {
    var correct = 0;
    for (final q in def.questions) {
      if (answers[q.id] == q.correctOptionId) correct++;
    }
    final total = def.questions.length;
    final score = total == 0 ? 0.0 : correct / total;
    return AssessmentResult(
      correct: correct,
      total: total,
      score: score,
      passed: score >= def.passThreshold,
    );
  }
}
