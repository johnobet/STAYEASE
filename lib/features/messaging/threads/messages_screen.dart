import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/media/safe_network_image.dart';
import '../chat/chat_screen.dart';
import '../data/messaging_repository.dart';
import '../models/message_models.dart';

/// Thread list — used as the Messages tab on both Tenant and Owner
/// shells. Same widget, same data shape; the only difference between
/// the two roles is which uid is passed in as [currentUserId].
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key, required this.currentUserId});
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final repo = MessagingRepository();
    return SafeArea(
      bottom: false,
      child: StreamBuilder<List<ChatThread>>(
        stream: repo.watchThreads(currentUserId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 32, color: AppColors.danger),
                    const SizedBox(height: AppSpacing.m),
                    Text('Could not load conversations.', style: AppTypography.bodyM.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('${snap.error}', style: AppTypography.bodyS, textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }
          final threads = snap.data ?? const [];
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.l),
            children: [
              Text('Messages', style: AppTypography.displayL.copyWith(fontSize: 26)),
              const SizedBox(height: AppSpacing.xl),
              if (threads.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                  child: Column(
                    children: [
                      const Icon(Icons.chat_bubble_outline_rounded, size: 40, color: AppColors.textTertiary),
                      const SizedBox(height: AppSpacing.m),
                      Text('No conversations yet.', style: AppTypography.bodyM.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('Message an owner from a property page to start.', style: AppTypography.bodyS, textAlign: TextAlign.center),
                    ],
                  ),
                )
              else
                ...threads.map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.m),
                      child: _ThreadCard(thread: t, currentUserId: currentUserId),
                    )),
            ],
          );
        },
      ),
    );
  }
}

class _ThreadCard extends StatelessWidget {
  const _ThreadCard({required this.thread, required this.currentUserId});
  final ChatThread thread;
  final String currentUserId;

  String get _preview {
    if (thread.lastMessageText.isEmpty) return 'No messages yet';
    final prefix = thread.lastSenderId == currentUserId ? 'You: ' : '';
    return '$prefix${thread.lastMessageText}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            threadId: thread.id,
            currentUserId: currentUserId,
            title: '${thread.otherPartyLabel(currentUserId)} · ${thread.propertyName}',
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: AppShadows.card),
        child: Row(
          children: [
            SafeNetworkImage(
              url: thread.propertyImageUrl,
              width: 48,
              height: 48,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(thread.otherPartyLabel(currentUserId), style: AppTypography.bodyM.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(width: 6),
                      Text('· ${thread.propertyName}', style: AppTypography.bodyS, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(_preview, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.bodyS),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
