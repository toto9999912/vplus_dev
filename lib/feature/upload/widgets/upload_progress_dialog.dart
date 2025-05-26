// lib/feature/upload/widgets/upload_progress_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/upload_progress_provider.dart';
import '../models/upload_state.dart';

class UploadProgressDialog extends ConsumerWidget {
  const UploadProgressDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(context: context, barrierDismissible: false, builder: (context) => const UploadProgressDialog());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadState = ref.watch(uploadProgressProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: uploadState.when(
            idle: () => const SizedBox.shrink(),
            uploading:
                (progress, fileName, currentIndex, totalFiles) =>
                    _UploadingContent(progress: progress, fileName: fileName, currentIndex: currentIndex, totalFiles: totalFiles),
            success:
                (successCount, totalCount) =>
                    _SuccessContent(successCount: successCount, totalCount: totalCount, onClose: () => Navigator.of(context).pop()),
            error:
                (message, fileName) => _ErrorContent(
                  message: message,
                  fileName: fileName,
                  onRetry: () {
                    ref.read(uploadProgressProvider.notifier).reset();
                    Navigator.of(context).pop();
                  },
                  onClose: () => Navigator.of(context).pop(),
                ),
          ),
        ),
      ),
    );
  }
}

class _UploadingContent extends StatelessWidget {
  final double progress;
  final String fileName;
  final int currentIndex;
  final int totalFiles;

  const _UploadingContent({required this.progress, required this.fileName, required this.currentIndex, required this.totalFiles});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 圓形進度指示器
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
              ),
            ),
            Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 24),

        // 檔案資訊
        Text('正在上傳 ($currentIndex/$totalFiles)', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        const SizedBox(height: 8),
        Text(
          fileName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _SuccessContent extends StatelessWidget {
  final int successCount;
  final int totalCount;
  final VoidCallback onClose;

  const _SuccessContent({required this.successCount, required this.totalCount, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final bool hasFailures = successCount < totalCount;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 成功圖標
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(color: hasFailures ? Colors.orange : Colors.green, shape: BoxShape.circle),
          child: Icon(hasFailures ? Icons.warning_rounded : Icons.check_rounded, color: Colors.white, size: 48),
        ),
        const SizedBox(height: 24),

        // 結果文字
        Text(hasFailures ? '部分上傳完成' : '上傳成功', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('成功上傳 $successCount/$totalCount 個檔案', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        const SizedBox(height: 24),

        // 關閉按鈕
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: onClose, child: const Text('完成'))),
      ],
    );
  }
}

class _ErrorContent extends StatelessWidget {
  final String message;
  final String? fileName;
  final VoidCallback onRetry;
  final VoidCallback onClose;

  const _ErrorContent({required this.message, this.fileName, required this.onRetry, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 錯誤圖標
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
          child: const Icon(Icons.close_rounded, color: Colors.white, size: 48),
        ),
        const SizedBox(height: 24),

        // 錯誤訊息
        const Text('上傳失敗', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (fileName != null) ...[
          Text(
            fileName!,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
        ],
        Text(
          message,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 24),

        // 操作按鈕
        Row(
          children: [
            Expanded(child: OutlinedButton(onPressed: onClose, child: const Text('關閉'))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(onPressed: onRetry, child: const Text('重試'))),
          ],
        ),
      ],
    );
  }
}
