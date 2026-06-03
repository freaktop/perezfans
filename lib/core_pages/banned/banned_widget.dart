import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BannedWidget extends StatefulWidget {
  const BannedWidget({super.key});

  static String routeName = 'Banned';
  static String routePath = 'banned';

  @override
  State<BannedWidget> createState() => _BannedWidgetState();
}

class _BannedWidgetState extends State<BannedWidget> {
  String? _reason;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSuspensionReason();
  }

  Future<void> _loadSuspensionReason() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
        .get();
    if (mounted) {
      setState(() {
        _reason = userDoc.data()?['suspension_reason'] as String?;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: _loading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.gpp_bad,
                      size: 96.0,
                      color: FlutterFlowTheme.of(context).error,
                    ),
                    const SizedBox(height: 24.0),
                    Text(
                      'Account Suspended',
                      style: FlutterFlowTheme.of(context)
                          .headlineMedium
                          .override(
                            font: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700),
                          ),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Your account has been suspended for violating our terms of service.',
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            font: GoogleFonts.poppins(),
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                    ),
                    if (_reason != null && _reason!.isNotEmpty) ...[
                      const SizedBox(height: 16.0),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context)
                              .error
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          _reason!,
                          textAlign: TextAlign.center,
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.poppins(),
                                  ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 32.0),
                    Text(
                      'If you believe this is an error, please contact support.',
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            font: GoogleFonts.poppins(),
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                    ),
                    const SizedBox(height: 24.0),
                    TextButton.icon(
                      onPressed: () async {
                        GoRouter.of(context).prepareAuthEvent();
                        await authManager.signOut();
                        GoRouter.of(context).clearRedirectLocation();
                        if (context.mounted) {
                          context.goNamedAuth(
                              WelcomeWidget.routeName, context.mounted);
                        }
                      },
                      icon: const Icon(Icons.logout, size: 18.0),
                      label: const Text('Sign Out'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
