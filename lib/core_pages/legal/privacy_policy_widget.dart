import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyWidget extends StatefulWidget {
  const PrivacyPolicyWidget({super.key});

  static String routeName = 'PrivacyPolicy';
  static String routePath = 'privacy-policy';

  @override
  State<PrivacyPolicyWidget> createState() => _PrivacyPolicyWidgetState();
}

class _PrivacyPolicyWidgetState extends State<PrivacyPolicyWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        title: Text(
          'Privacy Policy',
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
              'Privacy Policy',
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
            _section('1. Information We Collect',
                'We collect information you provide when creating an account (email, username, profile info), content you upload, and usage data (interactions, preferences).'),
            _section('2. How We Use Your Information',
                'We use your information to operate the platform, process payments, send notifications, personalize your experience, and improve our services.'),
            _section('3. Data Sharing',
                'We share data with Stripe for payment processing and Firebase for hosting and analytics. We do not sell your personal data to third parties.'),
            _section('4. Data Security',
                'We implement industry-standard security measures including encryption in transit and at rest. However, no system is 100% secure.'),
            _section('5. Your Rights',
                'You can access, update, or delete your data at any time through your account settings. You can request data export by contacting support.'),
            _section('6. Cookies',
                'We use essential cookies for authentication and functionality. Analytics cookies help us improve the platform. You can disable cookies in your browser settings.'),
            _section('7. Children\'s Privacy',
                'We do not knowingly collect data from children under 13. If you believe a child has provided us with data, contact us immediately.'),
            _section('8. Data Retention',
                'We retain your data for as long as your account is active. After deletion, we may retain anonymized analytics for up to 90 days.'),
            _section('9. International Transfers',
                'Your data may be processed on servers located in the United States and other countries where our service providers operate.'),
            _section('10. Contact',
                'For privacy inquiries, contact us at privacy@perezfans.com.'),
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
