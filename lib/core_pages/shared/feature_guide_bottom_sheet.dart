import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeatureGuideBottomSheet extends StatelessWidget {
  const FeatureGuideBottomSheet({
    super.key,
    required this.title,
    required this.description,
    this.steps,
  });

  final String title;
  final String description;
  final List<String>? steps;

  static Future<void> showGuide(BuildContext context, {
    required String title,
    required String description,
    List<String>? steps,
  }) async {
    await showModalBottomSheet(
      context: context,
      builder: (ctx) => FeatureGuideBottomSheet(
        title: title,
        description: description,
        steps: steps,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryText,
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              title,
              style: FlutterFlowTheme.of(context).headlineSmall.override(
                    font: GoogleFonts.poppins(),
                    letterSpacing: 0.0,
                  ),
            ),
            const SizedBox(height: 12.0),
            Text(
              description,
              style: FlutterFlowTheme.of(context).bodyLarge.override(
                    font: GoogleFonts.poppins(),
                    letterSpacing: 0.0,
                  ),
            ),
            if (steps != null && steps!.isNotEmpty) ...[
              const SizedBox(height: 16.0),
              ...List.generate(
                steps!.length,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24.0,
                        height: 24.0,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primary,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Text(
                          steps![i],
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                font: GoogleFonts.poppins(),
                                letterSpacing: 0.0,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20.0),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Got it',
                  style: FlutterFlowTheme.of(context).titleSmall.override(
                        font: GoogleFonts.poppins(),
                        letterSpacing: 0.0,
                        color: FlutterFlowTheme.of(context).primary,
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
