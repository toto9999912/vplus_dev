import 'package:auto_route/auto_route.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vplus_dev/core/constants/app_color.dart';
import 'package:vplus_dev/core/router/app_router.gr.dart';
import 'package:vplus_dev/feature/project/domain/entities/project.dart';
import 'package:vplus_dev/feature/project/domain/enums/project_status.dart';
import 'package:vplus_dev/feature/project/presentation/providers/project_providers.dart';
import 'package:vplus_dev/feature/project/presentation/widgets/empty_projects_view.dart';

@RoutePage()
class ProjectPage extends StatelessWidget {
  const ProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AutoRouter();
  }
}

@RoutePage()
class ProjectListPage extends ConsumerWidget {
  const ProjectListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedProjectsAsync = ref.watch(groupedProjectsProvider());

    return Scaffold(
      body: groupedProjectsAsync.when(
        data: (groupedProjects) {
          // 檢查是否所有分組都為空
          final bool isEmpty = groupedProjects.isEmpty;

          if (isEmpty) {
            return EmptyProjectsView(
              onAddPressed: () => _showAddProjectDialog(context, ref),
            );
          }
          return _buildProjectListView(context, groupedProjects);
        },
        error: (error, stackTrace) => Center(child: Text('發生錯誤: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProjectDialog(context, ref),
        tooltip: '新增專案',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProjectListView(BuildContext context, Map<ProjectStatus, List<Project>> groupedProjects) {
    // 準備拖放列表
    final lists = <DragAndDropList>[];

    groupedProjects.forEach((status, projects) {
      lists.add(_buildProjectSection(context, status, projects));
    });

    return DragAndDropLists(
      children: lists,
      onItemReorder: _onItemReorder,
      onListReorder: _onListReorder,
      listInnerDecoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      lastItemTargetHeight: 8,
      addLastItemTargetHeightToTop: true,
      lastListTargetSize: 40,
    );
  }

  DragAndDropList _buildProjectSection(BuildContext context, ProjectStatus status, List<Project> projects) {
    return DragAndDropList(
      header: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Text(status.displayName, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
              child: Text('${projects.length}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey.shade700)),
            ),
          ],
        ),
      ),
      children:
          projects.asMap().entries.map((entry) {
            final index = entry.key;
            final project = entry.value;
            return _buildProjectItem(context, project, index);
          }).toList(),
      canDrag: false,
    );
  }

  DragAndDropItem _buildProjectItem(BuildContext context, Project project, int index) {
    return DragAndDropItem(
      child: InkWell(
        onTap: () {
          // 導航到 ProjectDashboardPage，傳入專案 ID
          context.pushRoute(ProjectDashboardRoute(projectId: project.id));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.grey07))),
          child: Row(
            children: [
              // 顯示索引
              Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(right: 12),

                alignment: Alignment.center,
                child: Text('${index + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
              ),
              // 專案名稱
              Expanded(child: Text(project.projectName)),
            ],
          ),
        ),
      ),
    );
  }

  void _onItemReorder(int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    // 處理項目重新排序邏輯
    debugPrint('Item 從 ($oldListIndex, $oldItemIndex) 移動到 ($newListIndex, $newItemIndex)');
    
    // TODO: 實作實際的重新排序 API 呼叫
    // 這裡應該呼叫後端 API 來持久化新的排序
    // 暫時只記錄日誌，實際實作需要根據後端 API 規格
  }

  void _onListReorder(int oldListIndex, int newListIndex) {
    // 處理列表重新排序邏輯
    debugPrint('List 從 $oldListIndex 移動到 $newListIndex');
    
    // TODO: 實作實際的列表重新排序 API 呼叫
    // 這裡應該呼叫後端 API 來持久化新的列表順序
    // 暫時只記錄日誌，實際實作需要根據後端 API 規格
  }

  /// 顯示新增專案對話框
  void _showAddProjectDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('新增專案'),
          content: const TextField(
            decoration: InputDecoration(
              labelText: '專案名稱',
              hintText: '請輸入專案名稱',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: 實作新增專案的邏輯
                // 1. 驗證輸入
                // 2. 呼叫 API 創建專案
                // 3. 更新 UI 狀態
                // 4. 關閉對話框
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('新增專案功能待實作')),
                );
              },
              child: const Text('新增'),
            ),
          ],
        );
      },
    );
  }
}
