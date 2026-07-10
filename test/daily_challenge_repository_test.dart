import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stack_tower/data/daily_challenge_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DailyChallengeRepository repo;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repo = DailyChallengeRepository();
  });

  test('same day: target is stable across calls', () {
    final day = DateTime(2026, 7, 6);
    final key = repo.todayKey(day);
    final target1 = repo.targetHeightFor(key);
    final target2 = repo.targetHeightFor(key);
    expect(target1, target2);
    expect(target1, inInclusiveRange(10, 25));
  });

  test('different days can yield different target keys', () {
    final keyA = repo.todayKey(DateTime(2026, 7, 6));
    final keyB = repo.todayKey(DateTime(2026, 7, 7));
    expect(keyA, isNot(keyB));
  });

  test('completion persists within the same day', () async {
    expect(await repo.isTodayCompleted(), isFalse);
    await repo.markTodayCompleted();
    expect(await repo.isTodayCompleted(), isTrue);
  });

  test(
    'completion resets when the stored date differs from today (new day)',
    () async {
      final prefs = await SharedPreferences.getInstance();
      // Simulate a completed challenge from a stale/previous day.
      await prefs.setString('daily.date', '2000-01-01');
      await prefs.setBool('daily.completed', true);

      // isTodayCompleted should detect the date mismatch and reset to false.
      expect(await repo.isTodayCompleted(), isFalse);
      expect(prefs.getString('daily.date'), repo.todayKey());
    },
  );
}
