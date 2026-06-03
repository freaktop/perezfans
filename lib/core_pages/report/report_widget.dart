import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportWidget extends StatefulWidget {
  const ReportWidget({
    super.key,
    this.reportedUser,
  });

  final DocumentReference? reportedUser;

  static String routeName = 'Report';
  static String routePath = 'report';

  @override
  State<ReportWidget> createState() => _ReportWidgetState();
}

class _ReportWidgetState extends State<ReportWidget> {
  final List<String> _reasons = [
    'Spam',
    'Harassment',
    'Nudity/sexually explicit',
    'Hate speech',
    'Violence',
    'Impersonation',
    'Other',
  ];

  String? _selectedReason;
  final TextEditingController _detailsController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_selectedReason == null) return;

    setState(() => _submitting = true);

    try {
      await FirebaseFirestore.instance.collection('reports').add({
        'reported_by': currentUserReference,
        'reported_user': widget.reportedUser,
        'reason': _selectedReason,
        'details': _detailsController.text.trim(),
        'created_time': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted. Thank you.')),
        );
        context.safePop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting report: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Report User',
          style: FlutterFlowTheme.of(context).titleMedium.override(
                font: GoogleFonts.poppins(),
                letterSpacing: 0.0,
              ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select a reason for your report:',
              style: FlutterFlowTheme.of(context).bodyLarge,
            ),
            const SizedBox(height: 12.0),
            Expanded(
              child: ListView.separated(
                itemCount: _reasons.length,
                separatorBuilder: (_, __) => const Divider(height: 1.0),
                itemBuilder: (context, index) {
                  final reason = _reasons[index];
                  final isSelected = _selectedReason == reason;
                  return ListTile(
                    title: Text(reason),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: FlutterFlowTheme.of(context).primary,
                          )
                        : null,
                    selected: isSelected,
                    onTap: () {
                      setState(() => _selectedReason = reason);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: _detailsController,
              decoration: const InputDecoration(
                hintText: 'Additional details (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    (_selectedReason != null && !_submitting)
                        ? _submitReport
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 20.0,
                        height: 20.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Submit Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
