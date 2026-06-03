import 'dart:developer' as developer;

import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/core/firestore_listener_manager.dart';
import '/core_pages/live/live_join_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/index.dart';

class LiveWidget extends StatefulWidget {
  const LiveWidget({super.key});

  static String routeName = 'Live';
  static String routePath = 'live';

  @override
  State<LiveWidget> createState() => _LiveWidgetState();
}

class _LiveWidgetState extends State<LiveWidget> {
  final _functions =
      FirebaseFunctions.instanceFor(region: 'us-central1');

  final _titleController = TextEditingController();
  final _replayController = TextEditingController();
  String? _streamId;
  String? _channelName;
  bool _adult = false;
  bool _loading = false;
  bool _startBusy = false;
  DateTime? _lastLiveRoomNav;

  void _logHost(String message, [Object? err, StackTrace? st]) {
    developer.log(message, name: 'LiveHost', error: err, stackTrace: st);
  }

  String _mapStartLiveError(Object e) {
    if (e is FirebaseFunctionsException) {
      final msg = e.message?.trim();
      if (msg != null && msg.isNotEmpty) return msg;
      return 'Could not start live (${e.code}).';
    }
    return e.toString();
  }

  /// Newest-first active live doc for the signed-in host, or null.
  Future<QueryDocumentSnapshot<Map<String, dynamic>>?>
      _findMyActiveLiveDocument() async {
    final me = currentUserReference;
    if (me == null) return null;
    try {
      final snap = await FirebaseFirestore.instance
          .collection('live_streams')
          .where('host_user', isEqualTo: me)
          .where('status', isEqualTo: 'live')
          .limit(10)
          .get();
      if (snap.docs.isEmpty) return null;
      final docs =
          List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(snap.docs);
      docs.sort((a, b) {
        final ta = a.data()['started_at'];
        final tb = b.data()['started_at'];
        final ma = ta is Timestamp ? ta.millisecondsSinceEpoch : 0;
        final mb = tb is Timestamp ? tb.millisecondsSinceEpoch : 0;
        return mb.compareTo(ma);
      });
      return docs.first;
    } catch (e, st) {
      _logHost('checking for existing active room: query failed', e, st);
      return null;
    }
  }

  void _navigateToHostRoom(String streamId) {
    if (!context.mounted) return;
    _logHost('navigating to live room as host streamId=$streamId');
    context.pushNamed(
      LiveRoomWidget.routeName,
      queryParameters: {
        'streamRef': serializeParam(
          FirebaseFirestore.instance.collection('live_streams').doc(streamId),
          ParamType.DocumentReference,
        ),
        'streamId': serializeParam(streamId, ParamType.String),
        'asHost': serializeParam(true, ParamType.bool),
      }.withoutNulls,
    );
  }

  Future<void> _start() async {
    if (_startBusy) return;
    if (currentUserReference == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in to go live.')),
        );
      }
      return;
    }
    _logHost('start live tapped');
    setState(() {
      _loading = true;
      _startBusy = true;
    });
    try {
      _logHost('checking for existing active room');
      final existing = await _findMyActiveLiveDocument();
      if (existing != null) {
        _logHost('existing room found id=${existing.id}');
        final ch = (existing.data()['channel_name'] ?? '').toString();
        setState(() {
          _streamId = existing.id;
          _channelName = ch.isEmpty ? null : ch;
        });
        _logHost('requesting camera/mic before reopening host room');
        final perm = await LiveJoinService.ensureHostBroadcastPermissions();
        if (perm != null) {
          _logHost('camera/mic denied/failure: $perm');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(perm)),
            );
          }
          return;
        }
        _logHost('camera/mic granted');
        _navigateToHostRoom(existing.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Returning to your active live stream.'),
            ),
          );
        }
        return;
      }
      _logHost('no active room found — requesting camera/mic');
      final permErr = await LiveJoinService.ensureHostBroadcastPermissions();
      if (permErr != null) {
        _logHost('camera/mic denied/failure: $permErr');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(permErr)),
          );
        }
        return;
      }
      _logHost('camera/mic granted');

      _logHost('creating room doc (startLiveStream callable)');
      final callable = _functions.httpsCallable('startLiveStream');
      final res = await callable.call({
        'title': _titleController.text.trim().isEmpty
            ? 'PerezFans Live'
            : _titleController.text.trim(),
        'isAdult': _adult,
      });
      final raw = res.data;
      if (raw is! Map) {
        throw Exception('Invalid response from startLiveStream.');
      }
      final data = Map<String, dynamic>.from(raw);
      final streamId = data['streamId'] as String?;
      final channelName = data['channelName'] as String?;
      if (streamId == null || streamId.isEmpty) {
        throw Exception('Server did not return a stream id.');
      }
      _logHost('room doc ready streamId=$streamId reused=${data['reusedExisting']}');
      if (channelName == null || channelName.isEmpty) {
        _logHost('startLiveStream returned empty channelName');
      }
      setState(() {
        _streamId = streamId;
        _channelName = channelName;
      });
      _navigateToHostRoom(streamId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Live started. Channel: ${channelName ?? streamId}'),
          ),
        );
      }
    } catch (e, st) {
      _logHost('startLive failed', e, st);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_mapStartLiveError(e))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _startBusy = false;
        });
      }
    }
  }

  Future<void> _end() async {
    final id = _streamId;
    if (id == null) return;
    setState(() => _loading = true);
    try {
      final callable = _functions.httpsCallable('endLiveStream');
      await callable.call({
        'streamId': id,
        'replayUrl': _replayController.text.trim(),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Live ended. Replay will be added if URL is provided.'),
          ),
        );
      }
      setState(() {
        _streamId = null;
        _channelName = null;
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not end live: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    FirestoreListenerManager.instance.cancel('live_streams_active_list');
    _titleController.dispose();
    _replayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Go Live',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  font: GoogleFonts.poppins(),
                  letterSpacing: 0.0,
                ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Live title'),
              ),
              const SizedBox(height: 8.0),
              SwitchListTile.adaptive(
                value: _adult,
                onChanged: (v) => setState(() => _adult = v),
                title: const Text('Adult (18+) stream'),
              ),
              const SizedBox(height: 12.0),
              if (_streamId == null)
                ElevatedButton(
                  onPressed: _loading ? null : _start,
                  child: const Text('Start Live'),
                ),
              TextButton(
                onPressed: () => context.pushNamed(PerezFansLiveStream.routeName),
                child: const Text('Agora raw test (debug — .env token)'),
              ),
              TextButton(
                onPressed: () => context.pushNamed(PerezFansLiveWeb.routeName),
                child: const Text('Agora web layout (640×480)'),
              ),
              TextButton(
                onPressed: () => context.pushNamed(LiveGridWidget.routeName),
                child: const Text('Recorded Lives'),
              ),
              if (_streamId != null) ...[
                Text('Stream ID: $_streamId'),
                Text('Channel: ${_channelName ?? "-"}'),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _replayController,
                  decoration: const InputDecoration(
                    labelText: 'Replay URL (optional)',
                  ),
                ),
                const SizedBox(height: 8.0),
                ElevatedButton(
                  onPressed: _loading ? null : _end,
                  child: const Text('End Live and Publish Replay'),
                ),
              ],
              const SizedBox(height: 20.0),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirestoreListenerManager.instance.bindStream(
                    'live_streams_active_list',
                    () => FirebaseFirestore.instance
                        .collection('live_streams')
                        .where('status', isEqualTo: 'live')
                        .orderBy('started_at', descending: true)
                        .limit(20)
                        .snapshots(),
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      final err = snapshot.error;
                      developer.log(
                        'live_streams query failed',
                        name: 'LiveWidget',
                        error: err,
                      );
                      final detail = err is FirebaseException
                          ? '${err.code}: ${err.message ?? "query error"}'
                          : err.toString();
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_off_outlined,
                                size: 40,
                                color: FlutterFlowTheme.of(context).error,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Could not load the live list.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SelectableText(
                                detail,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                ),
                              ),
                              if (err is FirebaseException &&
                                  err.code == 'failed-precondition')
                                Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: Text(
                                    'A Firestore index may still be building. '
                                    'Check Firebase Console → Firestore → Indexes, or deploy firestore.indexes.json.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return const Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const SizedBox.shrink();
                    }
                    final docs = snapshot.data?.docs ?? [];
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        final data = docs[i].data() as Map<String, dynamic>;
                        final hostRef =
                            LiveJoinService.parseHostUserField(data['host_user']);
                        final me = currentUserReference;
                        final isMine =
                            hostRef != null && me != null && hostRef.path == me.path;
                        return ListTile(
                          title: Text((data['title'] ?? 'Untitled').toString()),
                          subtitle: Text(
                            isMine
                                ? 'Your stream • ${(data['status'] ?? 'unknown')}'
                                : 'Live now',
                          ),
                          trailing: TextButton(
                            onPressed: () {
                              final now = DateTime.now();
                              if (_lastLiveRoomNav != null &&
                                  now.difference(_lastLiveRoomNav!) <
                                      const Duration(milliseconds: 900)) {
                                return;
                              }
                              _lastLiveRoomNav = now;
                              context.pushNamed(
                                LiveRoomWidget.routeName,
                                queryParameters: {
                                  'streamRef': serializeParam(
                                    docs[i].reference,
                                    ParamType.DocumentReference,
                                  ),
                                  'streamId': serializeParam(
                                    docs[i].id,
                                    ParamType.String,
                                  ),
                                  'asHost': serializeParam(isMine, ParamType.bool),
                                }.withoutNulls,
                              );
                            },
                            child: Text(isMine ? 'Open' : 'Join'),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
