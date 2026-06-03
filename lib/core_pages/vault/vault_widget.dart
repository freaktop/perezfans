import 'package:provider/provider.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/backend/backend.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'vault_model.dart';
export 'vault_model.dart';

class VaultWidget extends StatefulWidget {
  const VaultWidget({super.key});

  static String routeName = 'Vault';
  static String routePath = 'vault';

  @override
  State<VaultWidget> createState() => _VaultWidgetState();
}

class _VaultWidgetState extends State<VaultWidget>
    with SingleTickerProviderStateMixin {
  late VaultModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VaultModel());
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    _tabController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

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
          automaticallyImplyLeading: true,
          title: Text(
            'Vault',
            style: FlutterFlowTheme.of(context).headlineSmall.override(
                  font: GoogleFonts.poppins(
                    fontWeight: FlutterFlowTheme.of(context)
                        .headlineSmall
                        .fontWeight,
                    fontStyle: FlutterFlowTheme.of(context)
                        .headlineSmall
                        .fontStyle,
                  ),
                  letterSpacing: 0.0,
                ),
          ),
          actions: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 16.0, 0.0),
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  context.pushNamed('NewVaultRequest');
                },
                child: Icon(
                  Icons.add_circle_outline,
                  color: FlutterFlowTheme.of(context).primary,
                  size: 28.0,
                ),
              ),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: FlutterFlowTheme.of(context).primary,
            unselectedLabelColor:
                FlutterFlowTheme.of(context).secondaryText,
            tabs: [
              Tab(text: 'My Requests'),
              Tab(text: 'Requests for Me'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildMyRequestsTab(context),
            _buildRequestsForMeTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMyRequestsTab(BuildContext context) {
    final userRef = currentUserReference;
    if (userRef == null) {
      return Center(
        child: Text(
          'Please sign in',
          style: FlutterFlowTheme.of(context).bodyLarge,
        ),
      );
    }

    return StreamBuilder<List<VaultRequestsRecord>>(
      stream: queryVaultRequestsRecord(
        queryBuilder: (q) => q
            .where('requester', isEqualTo: userRef)
            .orderBy('created_time', descending: true),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: SizedBox(
              width: 30.0,
              height: 30.0,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  FlutterFlowTheme.of(context).primary,
                ),
              ),
            ),
          );
        }

        final requests = snapshot.data!;
        if (requests.isEmpty) {
          return Center(
            child: Text(
              'No requests yet',
              style: FlutterFlowTheme.of(context).bodyLarge,
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 8.0),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return _buildRequestCard(context, request);
          },
        );
      },
    );
  }

  Widget _buildRequestsForMeTab(BuildContext context) {
    final userRef = currentUserReference;
    if (userRef == null) {
      return Center(
        child: Text(
          'Please sign in',
          style: FlutterFlowTheme.of(context).bodyLarge,
        ),
      );
    }

    return StreamBuilder<List<VaultRequestsRecord>>(
      stream: queryVaultRequestsRecord(
        queryBuilder: (q) => q
            .where('creator', isEqualTo: userRef)
            .orderBy('created_time', descending: true),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: SizedBox(
              width: 30.0,
              height: 30.0,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  FlutterFlowTheme.of(context).primary,
                ),
              ),
            ),
          );
        }

        final requests = snapshot.data!;
        if (requests.isEmpty) {
          return Center(
            child: Text(
              'No requests for you yet',
              style: FlutterFlowTheme.of(context).bodyLarge,
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 8.0),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return _buildRequestCard(context, request);
          },
        );
      },
    );
  }

  Widget _buildRequestCard(
      BuildContext context, VaultRequestsRecord request) {
    return Card(
      margin: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 4.0),
      color: FlutterFlowTheme.of(context).secondaryBackground,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    request.title,
                    style: FlutterFlowTheme.of(context).titleSmall.override(
                          font: GoogleFonts.poppins(
                            fontWeight: FlutterFlowTheme.of(context)
                                .titleSmall
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .fontStyle,
                          ),
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
                Container(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                  decoration: BoxDecoration(
                    color: _statusColor(request.status),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    request.status,
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          font: GoogleFonts.poppins(
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodySmall
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodySmall
                                .fontStyle,
                          ),
                          color: FlutterFlowTheme.of(context).primaryBtnText,
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
              ],
            ),
            Padding(
              padding:
                  EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
              child: Text(
                request.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.poppins(
                        fontWeight: FlutterFlowTheme.of(context)
                            .bodyMedium
                            .fontWeight,
                        fontStyle: FlutterFlowTheme.of(context)
                            .bodyMedium
                            .fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).secondaryText,
                      letterSpacing: 0.0,
                    ),
              ),
            ),
            Padding(
              padding:
                  EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
              child: Text(
                request.createdTime != null
                    ? dateTimeFormat('yMMMd', request.createdTime)
                    : '',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      font: GoogleFonts.poppins(
                        fontWeight: FlutterFlowTheme.of(context)
                            .bodySmall
                            .fontWeight,
                        fontStyle: FlutterFlowTheme.of(context)
                            .bodySmall
                            .fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).secondaryText,
                      letterSpacing: 0.0,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'declined':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
