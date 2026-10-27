import 'package:flutter_test/flutter_test.dart';
import 'package:english_pro/lesson_bank.dart';

void main() {
  group('A1 curriculum integrity', () {
    final a1 = buildCurriculum().where((lesson) => lesson.level == 'A1').toList();

    test('contains exactly 500 lessons with unique identifiers', () {
      expect(a1, hasLength(500));
      expect(a1.map((lesson) => lesson.id).toSet(), hasLength(500));
    });

    test('contains ten subchapters with fifty lessons each', () {
      final counts = <int, int>{};
      for (final lesson in a1) {
        counts.update(lesson.unit, (value) => value + 1, ifAbsent: () => 1);
      }
      expect(counts.keys.toSet(), Set<int>.from(List<int>.generate(10, (i) => i + 1)));
      for (var unit = 1; unit <= 10; unit++) {
        expect(counts[unit], 50, reason: 'A1 subchapter $unit must contain 50 lessons');
      }
    });

    test('every lesson has usable learning text and a valid three-option answer', () {
      for (final lesson in a1) {
        expect(lesson.title.trim(), isNotEmpty, reason: lesson.id);
        expect(lesson.explanation.trim(), isNotEmpty, reason: lesson.id);
        expect(lesson.example.trim(), isNotEmpty, reason: lesson.id);
        expect(lesson.french.trim(), isNotEmpty, reason: lesson.id);
        expect(lesson.question.trim(), isNotEmpty, reason: lesson.id);
        expect(lesson.correction.trim(), isNotEmpty, reason: lesson.id);
        expect(lesson.options, hasLength(3), reason: lesson.id);
        expect(lesson.answer, inInclusiveRange(0, 2), reason: lesson.id);
        expect(lesson.options.toSet(), hasLength(3), reason: 'Duplicate options in ${lesson.id}');
      }
    });
  });
}
