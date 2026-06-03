import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'search_model.dart';
export 'search_model.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget({super.key});

  static String routeName = 'Search';
  static String routePath = 'search';

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget>
    with TickerProviderStateMixin {
  late SearchModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final searchController = TextEditingController();
  final pageSize = 10;

  List<UsersRecord> _userResults = [];
  List<VideosRecord> _videoResults = [];
  DocumentSnapshot? _userPageMarker;
  DocumentSnapshot? _videoPageMarker;
  bool _loadingUsers = false;
  bool _loadingVideos = false;
  bool _hasMoreUsers = true;
  bool _hasMoreVideos = true;
  String _currentQuery = '';
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SearchModel());

    _model.tabBarController = TabController(
      vsync: this,
      length: 2,
      initialIndex: 0,
    )..addListener(() => safeSetState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final query = GoRouterState.of(context).uri.queryParameters['q'] ?? '';
      if (query.isNotEmpty) {
        searchController.text = query;
        _search(query);
      }
      safeSetState(() {});
    });
  }

  @override
  void dispose() {
    _model.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      safeSetState(() {
        _currentQuery = '';
        _userResults = [];
        _videoResults = [];
        _userPageMarker = null;
        _videoPageMarker = null;
        _hasMoreUsers = true;
        _hasMoreVideos = true;
      });
      return;
    }
    if (q == _currentQuery && _userResults.isNotEmpty) return;
    _currentQuery = q;
    safeSetState(() {
      _userResults = [];
      _videoResults = [];
      _userPageMarker = null;
      _videoPageMarker = null;
      _hasMoreUsers = true;
      _hasMoreVideos = true;
    });
    await _loadMoreUsers();
    await _loadMoreVideos();
  }

  Future<void> _loadMoreUsers() async {
    if (_loadingUsers || !_hasMoreUsers || _currentQuery.isEmpty) return;
    _loadingUsers = true;
    safeSetState(() {});
    try {
      final page = await queryCollectionPage(
        UsersRecord.collection,
        UsersRecord.fromSnapshot,
        queryBuilder: (q) =>
            q.where('search_keywords', arrayContains: _currentQuery),
        nextPageMarker: _userPageMarker,
        pageSize: pageSize,
        isStream: false,
      );
      safeSetState(() {
        _userResults.addAll(page.data);
        _userPageMarker = page.nextPageMarker;
        _hasMoreUsers = page.data.length >= pageSize;
        _loadingUsers = false;
      });
    } catch (e) {
      safeSetState(() {
        _loadingUsers = false;
      });
    }
  }

  Future<void> _loadMoreVideos() async {
    if (_loadingVideos || !_hasMoreVideos || _currentQuery.isEmpty) return;
    _loadingVideos = true;
    safeSetState(() {});
    try {
      final page = await queryCollectionPage(
        VideosRecord.collection,
        VideosRecord.fromSnapshot,
        queryBuilder: (q) =>
            q.where('search_keywords', arrayContains: _currentQuery),
        nextPageMarker: _videoPageMarker,
        pageSize: pageSize,
        isStream: false,
      );
      safeSetState(() {
        _videoResults.addAll(page.data);
        _videoPageMarker = page.nextPageMarker;
        _hasMoreVideos = page.data.length >= pageSize;
        _loadingVideos = false;
      });
    } catch (e) {
      safeSetState(() {
        _loadingVideos = false;
      });
    }
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
          automaticallyImplyLeading: true,
          title: TextField(
            controller: searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search users and videos...',
              hintStyle: FlutterFlowTheme.of(context).bodySmall,
              border: InputBorder.none,
              filled: true,
              fillColor: FlutterFlowTheme.of(context).secondaryBackground,
              contentPadding:
                  const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
              prefixIcon: Icon(
                Icons.search,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: FlutterFlowTheme.of(context).secondaryText,
                      ),
                      onPressed: () {
                        searchController.clear();
                        _search('');
                      },
                    )
                  : null,
            ),
            style: FlutterFlowTheme.of(context).bodyMedium,
            onSubmitted: (value) => _search(value),
            onChanged: (value) {
              safeSetState(() {});
              if (value.isEmpty) {
                _search('');
              }
            },
          ),
        ),
        body: Column(
          children: [
            if (_currentQuery.isNotEmpty)
              TabBar(
                controller: _model.tabBarController,
                onTap: (i) => safeSetState(() => _tabIndex = i),
                labelColor: FlutterFlowTheme.of(context).primary,
                unselectedLabelColor:
                    FlutterFlowTheme.of(context).secondaryText,
                indicatorColor: FlutterFlowTheme.of(context).primary,
                tabs: const [
                  Tab(text: 'Users'),
                  Tab(text: 'Videos'),
                ],
              ),
            Expanded(
              child: _currentQuery.isEmpty
                  ? Center(
                      child: Text(
                        'Type to search users and videos',
                        style: FlutterFlowTheme.of(context).bodyMedium,
                      ),
                    )
                  : _tabIndex == 0
                      ? _buildUsersList()
                      : _buildVideosList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    if (_userResults.isEmpty && _loadingUsers) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_userResults.isEmpty) {
      return Center(
        child: Text(
          'No users found',
          style: FlutterFlowTheme.of(context).bodyMedium,
        ),
      );
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 100) {
          _loadMoreUsers();
        }
        return false;
      },
      child: ListView.builder(
        itemCount: _userResults.length + (_hasMoreUsers ? 1 : 0),
        itemBuilder: (context, i) {
          if (i >= _userResults.length) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = _userResults[i];
          return ListTile(
            leading: Container(
              width: 48.0,
              height: 48.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: user.photoUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(user.photoUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: FlutterFlowTheme.of(context).secondaryBackground,
              ),
              child: user.photoUrl.isEmpty
                  ? Icon(
                      Icons.person,
                      color: FlutterFlowTheme.of(context).secondaryText,
                    )
                  : null,
            ),
            title: Text(
              user.username.isNotEmpty ? user.username : user.displayName,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
            ),
            subtitle: Text(
              '${user.displayName} · ${user.followers.length} followers',
              style: FlutterFlowTheme.of(context).bodySmall,
            ),
            onTap: () async {
              if (user.reference.path == currentUserReference?.path) {
                context.pushNamed(ProfileWidget.routeName);
              } else {
                context.pushNamed(
                  ProfileOtherWidget.routeName,
                  queryParameters: {
                    'userID': serializeParam(
                      user.reference,
                      ParamType.DocumentReference,
                    ),
                  }.withoutNulls,
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildVideosList() {
    if (_videoResults.isEmpty && _loadingVideos) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_videoResults.isEmpty) {
      return Center(
        child: Text(
          'No videos found',
          style: FlutterFlowTheme.of(context).bodyMedium,
        ),
      );
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 100) {
          _loadMoreVideos();
        }
        return false;
      },
      child: ListView.builder(
        itemCount: _videoResults.length + (_hasMoreVideos ? 1 : 0),
        itemBuilder: (context, i) {
          if (i >= _videoResults.length) {
            return const Center(child: CircularProgressIndicator());
          }
          final video = _videoResults[i];
          return StreamBuilder<UsersRecord>(
            stream: video.videoUser != null
                ? UsersRecord.getDocument(video.videoUser!)
                : null,
            builder: (context, snapshot) {
              final videoUser = snapshot.data;
              return ListTile(
                leading: Container(
                  width: 60.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      color: FlutterFlowTheme.of(context).alternate,
                      child: Center(
                        child: Icon(
                          Icons.play_circle_outline,
                          color: FlutterFlowTheme.of(context).primary,
                          size: 28.0,
                        ),
                      ),
                    ),
                  ),
                ),
                title: Text(
                  video.videoDescription.isNotEmpty
                      ? video.videoDescription
                      : 'No description',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: FlutterFlowTheme.of(context).bodyMedium,
                ),
                subtitle: Text(
                  videoUser?.displayName ?? 'User',
                  style: FlutterFlowTheme.of(context).bodySmall,
                ),
                onTap: () {
                  context.pushNamed(
                    SingleVideoWidget.routeName,
                    queryParameters: {
                      'videoRef': serializeParam(
                        video.reference,
                        ParamType.DocumentReference,
                      ),
                    }.withoutNulls,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
