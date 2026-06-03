import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SendGiftWidget extends StatefulWidget {
  const SendGiftWidget({
    super.key,
    required this.recipientRef,
  });

  final DocumentReference recipientRef;

  @override
  State<SendGiftWidget> createState() => _SendGiftWidgetState();

  static String routeName = 'SendGift';
  static String routePath = 'send-gift';
}

class _SendGiftWidgetState extends State<SendGiftWidget> {
  bool _sending = false;

  final List<_GiftOption> _gifts = [
    _GiftOption('Rose', Icons.local_florist, 10, Colors.pink),
    _GiftOption('Heart', Icons.favorite, 25, Colors.red),
    _GiftOption('Crown', Icons.workspace_premium, 100, Colors.amber),
    _GiftOption('Diamond', Icons.diamond, 250, Colors.cyan),
    _GiftOption('Rocket', Icons.rocket_launch, 500, Colors.orange),
    _GiftOption('Lion', Icons.pets, 1000, Colors.deepPurple),
  ];

  @override
  Widget build(BuildContext context) {
    final myRef = currentUserReference;
    if (myRef == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Send Gift')),
        body: const Center(child: Text('Sign in to send gifts.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Send a Gift',
          style: FlutterFlowTheme.of(context).titleMedium.override(
                font: GoogleFonts.poppins(),
                letterSpacing: 0.0,
              ),
        ),
      ),
      body: StreamBuilder<UsersRecord>(
        stream: UsersRecord.getDocument(widget.recipientRef),
        builder: (context, userSnap) {
          final recipientName =
              userSnap.data?.displayName.isNotEmpty == true
                  ? userSnap.data!.displayName
                  : 'this creator';
          return StreamBuilder<VirtualCoinsRecord>(
            stream: VirtualCoinsRecord.getDocument(
              VirtualCoinsRecord.collection.doc(myRef.id),
            ),
            builder: (context, coinSnap) {
              final balance = coinSnap.data?.balance ?? 0;
              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    color: FlutterFlowTheme.of(context)
                        .primary
                        .withOpacity(0.05),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.monetization_on,
                            color: Colors.amber, size: 28.0),
                        const SizedBox(width: 8.0),
                        Text(
                          '$balance coins available',
                          style: FlutterFlowTheme.of(context)
                              .bodyLarge
                              .override(
                                font: GoogleFonts.poppins(),
                              ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Send a gift to $recipientName',
                          style: FlutterFlowTheme.of(context)
                              .titleSmall
                              .override(
                                font: GoogleFonts.poppins(),
                              ),
                        ),
                        const SizedBox(height: 16.0),
                        ..._gifts.map((gift) => Card(
                              margin: const EdgeInsets.only(bottom: 8.0),
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12.0),
                              ),
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.circular(12.0),
                                onTap: _sending || balance < gift.cost
                                    ? null
                                    : () => _sendGift(
                                        gift, myRef),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48.0,
                                        height: 48.0,
                                        decoration: BoxDecoration(
                                          color: gift.color
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(
                                                  12.0),
                                        ),
                                        child: Icon(gift.icon,
                                            color: gift.color,
                                            size: 24.0),
                                      ),
                                      const SizedBox(width: 12.0),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Text(
                                              gift.name,
                                              style: FlutterFlowTheme
                                                      .of(context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts
                                                        .poppins(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                  ),
                                            ),
                                            Text(
                                              '${gift.cost} coins',
                                              style: FlutterFlowTheme
                                                      .of(context)
                                                  .bodySmall
                                                  .override(
                                                    font: GoogleFonts
                                                        .poppins(),
                                                    color: FlutterFlowTheme
                                                            .of(context)
                                                        .secondaryText,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '${gift.cost}',
                                        style: FlutterFlowTheme
                                                .of(context)
                                            .titleSmall
                                            .override(
                                              font: GoogleFonts.poppins(
                                                  fontWeight:
                                                      FontWeight.w700),
                                              color: Colors.amber,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _sendGift(_GiftOption gift, DocumentReference myRef) async {
    if (_sending) return;
    setState(() => _sending = true);

    try {
      final batch = FirebaseFirestore.instance.batch();

      final coinDocRef =
          VirtualCoinsRecord.collection.doc(myRef.id);
      batch.update(coinDocRef, {
        'balance': FieldValue.increment(-gift.cost),
        'last_updated': FieldValue.serverTimestamp(),
      });

      final recipientCoinDocRef =
          VirtualCoinsRecord.collection.doc(widget.recipientRef.id);
      batch.set(
        recipientCoinDocRef,
        {
          'user': widget.recipientRef,
          'balance': FieldValue.increment(gift.cost),
          'last_updated': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      final txRef = CoinTransactionsRecord.collection.doc();
      batch.set(txRef, {
        'user': myRef,
        'recipient': widget.recipientRef,
        'amount': gift.cost,
        'type': 'gift',
        'description': 'Sent ${gift.name} gift',
        'created_time': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sent ${gift.name} gift (${gift.cost} coins)!'),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }
}

class _GiftOption {
  final String name;
  final IconData icon;
  final int cost;
  final Color color;

  const _GiftOption(this.name, this.icon, this.cost, this.color);
}
