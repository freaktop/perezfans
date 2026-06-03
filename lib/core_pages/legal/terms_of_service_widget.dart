import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsOfServiceWidget extends StatefulWidget {
  const TermsOfServiceWidget({super.key});

  static String routeName = 'TermsOfService';
  static String routePath = 'terms-of-service';

  @override
  State<TermsOfServiceWidget> createState() => _TermsOfServiceWidgetState();
}

class _TermsOfServiceWidgetState extends State<TermsOfServiceWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        title: Text(
          'Terms of Service',
          style: FlutterFlowTheme.of(context).titleMedium.override(
                font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Service',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Last updated: June 1, 2026',
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.poppins(),
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
            ),
            const SizedBox(height: 24.0),
            _section('1. Acceptance of Terms',
                'By accessing or using PerezFans, you agree to be bound by these Terms of Service. If you do not agree, do not use the platform.'),
            _section('2. Eligibility',
                'You must be at least 13 years old to use PerezFans. Users who view adult content must be at least 18 years old. By using the platform, you represent that you meet these age requirements.'),
            _section('3. User Accounts',
                'You are responsible for maintaining the confidentiality of your account credentials. You must provide accurate and complete information when creating an account.'),
            _section('4. Content Guidelines',
                'You retain ownership of content you post but grant PerezFans a license to display it. You may not post illegal, harmful, or infringing content. We reserve the right to remove content that violates these terms.'),
            _section('5. Prohibited Activities',
                'You agree not to: harass others, impersonate others, spam, distribute malware, attempt to access unauthorized areas, or use the platform for illegal purposes.'),
            _section('6. Payments & Monetization',
                'Creators may earn revenue through tips, subscriptions, and other monetization features. PerezFans charges a platform fee. All payments are processed through Stripe. Refunds are at the creator\'s discretion.'),
            _section('7. Termination',
                'We reserve the right to suspend or terminate accounts that violate these terms. You may delete your account at any time from the app settings.'),
            _section('8. Limitation of Liability',
                'PerezFans is provided "as is" without warranties. We are not liable for damages arising from your use of the platform.'),
            _section('9. Changes to Terms',
                'We may update these terms at any time. Continued use after changes constitutes acceptance of the new terms.'),
            _section('10. Contact',
                'For questions about these terms, contact us at support@perezfans.com.'),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: FlutterFlowTheme.of(context).titleSmall.override(
                  font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
          ),
          const SizedBox(height: 4.0),
          Text(
            body,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.poppins(),
                ),
          ),
        ],
      ),
    );
  }
}
