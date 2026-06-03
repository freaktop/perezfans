import 'package:cloud_functions/cloud_functions.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class GiftShopWidget extends StatefulWidget {
  const GiftShopWidget({super.key});

  static String routeName = 'GiftShop';
  static String routePath = 'gift-shop';

  @override
  State<GiftShopWidget> createState() => _GiftShopWidgetState();
}

class _GiftShopWidgetState extends State<GiftShopWidget> {
  @override
  Widget build(BuildContext context) {
    final myRef = currentUserReference;
    if (myRef == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Gift Shop')),
        body: const Center(child: Text('Sign in to use the gift shop.')),
      );
    }

    final coinPackages = [
      _CoinPackage('Starter Pack', 100, 0.99),
      _CoinPackage('Popular Pack', 500, 4.99),
      _CoinPackage('Mega Pack', 1200, 9.99),
      _CoinPackage('Ultra Pack', 3000, 24.99),
      _CoinPackage('Legendary Pack', 7000, 49.99),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gift Shop',
          style: FlutterFlowTheme.of(context).titleMedium.override(
                font: GoogleFonts.poppins(),
                letterSpacing: 0.0,
              ),
        ),
      ),
      body: StreamBuilder<VirtualCoinsRecord>(
        stream: VirtualCoinsRecord.getDocument(
          VirtualCoinsRecord.collection.doc(myRef.id),
        ),
        builder: (context, snap) {
          final balance = snap.data?.balance ?? 0;
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                color: FlutterFlowTheme.of(context).primary.withOpacity(0.05),
                child: Column(
                  children: [
                    Icon(
                      Icons.monetization_on,
                      size: 48.0,
                      color: Colors.amber,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      '$balance',
                      style: FlutterFlowTheme.of(context)
                          .headlineMedium
                          .override(
                            font: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700),
                          ),
                    ),
                    Text(
                      'coins',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.poppins(),
                            color:
                                FlutterFlowTheme.of(context).secondaryText,
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
                      'Buy Coins',
                      style: FlutterFlowTheme.of(context)
                          .titleLarge
                          .override(
                            font: GoogleFonts.poppins(),
                            letterSpacing: 0.0,
                          ),
                    ),
                    const SizedBox(height: 12.0),
                    ...coinPackages.map((pkg) => Card(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          color: FlutterFlowTheme.of(context)
                              .secondaryBackground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 48.0,
                              height: 48.0,
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: const Icon(
                                Icons.monetization_on,
                                color: Colors.amber,
                                size: 28.0,
                              ),
                            ),
                            title: Text(
                              pkg.name,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600),
                                  ),
                            ),
                            subtitle: Text(
                              '${pkg.coins} coins',
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall,
                            ),
                            trailing: Text(
                              '\$${pkg.price.toStringAsFixed(2)}',
                              style: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    font: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w700),
                                    color: FlutterFlowTheme.of(context)
                                        .primary,
                                  ),
                            ),
                            onTap: () => _buyCoins(pkg, myRef),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _buyCoins(
      _CoinPackage pkg, DocumentReference myRef) async {
    final priceInCents = (pkg.price * 100).round();
    try {
      final functions = FirebaseFunctions.instance;
      final result =
          await functions.httpsCallable('createCoinPurchaseCheckout').call(
        <String, dynamic>{
          'coins': pkg.coins,
          'priceInCents': priceInCents,
        },
      );
      final url = result.data['url'] as String;
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

class _CoinPackage {
  final String name;
  final int coins;
  final double price;

  const _CoinPackage(this.name, this.coins, this.price);
}
