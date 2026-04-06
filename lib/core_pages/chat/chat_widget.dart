import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/core/firestore_listener_manager.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({
    super.key,
    this.peerRef,
  });

  final DocumentReference? peerRef;

  static String routeName = 'Chat';
  static String routePath = 'chat';

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final _inputController = TextEditingController();

  String get _chatId {
    final myId = currentUserReference!.id;
    final peerId = widget.peerRef!.id;
    final parts = [myId, peerId]..sort();
    return '${parts[0]}_${parts[1]}';
  }

  DocumentReference get _chatRef =>
      FirebaseFirestore.instance.collection('chats').doc(_chatId);

  CollectionReference get _messagesRef => _chatRef.collection('messages');

  Future<void> _ensureChat() async {
    await _chatRef.set({
      'participants': [currentUserReference, widget.peerRef],
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    await _ensureChat();
    await _messagesRef.add({
      'sender': currentUserReference,
      'text': text,
      'created_at': FieldValue.serverTimestamp(),
    });
    await _chatRef.set({
      'last_message': text,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _ensureChat();
    });
  }

  @override
  void dispose() {
    final peer = widget.peerRef;
    final me = currentUserReference;
    if (peer != null && me != null) {
      final parts = [me.id, peer.id]..sort();
      FirestoreListenerManager.instance
          .cancel('chat_messages_${parts[0]}_${parts[1]}');
    }
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final peerRef = widget.peerRef;
    if (peerRef == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: const Center(child: Text('No chat user selected.')),
      );
    }

    return StreamBuilder<UsersRecord>(
      stream: UsersRecord.getDocument(peerRef),
      builder: (context, peerSnap) {
        final peerName = peerSnap.data?.displayName.isNotEmpty == true
            ? peerSnap.data!.displayName
            : 'Chat';
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                peerName,
                style: FlutterFlowTheme.of(context).titleMedium.override(
                      font: GoogleFonts.poppins(),
                      letterSpacing: 0.0,
                    ),
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirestoreListenerManager.instance.bindStream(
                      'chat_messages_${_chatId}',
                      () => _messagesRef.orderBy('created_at').snapshots(),
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snapshot.data!.docs;
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 10.0,
                        ),
                        itemCount: docs.length,
                        itemBuilder: (context, i) {
                          final data = docs[i].data() as Map<String, dynamic>;
                          final sender = data['sender'] as DocumentReference?;
                          final mine = sender == currentUserReference;
                          final text = (data['text'] ?? '').toString();
                          return Align(
                            alignment: mine
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8.0),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 8.0,
                              ),
                              decoration: BoxDecoration(
                                color: mine
                                    ? FlutterFlowTheme.of(context).primary
                                    : FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Text(
                                text,
                                style:
                                    FlutterFlowTheme.of(context).bodyMedium.override(
                                          font: GoogleFonts.poppins(),
                                          color:
                                              mine ? Colors.white : null,
                                          letterSpacing: 0.0,
                                        ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _inputController,
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              hintStyle:
                                  FlutterFlowTheme.of(context).bodyMedium.override(
                                        font: GoogleFonts.poppins(),
                                        letterSpacing: 0.0,
                                      ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            onFieldSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        IconButton(
                          onPressed: _sendMessage,
                          icon: Icon(
                            Icons.send_rounded,
                            color: FlutterFlowTheme.of(context).primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
