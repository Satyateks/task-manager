import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../team/presentation/team_members_screen.dart';
import '../models/task_model.dart';
import 'bloc/task_cubit.dart';
import 'bloc/task_state.dart';
import 'task_detail_screen.dart';
import 'task_form_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    context.read<TaskCubit>().loadTasks();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) context.read<TaskCubit>().loadMoreTasks();
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll - 200);
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      context.read<TaskCubit>().searchTasks(value.trim());
    });
  }

  void _clearSearch() {
    _searchTimer?.cancel();
    _searchController.clear();
    context.read<TaskCubit>().searchTasks('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7F8FA),
        surfaceTintColor: Colors.transparent,
        titleSpacing: 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Tasks',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Stay organized and get things done',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          // Sorting Popup Menu Button
          BlocBuilder<TaskCubit, TaskState>(
            builder: (context, state) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.sort_rounded),
                tooltip: 'Sort tasks',
                onSelected: (sortBy) {
                  context.read<TaskCubit>().sortTasks(sortBy);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'dueDate',
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Sort by Due Date'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'title',
                    child: Row(
                      children: [
                        Icon(Icons.sort_by_alpha_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Sort by Title'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'created',
                    child: Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Sort by Created Date'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {context.read<TaskCubit>().loadTasks();},
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TeamMembersScreen()),
              );
            },
            icon: const Icon(Icons.telegram),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<TaskCubit, TaskState>(
        listener: (context, state) {
          if (state.status == TaskStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                content: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(state.errorMessage ?? 'Something went wrong'),
                    ),
                  ],
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Offline Status Banner Handler
              if (state.isOffline)
                Container(
                  width: double.infinity,
                  color: Colors.amber.shade800,
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.cloud_off_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'You are offline. Showing cached tasks.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              _buildSearchBar(),
              const SizedBox(height: 12),
              _buildStatusFilter(state),
              const SizedBox(height: 8),
              Expanded(child: _buildTaskContent(state)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        elevation: 3,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        onPressed: () async {
          await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const TaskFormScreen()));
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'New Task',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search tasks...',
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF6B7280),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  tooltip: 'Clear',
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.close_rounded, size: 20),
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilter(TaskState state) {
    const statuses = ['All', 'Todo', 'In Progress', 'Done'];

    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: statuses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final status = statuses[index];
          final isSelected = status == 'All' ? state.selectedStatus == null : state.selectedStatus == status;

          return FilterChip(
            label: Text(status),
            selected: isSelected,
            showCheckmark: false,
            selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
            backgroundColor: Colors.white,
            side: BorderSide(color: isSelected ? Theme.of(context).colorScheme.primary : const Color(0xFFE5E7EB)),
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Theme.of(context).colorScheme.primary : const Color(0xFF4B5563),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            onSelected: (_) {final filterValue = status == 'All aaaliyah_rajput' ? null : status;
              context.read<TaskCubit>().filterByStatus(filterValue);
              context.read<TaskCubit>().filterByStatus(status);
            },
          );
        },
      ),
    );
  }

  Widget _buildTaskContent(TaskState state) {
    if (state.status == TaskStatus.loading && state.tasks.isEmpty) return const Center(child: CircularProgressIndicator.adaptive());
    if (state.tasks.isEmpty) return _buildEmptyState();
    return RefreshIndicator(
      onRefresh: () {
        return context.read<TaskCubit>().loadTasks();
      },
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        itemCount: state.tasks.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.tasks.length) {
            // Pagination Loader Indicator at the bottom
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          return _buildTaskCard(state.tasks[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasSearch = _searchController.text.trim().isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasSearch ? Icons.search_off_rounded : Icons.task_alt_rounded,
                size: 42,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              hasSearch ? 'No matching tasks' : 'No tasks yet',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasSearch
                  ? 'Try a different keyword or clear your search.'
                  : 'Create your first task and start getting things done.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                height: 1.5,
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            if (!hasSearch) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () async {await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TaskFormScreen()));},
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create Task'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(TaskModel task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
            );

            if (mounted) {
              context.read<TaskCubit>().loadTasks();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _statusBadge(task.status),
                  ],
                ),
                if (task.description != null &&
                    task.description!.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    task.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFF0F1F3)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (task.assigneeName != null) ...[
                      _buildAssignee(task.assigneeName!),
                      const SizedBox(width: 14),
                    ],
                    if (task.dueDate != null)
                      Expanded(child: _buildDueDate(task.dueDate!)),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF9CA3AF),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAssignee(String name) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 15,
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.1),
          child: Text(
            initial,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 7),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 120),
          child: Text(
            name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4B5563),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDueDate(String date) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.calendar_today_outlined,
          size: 15,
          color: Color(0xFF6B7280),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            date,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(String status) {
    late Color color;
    late IconData icon;

    switch (status) {
      case 'Done':
        color = const Color(0xFF16A34A);
        icon = Icons.check_circle_outline_rounded;
        break;

      case 'In Progress':
        color = const Color(0xFFF59E0B);
        icon = Icons.timelapse_rounded;
        break;

      default:
        color = const Color(0xFF3B82F6);
        icon = Icons.radio_button_unchecked_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}




