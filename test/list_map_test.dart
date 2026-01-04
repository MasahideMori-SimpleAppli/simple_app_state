import 'package:flutter_test/flutter_test.dart';
import 'package:simple_app_state/simple_app_state.dart';

void main() {
  group('Collection types (List / Map) deep copy & type safety', () {
    test('List<String> preserves element type after clone', () {
      final state = SimpleAppState();
      state.slot<List<String>>(
        'names',
        initial: ['alice', 'bob'],
        caster: (v) => (v as List).cast<String>(),
      );
      final cloned = state.clone();
      final list = cloned
          .slot<List<String>>(
            'names',
            caster: (v) => (v as List).cast<String>(),
          )
          .get();
      // 値は同じ
      expect(list, ['alice', 'bob']);
      // List<dynamic> になっていないこと
      expect(list, isA<List<String>>());
      // 値がStringかどうか
      expect(list![0], isA<String>());
      // 要素型が String として扱えること
      final upper = list[0].toUpperCase();
      expect(upper, 'ALICE');
    });

    test('Map<String, dynamic> preserves value type after clone', () {
      final state = SimpleAppState();
      state.slot<Map<String, dynamic>>('scores', initial: {'a': 1, 'b': 2});
      final cloned = state.clone();
      final map = cloned.slot<Map<String, dynamic>>('scores').get();
      expect(map, {'a': 1, 'b': 2});
      expect(map, isA<Map<String, dynamic>>());
      // int として計算できること
      final sum = map!['a']! + map['b']!;
      expect(sum, 3);
    });

    test('Nested collections keep their generic types', () {
      final state = SimpleAppState();
      state.slot<List<Map<String, int>>>(
        'nested',
        initial: [
          {'x': 1},
          {'y': 2},
        ],
        caster: (v) => (v as List)
            .map(
              (m) => (m as Map).map((k, v) => MapEntry(k as String, v as int)),
            )
            .toList(),
      );
      final cloned = state.clone();
      final value = cloned
          .slot<List<Map<String, int>>>(
            'nested',
            caster: (v) => (v as List)
                .map(
                  (m) =>
                      (m as Map).map((k, v) => MapEntry(k as String, v as int)),
                )
                .toList(),
          )
          .get();
      expect(value, isA<List<Map<String, int>>>());
      expect(value![0], isA<Map<String, int>>());
      final v = value[0]['x']! + value[1]['y']!;
      expect(v, 3);
    });

    test('toDict / fromDict round-trip keeps List<String> type', () {
      final state = SimpleAppState();
      state
          .slot<List<String>>('tags', caster: (v) => (v as List).cast<String>())
          .set(['a', 'b', 'c']);
      final dict = state.toDict();
      final restored = SimpleAppState.fromDict(dict, {});
      final tags = restored
          .slot<List<String>>('tags', caster: (v) => (v as List).cast<String>())
          .get();
      expect(tags, ['a', 'b', 'c']);
      expect(tags, isA<List<String>>());
      // String メソッドが直接呼べること
      expect(tags![1].toUpperCase(), 'B');
    });

    test('toDict / fromDict round-trip keeps Map<String, List<String>>', () {
      final state = SimpleAppState();
      state.slot<Map<String, List<String>>>(
        'complex',
        initial: {
          'a': ['x', 'y'],
          'b': ['z'],
        },
        caster: (raw) => (raw as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, (v as List).cast<String>()),
        ),
      );
      final dict = state.toDict();
      final restored = SimpleAppState.fromDict(dict, {});
      final value = restored
          .slot<Map<String, List<String>>>(
            'complex',
            caster: (raw) => (raw as Map<String, dynamic>).map(
              (k, v) => MapEntry(k, (v as List).cast<String>()),
            ),
          )
          .get();
      expect(value, isA<Map<String, List<String>>>());
      expect(value!['a'], isA<List<String>>());
      expect(value['a']![0].toUpperCase(), 'X');
    });
  });
}
