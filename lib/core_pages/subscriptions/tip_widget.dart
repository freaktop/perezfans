import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'stripe_connect_service.dart';
import 'tip_model.dart';
export 'tip_model.dart';

class TipWidget extends StatefulWidget {
  const TipWidget({super.key, this.creatorRef});

  static String routeName = 'Tip';
  static String routePath = 'tip';

  final DocumentReference? creatorRef;

  @override
  State<TipWidget> createState() => _TipWidgetState();
}

class _TipWidgetState extends State<TipWidget> {
  late TipModel _model;

  final List<int> _presetAmountsCents = [100, 500, 1000, 2500, 5000];

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TipModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  int? get _effectiveAmountCents {
    if (_model.selectedPresetCents != null) {
      return _model.selectedPresetCents;
    }
    final customText = _model.customAmountTextController?.text;
    if (customText != null && customText.isNotEmpty) {
      final parsed = double.tryParse(customText);
      if (parsed != null && parsed > 0) {
        return (parsed * 100).round();
      }
    }
    return null;
  }

  Future<void> _sendTip() async {
    final creatorRef = widget.creatorRef;
    final amountCents = _effectiveAmountCents;
    if (creatorRef == null || amountCents == null) return;

    try {
      final url = await StripeConnectService().createTipCheckout(
        creatorId: creatorRef.id,
        amountInCents: amountCents,
      );
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Tip initiated! Complete payment in your browser.'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Send a Tip',
          style: FlutterFlowTheme.of(context).titleMedium.override(
                font: GoogleFonts.poppins(),
                letterSpacing: 0.0,
              ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose amount',
              style: FlutterFlowTheme.of(context).bodyMedium,
            ),
            const SizedBox(height: 12.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _presetAmountsCents.map((cents) {
                final dollars = cents ~/ 100;
                final isSelected = _model.selectedPresetCents == cents;
                return ChoiceChip(
                  label: Text(
                    '\$$dollars',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          color: isSelected
                              ? FlutterFlowTheme.of(context).primaryBtnText
                              : null,
                        ),
                  ),
                  selected: isSelected,
                  onSelected: (val) {
                    safeSetState(() {
                      _model.selectedPresetCents = val ? cents : null;
                      _model.customAmountTextController?.clear();
                    });
                  },
                  selectedColor: FlutterFlowTheme.of(context).primary,
                  backgroundColor:
                      FlutterFlowTheme.of(context).secondaryBackground,
                );
              }).toList(),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _model.customAmountTextController ??=
                  TextEditingController(),
              focusNode: _model.customAmountFocusNode,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: '\$ ',
                hintText: 'Custom amount',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              style: FlutterFlowTheme.of(context).bodyMedium,
              onChanged: (_) {
                safeSetState(() {
                  _model.selectedPresetCents = null;
                });
              },
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _model.messageTextController ??=
                  TextEditingController(),
              focusNode: _model.messageFocusNode,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add a message (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              style: FlutterFlowTheme.of(context).bodyMedium,
            ),
            const SizedBox(height: 24.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _effectiveAmountCents != null ? _sendTip : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14.0),
                ),
                child: Text(
                  _effectiveAmountCents != null
                      ? 'Send \$${(_effectiveAmountCents! / 100).toStringAsFixed(2)}'
                      : 'Select an amount',
                  style: FlutterFlowTheme.of(context).titleSmall.override(
                        font: GoogleFonts.poppins(),
                        color: FlutterFlowTheme.of(context).info,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
