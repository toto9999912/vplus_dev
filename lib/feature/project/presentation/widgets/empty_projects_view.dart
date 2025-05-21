import 'package:flutter/material.dart';

class EmptyProjectsView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onAddPressed;

  const EmptyProjectsView({super.key, this.title = '沒有專案', this.message = '目前沒有專案可以顯示', this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_off_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ),
          if (onAddPressed != null) ...[
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('新增專案'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
              onPressed: onAddPressed,
            ),
          ],
        ],
      ),
    );
  }
}
