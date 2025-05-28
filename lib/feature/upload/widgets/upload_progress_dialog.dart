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
          width: 300,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withAlpha(26), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: uploadState.when(
            idle: () => const _LoadingContent(),
            uploading:
                (overallProgress, totalBytes, uploadedBytes, currentFileName, currentFileIndex, totalFiles, completedFiles) => _UploadingContent(
                  overallProgress: overallProgress,
                  totalBytes: totalBytes,
                  uploadedBytes: uploadedBytes,
                  currentFileName: currentFileName,
                  currentFileIndex: currentFileIndex,
                  totalFiles: totalFiles,
                  completedFiles: completedFiles,
                ),
            success:
                (successCount, totalCount) => _SuccessContent(
                  successCount: successCount,
                  totalCount: totalCount,
                  onClose: () {
                    ref.read(uploadProgressProvider.notifier).reset();
                    Navigator.of(context).pop();
                  },
                ),
            error:
                (message, fileName) => _ErrorContent(
                  message: message,
                  fileName: fileName,
                  onRetry: () {
                    ref.read(uploadProgressProvider.notifier).reset();
                    Navigator.of(context).pop();
                  },
                  onClose: () {
                    ref.read(uploadProgressProvider.notifier).reset();
                    Navigator.of(context).pop();
                  },
                ),
          ),
        ),
      ),
    );
  }
}

class _LoadingContent extends StatelessWidget {
  const _LoadingContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            strokeWidth: 4,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
        ),
        const SizedBox(height: 20),
        const Text('準備上傳中...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
      ],
    );
  }
}

class _UploadingContent extends StatelessWidget {
  final double overallProgress;
  final int totalBytes;
  final int uploadedBytes;
  final String currentFileName;
  final int currentFileIndex;
  final int totalFiles;
  final int completedFiles;

  const _UploadingContent({
    required this.overallProgress,
    required this.totalBytes,
    required this.uploadedBytes,
    required this.currentFileName,
    required this.currentFileIndex,
    required this.totalFiles,
    required this.completedFiles,
  });

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 圓形進度指示器 - 顯示整體進度
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 90,
              height: 90,
              child: CircularProgressIndicator(
                value: overallProgress,
                strokeWidth: 8,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
              ),
            ),
            Text('${(overallProgress * 100).toInt()}%', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 20),

        // 整體進度資訊
        Text('${_formatBytes(uploadedBytes)} / ${_formatBytes(totalBytes)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),

        // 檔案進度資訊
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 16),
            const SizedBox(width: 4),
            Text('$completedFiles', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text(' / $totalFiles 個檔案', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 12),

        // 當前檔案資訊
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
          child: Column(
            children: [
              Text('正在上傳第 $currentFileIndex 個檔案', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(height: 4),
              Text(
                currentFileName,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
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
          width: 70,
          height: 70,
          decoration: BoxDecoration(color: hasFailures ? Colors.orange : Colors.green, shape: BoxShape.circle),
          child: Icon(hasFailures ? Icons.warning_rounded : Icons.check_rounded, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 20),

        // 結果文字
        Text(hasFailures ? '部分上傳完成' : '上傳成功', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('成功上傳 $successCount/$totalCount 個檔案', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        const SizedBox(height: 20),

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
          width: 70,
          height: 70,
          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
          child: const Icon(Icons.close_rounded, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 20),

        // 錯誤訊息
        const Text('上傳失敗', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
        const SizedBox(height: 20),

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
