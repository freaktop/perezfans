import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/payments/promotion_paywall.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/video_upload_flow.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central place for upload, live, promote, payouts, vault, and messages.
class CreatorHubWidget extends StatelessWidget {
  const CreatorHubWidget({super.key});

  static String routeName = 'CreatorHub';
  static String routePath = 'creatorHub';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        title: Text(
          'Creator tools',
          style: FlutterFlowTheme.of(context).titleMedium.override(
                font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          Text(
            'Create & go live',
            style: FlutterFlowTheme.of(context).labelLarge.override(
                  font: GoogleFonts.poppins(),
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
          ),
          const SizedBox(height: 8.0),
          ListTile(
            leading: const Icon(Icons.upload_rounded),
            title: const Text('Upload a video'),
            subtitle: const Text('Post to your profile and feeds'),
            onTap: () => pickUploadVideoAndOpenNewPost(context),
          ),
          ListTile(
            leading: const Icon(Icons.live_tv_rounded),
            title: const Text('Go live'),
            subtitle: const Text('Start a live stream'),
            onTap: () => context.pushNamed(LiveWidget.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.person_rounded),
            title: const Text('Your profile & vault'),
            subtitle: const Text('Vault tab for custom / locked clips'),
            onTap: () => context.pushNamed(ProfileWidget.routeName),
          ),
          const Divider(height: 32.0),
          Text(
            'Grow & earn',
            style: FlutterFlowTheme.of(context).labelLarge.override(
                  font: GoogleFonts.poppins(),
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
          ),
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
            child: Row(
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  size: 22.0,
                  color: FlutterFlowTheme.of(context).primary,
                ),
                const SizedBox(width: 8.0),
                Text(
                  'Promote a video',
                  style: FlutterFlowTheme.of(context).titleSmall.override(
                        font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                ),
              ],
            ),
          ),
          _PromoteVideoPicker(),
          ListTile(
            leading: const Icon(Icons.payments_outlined),
            title: const Text('Stripe payouts'),
            subtitle: const Text('Connect your seller account'),
            onTap: () => context.pushNamed(EditProfileWidget.routeName),
          ),
          const Divider(height: 32.0),
          Text(
            'Engage',
            style: FlutterFlowTheme.of(context).labelLarge.override(
                  font: GoogleFonts.poppins(),
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
          ),
          const SizedBox(height: 8.0),
          ListTile(
            leading: const Icon(Icons.chat_bubble_outline_rounded),
            title: const Text('Messages'),
            subtitle: const Text('Chats with fans'),
            onTap: () => context.pushNamed(ChatListWidget.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.home_rounded),
            title: const Text('Home feed'),
            subtitle: const Text('Back to For You'),
            onTap: () => context.goNamed(HomeWidget.routeName),
          ),
        ],
      ),
    );
  }
}

class _PromoteVideoPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ref = currentUserReference;
    if (ref == null) return const SizedBox.shrink();

    return StreamBuilder<List<VideosRecord>>(
      stream: queryVideosRecord(
        queryBuilder: (q) => q
            .where('video_user', isEqualTo: ref)
            .orderBy('video_posted_time', descending: true)
            .limit(8),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
            child: Text(
              'Post a video first, then promote it from here.',
              style: FlutterFlowTheme.of(context).bodySmall,
            ),
          );
        }
        final list = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: list.map((v) {
            final preview = v.videoDescription.isNotEmpty
                ? v.videoDescription
                : 'Video · ${dateTimeFormat('relative', v.videoPostedTime)}';
            return ListTile(
              dense: true,
              title: Text(
                preview,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(fontSize: 14.0),
              ),
              subtitle: Text(
                promotionStatusLabel(v.promotionStatus),
                style: GoogleFonts.poppins(
                  fontSize: 12.0,
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
              ),
              trailing: TextButton(
                onPressed: () async {
                  try {
                    await startPromotionCheckout(videoId: v.reference.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Opening Stripe checkout…'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$e')),
                      );
                    }
                  }
                },
                child: const Text('Promote'),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
