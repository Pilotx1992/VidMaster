import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/encrypted_file_metadata.dart';
import '../providers/vault_provider.dart';

class VaultScreen extends ConsumerStatefulWidget {
  const VaultScreen({super.key});

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends ConsumerState<VaultScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vaultProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('Security Vault'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_moderator),
            tooltip: 'Add to Vault',
            onPressed: () => _showAddFileDialog(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildVaultHeader(state),
          Expanded(
            child: state.isLoading && state.items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.items.isEmpty
                    ? _buildEmptyState()
                    : _buildVaultList(state),
          ),
          if (state.operationProgress != null) _buildProgressOverlay(state),
        ],
      ),
    );
  }

  Widget _buildVaultHeader(VaultState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2B3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          const Icon(Icons.security, color: Color(0xFFF9A825), size: 40),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${state.items.length} Protected Files',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'AES-256-GCM Encrypted',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 80, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          const Text(
            'Your vault is empty',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddFileDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Add Private Files'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF9A825),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVaultList(VaultState state) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: state.items.length,
      itemBuilder: (context, index) {
        final item = state.items[index];
        return _VaultItemTile(item: item);
      },
    );
  }

  Widget _buildProgressOverlay(VaultState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.black54,
      child: Row(
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFF9A825)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Processing file...', style: TextStyle(color: Colors.white)),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: state.operationProgress,
                  color: const Color(0xFFF9A825),
                  backgroundColor: Colors.white10,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(state.operationProgress! * 100).toInt()}%',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddFileDialog(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      
      // Request PIN if not authenticated or session expired.
      // For this MVP, we assume the user just unlocked the vault to enter this screen.
      // In a real app, we'd prompt for PIN again or use the cached PIN if session is active.
      // We'll use a dialog to ask for the PIN as required by VaultRepository.
      
      if (!context.mounted) return;
      final pin = await _showPinDialog(context);
      if (pin != null) {
        if (!context.mounted) return;
        ref.read(vaultProvider.notifier).addToVault(path, pin);
      }
    }
  }

  Future<String?> _showPinDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C2B3A),
        title: const Text('Vault PIN', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          obscureText: true,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter your vault PIN',
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _VaultItemTile extends ConsumerWidget {
  final EncryptedFileMetadata item;

  const _VaultItemTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sizeStr = _formatSize(item.originalFileSizeBytes);
    final dateStr = DateFormat('MMM d, yyyy • HH:mm').format(item.encryptedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2B3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF0D1B2A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.movie_outlined, color: Colors.white38),
        ),
        title: Text(
          item.originalFileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '$sizeStr • $dateStr',
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white54),
          color: const Color(0xFF1C2B3A),
          onSelected: (value) => _handleAction(context, ref, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'restore',
              child: ListTile(
                leading: Icon(Icons.unarchive, color: Color(0xFFF9A825)),
                title: Text('Restore to Library', style: TextStyle(color: Colors.white)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete_forever, color: Colors.redAccent),
                title: Text('Delete Permanently', style: TextStyle(color: Colors.white)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, String action) async {
    if (action == 'restore') {
      final pin = await _showPinDialog(context);
      if (pin != null) {
        ref.read(vaultProvider.notifier).restoreFromVault(item, pin);
      }
    } else if (action == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1C2B3A),
          title: const Text('Delete Permanently?', style: TextStyle(color: Colors.white)),
          content: const Text(
            'This file will be completely destroyed and cannot be recovered. Are you sure?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirm == true) {
        ref.read(vaultProvider.notifier).deleteFromVault(item.id);
      }
    }
  }

  Future<String?> _showPinDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C2B3A),
        title: const Text('Enter PIN to Decrypt', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          obscureText: true,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Confirm vault PIN',
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Decrypt'),
          ),
        ],
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (math.log(bytes) / math.log(1024)).floor();
    return "${(bytes / math.pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}";
  }
}
// Wait, I should use dart:math
