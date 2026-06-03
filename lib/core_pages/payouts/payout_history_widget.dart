import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class PayoutHistoryWidget extends StatefulWidget {
  const PayoutHistoryWidget({super.key});

  static String routeName = 'PayoutHistory';
  static String routePath = 'payout-history';

  @override
  State<PayoutHistoryWidget> createState() => _PayoutHistoryWidgetState();
}

class _PayoutHistoryWidgetState extends State<PayoutHistoryWidget> {
  @override
  Widget build(BuildContext context) {
    final myRef = currentUserReference;
    if (myRef == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Payout History')),
        body: const Center(child: Text('Sign in to view payouts.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payout History',
          style: FlutterFlowTheme.of(context).titleMedium.override(
                font: GoogleFonts.poppins(),
                letterSpacing: 0.0,
              ),
        ),
      ),
      body: StreamBuilder<List<PayoutsRecord>>(
        stream: queryPayoutsRecord(
          queryBuilder: (q) => q
              .where('creator', isEqualTo: myRef)
              .orderBy('created_time', descending: true)
              .limit(50),
        ),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Could not load payouts.',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyMedium,
                ),
              ),
            );
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final payouts = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.account_balance,
                        size: 48.0,
                        color: FlutterFlowTheme.of(context).primary,
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        'Your earnings are paid out via Stripe Connect.',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context)
                            .bodyMedium
                            .override(
                              font: GoogleFonts.poppins(),
                            ),
                      ),
                      const SizedBox(height: 12.0),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final uri = Uri.parse(
                                'https://dashboard.stripe.com/connect/payouts');
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri,
                                  mode: LaunchMode.externalApplication);
                            }
                          },
                          icon: const Icon(Icons.open_in_new, size: 18.0),
                          label: const Text('View on Stripe Dashboard'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              if (payouts.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      'No payouts yet.',
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            font: GoogleFonts.poppins(),
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                    ),
                  ),
                )
              else
                ...payouts.map((p) => _payoutCard(context, p)),
            ],
          );
        },
      ),
    );
  }

  Widget _payoutCard(BuildContext context, PayoutsRecord payout) {
    final status = payout.status;
    Color statusColor;
    IconData statusIcon;
    switch (status) {
      case 'paid':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      case 'failed':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      case 'in_transit':
        statusColor = Colors.blue;
        statusIcon = Icons.local_shipping;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      color: FlutterFlowTheme.of(context).secondaryBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 44.0,
              height: 44.0,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(22.0),
              ),
              child: Icon(statusIcon, color: statusColor, size: 22.0),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$${payout.amount.toStringAsFixed(2)}',
                    style: FlutterFlowTheme.of(context).titleSmall.override(
                          font: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600),
                        ),
                  ),
                  if (payout.hasCreatedTime())
                    Text(
                      dateTimeFormat('MMM d, yyyy', payout.createdTime!),
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            font: GoogleFonts.poppins(),
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                    ),
                ],
              ),
            ),
            Chip(
              label: Text(
                status.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 10.0,
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: statusColor.withOpacity(0.1),
              side: BorderSide.none,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}
