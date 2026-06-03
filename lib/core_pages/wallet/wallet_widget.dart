import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'wallet_model.dart';
export 'wallet_model.dart';

class WalletWidget extends StatefulWidget {
  const WalletWidget({super.key});

  static String routeName = 'Wallet';
  static String routePath = 'wallet';

  @override
  State<WalletWidget> createState() => _WalletWidgetState();
}

class _WalletWidgetState extends State<WalletWidget> {
  late WalletModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WalletModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          title: Text(
            'Wallet',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
          ),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: currentUserReference == null
            ? const SizedBox.shrink()
            : StreamBuilder<List<TipsRecord>>(
                stream: queryTipsRecord(
                  queryBuilder: (q) => q
                      .where('creator', isEqualTo: currentUserReference)
                      .where('status', isEqualTo: 'completed')
                      .orderBy('created_time', descending: true)
                      .limit(50),
                ),
                builder: (context, tipsSnapshot) {
                  final tips = tipsSnapshot.data ?? [];
                  final totalTips = tips.fold<double>(
                      0.0, (sum, t) => sum + t.amount);

                  return StreamBuilder<List<SubscriptionsRecord>>(
                    stream: querySubscriptionsRecord(
                      queryBuilder: (q) => q
                          .where('creator', isEqualTo: currentUserReference)
                          .where('status', isEqualTo: 'active'),
                    ),
                    builder: (context, subSnapshot) {
                      final subs = subSnapshot.data ?? [];

                      return ListView(
                        padding: const EdgeInsets.all(16.0),
                        children: [
                          _balanceCard(
                            context,
                            totalTips: totalTips,
                            subscriberCount: subs.length,
                          ),
                          const SizedBox(height: 24.0),
                          Row(
                            children: [
                              Icon(
                                Icons.receipt_long,
                                color: FlutterFlowTheme.of(context).primary,
                                size: 20.0,
                              ),
                              const SizedBox(width: 8.0),
                              Text(
                                'Recent Transactions',
                                style: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      font: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600),
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          if (tips.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 24.0),
                              child: Center(
                                child: Text(
                                  'No transactions yet',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.poppins(),
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                      ),
                                ),
                              ),
                            )
                          else
                            ...tips.map(
                              (tip) => _transactionTile(context, tip),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
      ),
    );
  }

  Widget _balanceCard(
    BuildContext context, {
    required double totalTips,
    required int subscriberCount,
  }) {
    final estimatedSubRevenue = subscriberCount * 9.99;
    final total = totalTips + estimatedSubRevenue;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FlutterFlowTheme.of(context).primary,
            FlutterFlowTheme.of(context).tertiary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Earned',
            style: FlutterFlowTheme.of(context).titleSmall.override(
                  font: GoogleFonts.poppins(),
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 8.0),
          Text(
            '\$${total.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontSize: 32.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              _statItem(context, 'Tips', '\$${totalTips.toStringAsFixed(0)}'),
              const SizedBox(width: 24.0),
              _statItem(context, 'Subscribers', '$subscriberCount'),
            ],
          ),
          const SizedBox(height: 16.0),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {
                context.pushNamed(PayoutHistoryWidget.routeName);
              },
              icon: const Icon(Icons.open_in_new, color: Colors.white, size: 18.0),
              label: Text(
                'Withdraw to Stripe',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.0,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _transactionTile(BuildContext context, TipsRecord tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(
                Icons.payments,
                color: FlutterFlowTheme.of(context).primary,
                size: 20.0,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tip received',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.poppins(),
                        ),
                  ),
                  if (tip.hasMessage() && tip.message!.isNotEmpty)
                    Text(
                      tip.message!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            font: GoogleFonts.poppins(),
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                    ),
                ],
              ),
            ),
            Text(
              '+\$${tip.amount.toStringAsFixed(2)}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: FlutterFlowTheme.of(context).success,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
