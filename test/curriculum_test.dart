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

  group('Progression locks', () {
    final allLessons = buildCurriculum();
    final a1 = allLessons.where((lesson) => lesson.level == 'A1').toList();
    final unitOne = a1.where((lesson) => lesson.unit == 1).toList();
    final unitTwoFirst = a1.firstWhere((lesson) => lesson.unit == 2);
    final a2First = allLessons.firstWhere((lesson) => lesson.level == 'A2');

    test('a new subchapter stays locked until its conversation is validated', () {
      final completed = unitOne.map((lesson) => lesson.id).toSet();
      expect(isLessonUnlockedInCurriculum(
        lesson: unitTwoFirst,
        lessons: allLessons,
        completedLessonIds: completed,
        completedConversationKeys: <String>{},
      ), isFalse);
      expect(isLessonUnlockedInCurriculum(
        lesson: unitTwoFirst,
        lessons: allLessons,
        completedLessonIds: completed,
        completedConversationKeys: <String>{'A1-U1'},
      ), isTrue);
    });

    test('A2 stays locked until every A1 lesson and all ten conversations are complete', () {
      final completed = a1.map((lesson) => lesson.id).toSet();
      final allConversations = Set<String>.from(
        List<String>.generate(10, (i) => 'A1-U${i + 1}'),
      );
      final missingLastConversation = Set<String>.from(allConversations)..remove('A1-U10');
      expect(isLessonUnlockedInCurriculum(
        lesson: a2First,
        lessons: allLessons,
        completedLessonIds: completed,
        completedConversationKeys: missingLastConversation,
      ), isFalse);
      expect(isLessonUnlockedInCurriculum(
        lesson: a2First,
        lessons: allLessons,
        completedLessonIds: completed,
        completedConversationKeys: allConversations,
      ), isTrue);
    });
  });
}
