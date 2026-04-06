import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/core/firestore_listener_manager.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatListWidget extends StatefulWidget {
  const ChatListWidget({super.key});

  static String routeName = 'ChatList';
  static String routePath = 'messages';

  @override
  State<ChatListWidget> createState() => _ChatListWidgetState();
}

class _ChatListWidgetState extends State<ChatListWidget> {
  String? _chatsStreamKey;

  @override
  void dispose() {
    if (_chatsStreamKey != null) {
      FirestoreListenerManager.instance.cancel(_chatsStreamKey!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myRef = currentUserReference;
    if (myRef == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Messages')),
        body: const Center(child: Text('Sign in to see messages.')),
      );
    }

    final chatsKey = 'chat_list_${myRef.id}';
    if (_chatsStreamKey != chatsKey) {
      if (_chatsStreamKey != null) {
        FirestoreListenerManager.instance.cancel(_chatsStreamKey!);
      }
      _chatsStreamKey = chatsKey;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Messages',
          style: FlutterFlowTheme.of(context).titleMedium.override(
                font: GoogleFonts.poppins(),
                letterSpacing: 0.0,
              ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreListenerManager.instance.bindStream(
          chatsKey,
          () => FirebaseFirestore.instance
              .collection('chats')
              .where('participants', arrayContains: myRef)
              .orderBy('updated_at', descending: true)
              .snapshots(),
        ),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Could not load conversations. If this is the first messages screen load, deploy Firestore indexes and try again.',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyMedium,
                ),
              ),
            );
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'No messages yet.\nOpen someone\'s profile and tap Message.',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyMedium,
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final raw = docs[i].data();
              final data = raw is Map<String, dynamic>
                  ? raw
                  : <String, dynamic>{};
              final participants =
                  (data['participants'] as List<dynamic>?) ?? [];
              DocumentReference? peerRef;
              for (final p in participants) {
                if (p is DocumentReference && p.path != myRef.path) {
                  peerRef = p;
                  break;
                }
              }
              final preview = (data['last_message'] ?? '').toString();
              return ListTile(
                title: peerRef == null
                    ? const Text('Chat')
                    : StreamBuilder<UsersRecord>(
                        stream: UsersRecord.getDocument(peerRef),
                        builder: (context, u) {
                          final name = u.data?.displayName.isNotEmpty == true
                              ? u.data!.displayName
                              : 'User';
                          return Text(
                            name,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                subtitle: Text(
                  preview.isEmpty ? 'Tap to open' : preview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  if (peerRef != null) {
                    context.pushNamed(
                      ChatWidget.routeName,
                      queryParameters: {
                        'peerRef': serializeParam(
                          peerRef,
                          ParamType.DocumentReference,
                        ),
                      }.withoutNulls,
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
