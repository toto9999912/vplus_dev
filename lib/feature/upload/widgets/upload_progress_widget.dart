// lib/feature/upload/presentation/widgets/upload_progress_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/upload_progress_provider.dart';

class UploadProgressWidget extends ConsumerWidget {
  final VoidCallback? onClose;

  const UploadProgressWidget({super.key, this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressState = ref.watch(uploadProgressNotifierProvider);

    // 如果沒有上傳，不顯示任何內容
    if (progressState.totalFiles == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 0, blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('媒體上傳', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              // 如果所有文件都已處理完畢，顯示關閉按鈕
              if (progressState.isAllCompleted && onClose != null)
                IconButton(icon: const Icon(Icons.close), onPressed: onClose, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progressState.overallProgress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(progressState.failedFiles > 0 ? Colors.orange : Colors.blue),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusItem('進度', '${(progressState.overallProgress * 100).toInt()}%', Icons.percent, Colors.blue),
              _buildStatusItem('完成', '${progressState.completedFiles}/${progressState.totalFiles}', Icons.check_circle_outline, Colors.green),
              if (progressState.failedFiles > 0) _buildStatusItem('失敗', '${progressState.failedFiles}', Icons.error_outline, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text('$label: $value', style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
