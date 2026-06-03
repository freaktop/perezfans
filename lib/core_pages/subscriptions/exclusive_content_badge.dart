import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExclusiveContentBadge extends StatelessWidget {
  const ExclusiveContentBadge({
    super.key,
    required this.isExclusive,
    required this.isSubscribed,
  });

  final bool isExclusive;
  final bool isSubscribed;

  @override
  Widget build(BuildContext context) {
    if (!isExclusive || isSubscribed) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock,
            color: FlutterFlowTheme.of(context).primaryBtnText,
            size: 14.0,
          ),
          const SizedBox(width: 4.0),
          Text(
            'Subscriber Only',
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  font: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.normal,
                  ),
                  color: FlutterFlowTheme.of(context).primaryBtnText,
                  letterSpacing: 0.0,
                ),
          ),
        ],
      ),
    );
  }
}
