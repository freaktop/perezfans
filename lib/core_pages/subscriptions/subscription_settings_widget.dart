import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'stripe_connect_service.dart';
import 'subscription_settings_model.dart';
export 'subscription_settings_model.dart';

class SubscriptionSettingsWidget extends StatefulWidget {
  const SubscriptionSettingsWidget({super.key});

  static String routeName = 'SubscriptionSettings';
  static String routePath = 'subscription-settings';

  @override
  State<SubscriptionSettingsWidget> createState() =>
      _SubscriptionSettingsWidgetState();
}

class _SubscriptionSettingsWidgetState
    extends State<SubscriptionSettingsWidget> {
  late SubscriptionSettingsModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SubscriptionSettingsModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  Future<void> _saveSettings(CreatorSettingsRecord? settings) async {
    final myRef = currentUserReference;
    if (myRef == null) return;

    double parsePrice(TextEditingController? c) {
      final v = c?.text ?? '';
      return double.tryParse(v) ?? 0;
    }

    await CreatorSettingsRecord.collection.doc(myRef.id).set(
      createCreatorSettingsRecordData(
        user: myRef,
        isActive: true,
        bronzePrice: parsePrice(_model.bronzePriceTextController),
        bronzeName: _model.bronzeNameTextController?.text,
        silverPrice: parsePrice(_model.silverPriceTextController),
        silverName: _model.silverNameTextController?.text,
        goldPrice: parsePrice(_model.goldPriceTextController),
        goldName: _model.goldNameTextController?.text,
      ),
      SetOptions(merge: true),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subscription tiers updated')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final myRef = currentUserReference;
    if (myRef == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Subscription Settings')),
        body: const Center(child: Text('Sign in to manage subscriptions.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Subscription Tiers',
          style: FlutterFlowTheme.of(context).titleMedium.override(
                font: GoogleFonts.poppins(),
                letterSpacing: 0.0,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => _saveSettings(null),
            child: const Text('Save'),
          ),
        ],
      ),
      body: StreamBuilder<CreatorSettingsRecord>(
        stream: CreatorSettingsRecord.getDocument(
          CreatorSettingsRecord.collection.doc(myRef.id),
        ),
        builder: (context, snap) {
          final settings = snap.data;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set up to 3 subscription tiers. Fans can choose which tier to subscribe to.',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        font: GoogleFonts.poppins(),
                        color: FlutterFlowTheme.of(context).secondaryText,
                      ),
                ),
                const SizedBox(height: 20),
                _tierCard(
                  context: context,
                  title: 'Tier 1 (Bronze)',
                  icon: Icons.emoji_events,
                  defaultName: 'Bronze',
                  defaultPrice: 2.99,
                  nameController: _model.bronzeNameTextController ??=
                      TextEditingController(
                    text: settings?.bronzeName.isNotEmpty == true
                        ? settings!.bronzeName
                        : 'Bronze',
                  ),
                  nameFocusNode: _model.bronzeNameFocusNode,
                  priceController: _model.bronzePriceTextController ??=
                      TextEditingController(
                    text: (settings?.bronzePrice ?? 0) > 0
                        ? settings!.bronzePrice.toString()
                        : '2.99',
                  ),
                  priceFocusNode: _model.bronzePriceFocusNode,
                ),
                const SizedBox(height: 12),
                _tierCard(
                  context: context,
                  title: 'Tier 2 (Silver)',
                  icon: Icons.emoji_events,
                  defaultName: 'Silver',
                  defaultPrice: 4.99,
                  nameController: _model.silverNameTextController ??=
                      TextEditingController(
                    text: settings?.silverName.isNotEmpty == true
                        ? settings!.silverName
                        : 'Silver',
                  ),
                  nameFocusNode: _model.silverNameFocusNode,
                  priceController: _model.silverPriceTextController ??=
                      TextEditingController(
                    text: (settings?.silverPrice ?? 0) > 0
                        ? settings!.silverPrice.toString()
                        : '4.99',
                  ),
                  priceFocusNode: _model.silverPriceFocusNode,
                ),
                const SizedBox(height: 12),
                _tierCard(
                  context: context,
                  title: 'Tier 3 (Gold)',
                  icon: Icons.star,
                  defaultName: 'Gold',
                  defaultPrice: 9.99,
                  nameController: _model.goldNameTextController ??=
                      TextEditingController(
                    text: settings?.goldName.isNotEmpty == true
                        ? settings!.goldName
                        : 'Gold',
                  ),
                  nameFocusNode: _model.goldNameFocusNode,
                  priceController: _model.goldPriceTextController ??=
                      TextEditingController(
                    text: (settings?.goldPrice ?? 0) > 0
                        ? settings!.goldPrice.toString()
                        : '9.99',
                  ),
                  priceFocusNode: _model.goldPriceFocusNode,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Enable Subscriptions',
                      style: FlutterFlowTheme.of(context).bodyMedium,
                    ),
                    Switch(
                      value: settings?.isActive ?? false,
                      onChanged: (val) async {
                        await CreatorSettingsRecord.collection
                            .doc(myRef.id)
                            .set(
                              createCreatorSettingsRecordData(
                                user: myRef,
                                isActive: val,
                              ),
                              SetOptions(merge: true),
                            );
                      },
                      activeTrackColor:
                          FlutterFlowTheme.of(context).primary,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subscriber Count',
                      style: FlutterFlowTheme.of(context).bodyMedium,
                    ),
                    Text(
                      '${settings?.subscriberCount ?? 0}',
                      style: FlutterFlowTheme.of(context).titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        final url = await StripeConnectService()
                            .createStripeConnectAccount(
                          email: currentUserEmail,
                        );
                        final uri = Uri.parse(url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        }
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          FlutterFlowTheme.of(context).primary,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14.0),
                    ),
                    child: Text(
                      'Connect Stripe to receive payments',
                      style: FlutterFlowTheme.of(context)
                          .titleSmall
                          .override(
                            font: GoogleFonts.poppins(),
                            color: FlutterFlowTheme.of(context).info,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _tierCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String defaultName,
    required double defaultPrice,
    required TextEditingController nameController,
    required FocusNode? nameFocusNode,
    required TextEditingController priceController,
    required FocusNode? priceFocusNode,
  }) {
    return Card(
      color: FlutterFlowTheme.of(context).secondaryBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: FlutterFlowTheme.of(context).primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: nameController,
              focusNode: nameFocusNode,
              decoration: InputDecoration(
                labelText: 'Tier Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              style: FlutterFlowTheme.of(context).bodyMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: priceController,
              focusNode: priceFocusNode,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Monthly Price (\$)',
                prefixText: '\$ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              style: FlutterFlowTheme.of(context).bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
