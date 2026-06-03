import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'subscriptions_list_model.dart';
export 'subscriptions_list_model.dart';

class SubscriptionsListWidget extends StatefulWidget {
  const SubscriptionsListWidget({super.key});

  static String routeName = 'SubscriptionsList';
  static String routePath = 'subscriptions';

  @override
  State<SubscriptionsListWidget> createState() =>
      _SubscriptionsListWidgetState();
}

class _SubscriptionsListWidgetState extends State<SubscriptionsListWidget> {
  late SubscriptionsListModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SubscriptionsListModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myRef = currentUserReference;
    if (myRef == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Subscriptions')),
        body: const Center(child: Text('Sign in to see your subscriptions.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Subscriptions',
          style: FlutterFlowTheme.of(context).titleMedium.override(
                font: GoogleFonts.poppins(),
                letterSpacing: 0.0,
              ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: SubscriptionsRecord.collection
            .where('subscriber', isEqualTo: myRef)
            .orderBy('created_time', descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Could not load subscriptions.',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyMedium,
                ),
              ),
            );
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'No subscriptions yet.\nSubscribe to a creator to see their exclusive content.',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyMedium,
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final raw = docs[i].data();
              final data = raw is Map<String, dynamic>
                  ? raw
                  : <String, dynamic>{};
              final creatorRef =
                  data['creator'] as DocumentReference?;
              final status =
                  (data['status'] ?? '').toString();
              final isActive = status == 'active';
              final tierName = data['tier'] as String?;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      FlutterFlowTheme.of(context).alternate,
                ),
                title: creatorRef == null
                    ? const Text('Creator')
                    : StreamBuilder<UsersRecord>(
                        stream: UsersRecord.getDocument(creatorRef),
                        builder: (context, u) {
                          final name =
                              u.data?.displayName.isNotEmpty == true
                                  ? u.data!.displayName
                                  : 'Creator';
                          return Text(
                            name,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isActive ? 'Active' : status,
                      style: GoogleFonts.poppins(
                        color: isActive ? Colors.green : Colors.grey,
                      ),
                    ),
                    if (tierName != null && tierName.isNotEmpty)
                      Text(
                        tierName,
                        style: GoogleFonts.poppins(
                          fontSize: 12.0,
                          color: FlutterFlowTheme.of(context)
                              .secondaryText,
                        ),
                      ),
                  ],
                ),
                onTap: () {
                  if (creatorRef != null) {
                    context.pushNamed(
                      ProfileOtherWidget.routeName,
                      queryParameters: {
                        'userID': serializeParam(
                          creatorRef,
                          ParamType.DocumentReference,
                        ),
                      }.withoutNulls,
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
