import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeleteAccountWidget extends StatefulWidget {
  const DeleteAccountWidget({super.key});

  static String routeName = 'DeleteAccount';
  static String routePath = 'delete-account';

  @override
  State<DeleteAccountWidget> createState() => _DeleteAccountWidgetState();
}

class _DeleteAccountWidgetState extends State<DeleteAccountWidget> {
  bool _deleting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        title: Text(
          'Delete Account',
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: FlutterFlowTheme.of(context).error.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    color: FlutterFlowTheme.of(context).error,
                    size: 24.0,
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Text(
                      'This action cannot be undone. All your data will be permanently deleted.',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.poppins(),
                            color: FlutterFlowTheme.of(context).error,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
            Text(
              'What will be deleted:',
              style: FlutterFlowTheme.of(context).titleSmall.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
            ),
            const SizedBox(height: 8.0),
            _bullet('Your profile and account info'),
            _bullet('All videos and content you uploaded'),
            _bullet('Comments, likes, and bookmarks'),
            _bullet('Subscription and tip history'),
            _bullet('Your referral code and affiliate data'),
            const SizedBox(height: 16.0),
            Text(
              'What will remain:',
              style: FlutterFlowTheme.of(context).titleSmall.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
            ),
            const SizedBox(height: 8.0),
            _bullet('Comments you left on others\' videos (anonymized)'),
            _bullet('Tips you sent to creators (transaction records)'),
            const SizedBox(height: 32.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _deleting ? null : _confirmDelete,
                icon: _deleting
                    ? const SizedBox(
                        width: 18.0,
                        height: 18.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.delete_forever, color: Colors.white),
                label: Text(
                  _deleting ? 'Deleting...' : 'Permanently Delete My Account',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FlutterFlowTheme.of(context).error,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0, left: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: FlutterFlowTheme.of(context).bodyMedium),
          Expanded(
            child: Text(
              text,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.poppins(),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        title: const Text('Confirm Deletion'),
        content: const Text(
          'Are you absolutely sure? This will permanently delete your account and all associated data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: FlutterFlowTheme.of(context).error,
            ),
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    setState(() => _deleting = true);

    try {
      final uid = currentUserUid;
      if (uid.isEmpty) return;

      await FirebaseFirestore.instance.collection('deletion_requests').add({
        'uid': uid,
        'user_ref': currentUserReference,
        'email': currentUserEmail,
        'requested_at': FieldValue.serverTimestamp(),
      });

      await currentUser?.delete();

      await authManager.signOut();
      GoRouter.of(context).clearRedirectLocation();

      if (context.mounted) {
        context.goNamedAuth(WelcomeWidget.routeName, context.mounted);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deletion request submitted.'),
          ),
        );
      }
    } catch (e) {
      setState(() => _deleting = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
}
