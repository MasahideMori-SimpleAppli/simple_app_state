import 'package:file_state_manager/file_state_manager.dart';
import 'package:simple_app_state/src/core/state_slot.dart';

class UtilCopy {
  static final int _maxDepth = 100; // 安全な再帰深度上限

  /// (en) Deep copies a JSON serializable type or a ClonableFile.
  /// Throws ArgumentError on unsupported input types.
  /// Note that the return value requires an explicit type conversion.
  /// Also, if you enter data with a depth of 100 or more levels,
  /// an [ArgumentError] will be thrown.
  ///
  /// (ja) JSONでシリアライズ可能な型、またはClonableFileをディープコピーします。
  /// 戻り値には明示的な型変換が必要であることに注意してください。
  /// 非対応の型を入力するとArgumentErrorをスローします。
  /// また、深さ100階層以上のデータを入力した場合も[ArgumentError]をスローします。
  ///
  /// * [value] : The deep copy target.
  /// * [depth] : This is an internal parameter to limit recursive calls.
  /// Do not set this when using from outside.
  static dynamic deepCopyJsonableOrClonableFile(
    dynamic value, {
    int depth = 0,
  }) {
    if (depth > _maxDepth) {
      throw ArgumentError('Exceeded max allowed nesting depth');
    }
    // 通常の処理
    if (value is Map<String, dynamic>) {
      return value.map(
        (key, val) => MapEntry(
          key,
          deepCopyJsonableOrClonableFile(val, depth: depth + 1),
        ),
      );
    } else if (value is List) {
      return value
          .map((e) => deepCopyJsonableOrClonableFile(e, depth: depth + 1))
          .toList();
    } else if (value is String ||
        value is num ||
        value is bool ||
        value == null) {
      return value;
    } else if (value is CloneableFile) {
      return value.clone();
    } else {
      throw ArgumentError('Unsupported type for deep copy');
    }
  }

  /// (en) Converts a JSON serializable type or a ClonableFile to JSON.
  /// Note that the return value requires an explicit type conversion.
  /// Also, if you enter data with a depth of 100 or more levels,
  /// an [ArgumentError] will be thrown.
  ///
  /// (ja) JSONでシリアライズ可能な型、またはClonableFileをJSON用に変換します。
  /// 非対応の型を入力するとArgumentErrorをスローします。
  /// また、深さ100階層以上のデータを入力した場合も[ArgumentError]をスローします。
  ///
  /// * [value] : The convert target.
  /// * [depth] : This is an internal parameter to limit recursive calls.
  /// Do not set this when using from outside.
  static dynamic toDictJsonableOrClonableFile(dynamic value, {int depth = 0}) {
    if (depth > _maxDepth) {
      throw ArgumentError('Exceeded max allowed nesting depth');
    }
    // 通常の処理
    if (value is Map<String, dynamic>) {
      return value.map(
        (key, val) =>
            MapEntry(key, toDictJsonableOrClonableFile(val, depth: depth + 1)),
      );
    } else if (value is List) {
      return value
          .map((e) => toDictJsonableOrClonableFile(e, depth: depth + 1))
          .toList();
    } else if (value is String ||
        value is num ||
        value is bool ||
        value == null) {
      return value;
    } else if (value is CloneableFile) {
      return value.toDict();
    } else {
      throw ArgumentError('Unsupported type for deep copy');
    }
  }

  /// (en) Converts a JSON serializable type or a ClonableFile to JSON.
  /// Note that the return value requires an explicit type conversion.
  /// Also, if you enter data with a depth of 100 or more levels,
  /// an [ArgumentError] will be thrown.
  ///
  /// (ja) JSONでシリアライズ可能な型、またはClonableFileをJSON用に変換します。
  /// 非対応の型を入力するとArgumentErrorをスローします。
  /// また、深さ100階層以上のデータを入力した場合も[ArgumentError]をスローします。
  ///
  /// * [value] : The convert target.
  /// * [depth] : This is an internal parameter to limit recursive calls.
  /// Do not set this when using from outside.
  /// * [fromDictMap] : A map of restoration methods per object.
  /// The key is the object name, and must correspond to the name defined
  /// in each object's serialization method as {"className": className}.
  /// If a dictionary with the same key name and "className" field is found,
  /// the object will be restored using the function corresponding to the key.
  static dynamic fromDictJsonableOrClonableFile(
    dynamic value,
    Map<String, CloneableFile Function(Map<String, dynamic> src)> fromDictMap, {
    int depth = 0,
  }) {
    if (depth > _maxDepth) {
      throw ArgumentError('Exceeded max allowed nesting depth');
    }
    // CloneableFileだったかどうかで処理を変更。
    if (value is Map<String, dynamic>) {
      if (value.containsKey("className") &&
          fromDictMap.containsKey(value["className"])) {
        return fromDictMap[value["className"]!]!(value);
      } else {
        return value.map(
          (key, val) => MapEntry(
            key,
            fromDictJsonableOrClonableFile(val, fromDictMap, depth: depth + 1),
          ),
        );
      }
    } else if (value is List) {
      return value
          .map(
            (e) => fromDictJsonableOrClonableFile(
              e,
              fromDictMap,
              depth: depth + 1,
            ),
          )
          .toList();
    } else if (value is String ||
        value is num ||
        value is bool ||
        value == null) {
      return value;
    } else {
      throw ArgumentError('Unsupported type for deep copy');
    }
  }

  /// (en) Recursively checks whether the target contains a safe value,
  /// and raises an ArgumentError if there is a problem.
  ///
  /// (ja) 対象が安全な値を含むかどうかを再帰的に確認し、
  /// 問題がある場合はArgumentErrorを出します。
  ///
  /// * [value] : The target value.
  /// * [context] : Error text.
  /// * [depth] : This is an internal parameter to limit recursive calls.
  /// Do not set this when using from outside.
  static void validateJsonableOrClonableFile<T>(
    dynamic value,
    StateSlot<T> key, {
    String? context,
    int depth = 0,
  }) {
    if (depth > _maxDepth) {
      throw ArgumentError(
        '${context ?? "value"} exceeded max allowed nesting depth',
      );
    }
    // Typed List requires caster
    if (value != null && key.caster == null && _isTypedCollection<T>()) {
      throw ArgumentError(
        'StateSlot "${key.name}" requires a caster for type $T',
      );
    }
    if (value == null) return;
    if (value is String || value is num || value is bool) return;
    if (value is CloneableFile) return;
    if (value is Map<String, dynamic>) {
      for (final v in value.values) {
        validateJsonableOrClonableFile(
          v,
          key,
          context: context,
          depth: depth + 1,
        );
      }
      return;
    }
    if (value is List) {
      for (final v in value) {
        validateJsonableOrClonableFile(
          v,
          key,
          context: context,
          depth: depth + 1,
        );
      }
      return;
    }
    throw ArgumentError(
      'Invalid value type for ${context ?? "state"}: '
      '${value.runtimeType}',
    );
  }

  static bool _isTypedCollection<T>() {
    final t = T.toString();
    return t.startsWith('List<') && t != 'List<dynamic>';
  }
}
