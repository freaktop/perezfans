import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'affiliate_model.dart';
export 'affiliate_model.dart';

class AffiliateWidget extends StatefulWidget {
  const AffiliateWidget({super.key});

  static String routeName = 'Affiliate';
  static String routePath = 'affiliate';

  @override
  State<AffiliateWidget> createState() => _AffiliateWidgetState();
}

class _AffiliateWidgetState extends State<AffiliateWidget> {
  late AffiliateModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AffiliateModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myReferralCode = currentUserDocument?.referralCode ?? '';

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
            'Affiliate Program',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
          ),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: currentUserReference == null
            ? const SizedBox.shrink()
            : StreamBuilder<List<UsersRecord>>(
                stream: queryUsersRecord(
                  queryBuilder: (q) => q
                      .where('referred_by',
                          isEqualTo: currentUserReference)
                      .orderBy('created_time', descending: true)
                      .limit(50),
                ),
                builder: (context, snapshot) {
                  final referrals = snapshot.data ?? [];

                  return ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      _referralCard(context, myReferralCode),
                      const SizedBox(height: 24.0),
                      Text(
                        'Your Referrals (${referrals.length})',
                        style: FlutterFlowTheme.of(context)
                            .titleSmall
                            .override(
                              font: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600),
                            ),
                      ),
                      const SizedBox(height: 8.0),
                      if (referrals.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 32.0),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 64.0,
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                ),
                                const SizedBox(height: 12.0),
                                Text(
                                  'No referrals yet',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.poppins(),
                                        color:
                                            FlutterFlowTheme.of(context)
                                                .secondaryText,
                                      ),
                                ),
                                Text(
                                  'Share your code to start earning!',
                                  style: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .override(
                                        font: GoogleFonts.poppins(),
                                        color:
                                            FlutterFlowTheme.of(context)
                                                .secondaryText,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...referrals.map(
                          (ref) => _referralTile(context, ref),
                        ),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget _referralCard(BuildContext context, String code) {
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
          Row(
            children: [
              Icon(Icons.card_giftcard,
                  color: Colors.white, size: 24.0),
              const SizedBox(width: 8.0),
              Text(
                'Your Referral Code',
                style: FlutterFlowTheme.of(context)
                    .titleSmall
                    .override(
                      font: GoogleFonts.poppins(),
                      color: Colors.white70,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: SelectableText(
                code,
                style: GoogleFonts.poppins(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 4.0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _shareCode(code),
              icon: const Icon(Icons.share, color: Colors.white, size: 18.0),
              label: Text(
                'Share Referral Code',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                elevation: 0.0,
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

  void _shareCode(String code) {
    final shareText = 'Join me on PerezFans! Use my referral code: $code\n\nhttps://perezfans.web.app';
    Clipboard.setData(ClipboardData(text: shareText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard: $code'),
      ),
    );
  }

  Widget _referralTile(BuildContext context, UsersRecord referredUser) {
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
            CircleAvatar(
              radius: 20.0,
              backgroundImage: referredUser.photoUrl.isNotEmpty
                  ? NetworkImage(referredUser.photoUrl)
                  : null,
              backgroundColor:
                  FlutterFlowTheme.of(context).primary.withOpacity(0.1),
              child: referredUser.photoUrl.isEmpty
                  ? Text(
                      (referredUser.username.isNotEmpty
                              ? referredUser.username[0]
                              : referredUser.email[0])
                          .toUpperCase(),
                      style: FlutterFlowTheme.of(context).titleSmall,
                    )
                  : null,
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    referredUser.username.isNotEmpty
                        ? '@${referredUser.username}'
                        : referredUser.email,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.poppins(),
                        ),
                  ),
                  Text(
                    'Joined ${dateTimeFormat('MMM d, yyyy', referredUser.createdTime)}',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          font: GoogleFonts.poppins(),
                          color:
                              FlutterFlowTheme.of(context).secondaryText,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.check_circle,
              color: FlutterFlowTheme.of(context).success,
              size: 20.0,
            ),
          ],
        ),
      ),
    );
  }
}
