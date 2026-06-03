import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'stripe_connect_service.dart';

class SubscribeToCreatorWidget extends StatefulWidget {
  const SubscribeToCreatorWidget({
    super.key,
    required this.creatorRef,
  });

  final DocumentReference creatorRef;

  @override
  State<SubscribeToCreatorWidget> createState() =>
      _SubscribeToCreatorWidgetState();

  static String routeName = 'SubscribeToCreator';
  static String routePath = 'subscribe-to-creator';
}

class _SubscribeToCreatorWidgetState
    extends State<SubscribeToCreatorWidget> {
  bool _subscribing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Subscribe',
          style: FlutterFlowTheme.of(context).titleMedium.override(
                font: GoogleFonts.poppins(),
                letterSpacing: 0.0,
              ),
        ),
      ),
      body: StreamBuilder<CreatorSettingsRecord>(
        stream: CreatorSettingsRecord.getDocument(
          CreatorSettingsRecord.collection.doc(widget.creatorRef.id),
        ),
        builder: (context, snap) {
          final settings = snap.data;
          if (settings == null || !snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!settings.isActive) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'This creator has not enabled subscriptions yet.',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyLarge,
                ),
              ),
            );
          }

          final tiers = <_TierOption>[];
          final bp = settings.bronzePrice;
          if (bp > 0) {
            tiers.add(_TierOption(
              name: settings.bronzeName.isNotEmpty
                  ? settings.bronzeName
                  : 'Bronze',
              price: bp,
              icon: Icons.emoji_events,
              color: Colors.orange,
            ));
          }
          final sp = settings.silverPrice;
          if (sp > 0) {
            tiers.add(_TierOption(
              name: settings.silverName.isNotEmpty
                  ? settings.silverName
                  : 'Silver',
              price: sp,
              icon: Icons.emoji_events,
              color: Colors.grey,
            ));
          }
          final gp = settings.goldPrice;
          if (gp > 0) {
            tiers.add(_TierOption(
              name: settings.goldName.isNotEmpty
                  ? settings.goldName
                  : 'Gold',
              price: gp,
              icon: Icons.star,
              color: Colors.amber,
            ));
          }

          if (tiers.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'No subscription tiers configured yet.',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyLarge,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: tiers.length,
            itemBuilder: (context, i) {
              final tier = tiers[i];
              return Card(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                margin: const EdgeInsets.only(bottom: 12.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16.0),
                  onTap: _subscribing
                      ? null
                      : () => _subscribe(tier),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 56.0,
                          height: 56.0,
                          decoration: BoxDecoration(
                            color: tier.color.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(28.0),
                          ),
                          child: Icon(tier.icon,
                              color: tier.color, size: 28.0),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                tier.name,
                                style: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      font: GoogleFonts.poppins(
                                          fontWeight:
                                              FontWeight.w600),
                                    ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                '\$${tier.price.toStringAsFixed(2)}/month',
                                style: FlutterFlowTheme.of(context)
                                    .bodyLarge
                                    .override(
                                      font: GoogleFonts.poppins(
                                          fontWeight:
                                              FontWeight.w700),
                                      color:
                                          FlutterFlowTheme.of(context)
                                              .primary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16.0,
                          color: FlutterFlowTheme.of(context)
                              .secondaryText,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _subscribe(_TierOption tier) async {
    setState(() => _subscribing = true);
    try {
      final priceInCents = (tier.price * 100).round();
      final url = await StripeConnectService().createSubscriptionCheckout(
        creatorId: widget.creatorRef.id,
        priceInCents: priceInCents,
      );
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _subscribing = false);
    }
  }
}

class _TierOption {
  final String name;
  final double price;
  final IconData icon;
  final Color color;

  const _TierOption({
    required this.name,
    required this.price,
    required this.icon,
    required this.color,
  });
}
