import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PayPerViewOverlay extends StatelessWidget {
  const PayPerViewOverlay({
    super.key,
    this.price,
    required this.isSubscribed,
    required this.onSubscribe,
    this.onPay,
  });

  final double? price;
  final bool isSubscribed;
  final VoidCallback onSubscribe;
  final VoidCallback? onPay;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock,
            color: FlutterFlowTheme.of(context).primary,
            size: 64.0,
          ),
          const SizedBox(height: 16.0),
          Text(
            isSubscribed && price != null && price! > 0
                ? 'Pay \$${price!.toStringAsFixed(2)} to view'
                : 'Subscribe to view',
            style: FlutterFlowTheme.of(context).headlineSmall.override(
                  font: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.normal,
                  ),
                  color: FlutterFlowTheme.of(context).primaryBtnText,
                  letterSpacing: 0.0,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8.0),
          Text(
            isSubscribed && price != null && price! > 0
                ? 'This content requires a one-time payment.'
                : 'This content is for subscribers only.',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.poppins(
                    fontWeight: FontWeight.normal,
                    fontStyle: FontStyle.normal,
                  ),
                  color: FlutterFlowTheme.of(context).secondaryText,
                  letterSpacing: 0.0,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24.0),
          if (isSubscribed && price != null && price! > 0 && onPay != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: SizedBox(
                width: double.infinity,
                child: MaterialButton(
                  onPressed: onPay,
                  color: FlutterFlowTheme.of(context).primary,
                  textColor: FlutterFlowTheme.of(context).primaryBtnText,
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    'Pay \$${price!.toStringAsFixed(2)}',
                    style: FlutterFlowTheme.of(context).titleSmall.override(
                          font: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.normal,
                          ),
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
              ),
            ),
          if (!isSubscribed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: SizedBox(
                width: double.infinity,
                child: MaterialButton(
                  onPressed: onSubscribe,
                  color: FlutterFlowTheme.of(context).primary,
                  textColor: FlutterFlowTheme.of(context).primaryBtnText,
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    'Subscribe to view',
                    style: FlutterFlowTheme.of(context).titleSmall.override(
                          font: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.normal,
                          ),
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
