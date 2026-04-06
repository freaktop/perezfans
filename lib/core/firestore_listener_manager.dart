import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;

/// Singleton: deduplicated Firestore (and similar) stream listeners by [key].
class FirestoreListenerManager {
  FirestoreListenerManager._();
  static final FirestoreListenerManager instance = FirestoreListenerManager._();

  final Map<String, StreamSubscription<dynamic>> _subscriptions = {};
  final Map<String, _BindState<dynamic>> _binds = {};

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[FirestoreListenerManager] $message');
    }
  }

  /// Subscribes to [stream] for [key], replacing any previous subscription for that key.
  void listenQuery<T>({
    required String key,
    required Stream<T> stream,
    required void Function(T data) onData,
    required void Function(Object error, StackTrace stackTrace) onError,
  }) {
    cancel(key);
    _log('listen start: $key');
    _subscriptions[key] = stream.listen(
      onData,
      onError: (Object e, StackTrace? st) {
        final trace = st ?? StackTrace.current;
        _log('error [$key]: $e');
        onError(e, trace);
      },
      cancelOnError: false,
    );
  }

  /// Cancels a [listenQuery] subscription and/or a [bindStream] binding for [key].
  void cancel(String key) {
    final sub = _subscriptions.remove(key);
    if (sub != null) {
      sub.cancel();
      _log('cancel (listen): $key');
    }
    final bind = _binds.remove(key);
    if (bind != null) {
      bind.dispose();
      _log('cancel (bind): $key');
    }
  }

  void cancelAll() {
    for (final e in _subscriptions.entries) {
      e.value.cancel();
      _log('cancel (listen): ${e.key}');
    }
    _subscriptions.clear();
    for (final k in _binds.keys.toList()) {
      _binds.remove(k)?.dispose();
      _log('cancel (bind): $k');
    }
    _binds.clear();
  }

  bool isActive(String key) =>
      _subscriptions.containsKey(key) || _binds.containsKey(key);

  /// Broadcast stream for [StreamBuilder]; one upstream subscription per [key].
  /// Prefer [cancel] in [State.dispose] for the same [key].
  Stream<T> bindStream<T>(String key, Stream<T> Function() create) {
    final existing = _binds[key];
    if (existing != null) {
      return existing.controller.stream as Stream<T>;
    }
    _log('bind start: $key');
    final controller = StreamController<T>.broadcast();
    final sub = create().listen(
      controller.add,
      onError: (Object e, StackTrace? st) {
        _log('bind error [$key]: $e');
        controller.addError(e, st ?? StackTrace.current);
      },
      onDone: () {
        if (!controller.isClosed) controller.close();
      },
    );
    _binds[key] = _BindState<T>(controller, sub);
    return controller.stream;
  }
}

class _BindState<T> {
  _BindState(this.controller, this.subscription);
  final StreamController<T> controller;
  final StreamSubscription<T> subscription;

  void dispose() {
    subscription.cancel();
    if (!controller.isClosed) {
      controller.close();
    }
  }
}
