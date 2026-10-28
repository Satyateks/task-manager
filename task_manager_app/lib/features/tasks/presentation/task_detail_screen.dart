import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/task_model.dart';
import 'bloc/task_cubit.dart';
import 'task_form_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}
class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late String _status;

  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _status = widget.task.status;
    // _assigneeId = widget.task.assigneeId;
  }

  Future<void> _updateStatus(String status) async {
    if (status == _status) return;

    setState(() => _isUpdating = true);

    try {
      final repository = context.read<TaskCubit>().taskRepository;

      final updatedTask = await repository.updateTask(
        id: widget.task.id,
        status: status,
      );

      if (!mounted) return;

      setState(() {
        _status = updatedTask.status;
      });

      await context.read<TaskCubit>().loadTasks();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status updated successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $error'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Future<void> _deleteTask() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      await context.read<TaskCubit>().deleteTask(widget.task.id);

      if (!mounted) return;
      Navigator.of(context).pop(true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task deleted successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete task: $error'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _editTask() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TaskFormScreen(task: widget.task)),
    );

    if (result == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            onPressed: _editTask,
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
          ),
          IconButton(
            onPressed: _deleteTask,
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Delete',
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Title & Status Segmented Bar
              Text(
                widget.task.title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Modern Segmented Button for Status
              Text(
                'Status',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'Todo',
                      label: Text('Todo'),
                      icon: Icon(Icons.radio_button_unchecked, size: 16),
                    ),
                    ButtonSegment(
                      value: 'In Progress',
                      label: Text('In Progress'),
                      icon: Icon(Icons.timelapse, size: 16),
                    ),
                    ButtonSegment(
                      value: 'Done',
                      label: Text('Done'),
                      icon: Icon(Icons.check_circle_outline, size: 16),
                    ),
                  ],
                  selected: {_status},
                  onSelectionChanged: _isUpdating
                      ? null
                      : (newSelection) {
                          _updateStatus(newSelection.first);
                        },
                ),
              ),

              const SizedBox(height: 24),

              // Description Card
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.task.description?.isNotEmpty == true
                            ? widget.task.description!
                            : 'No description provided.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: widget.task.description?.isNotEmpty == true
                              ? theme.colorScheme.onSurface
                              : theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Metadata Information Card
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        context,
                        icon: Icons.person_outline,
                        title: 'Assignee',
                        value: widget.task.assigneeName ?? 'Unassigned',
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        context,
                        icon: Icons.email_outlined,
                        title: 'Email',
                        value: widget.task.assigneeEmail ?? 'No email',
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        context,
                        icon: Icons.calendar_today_outlined,
                        title: 'Due Date',
                        value: widget.task.dueDate ?? 'No due date',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Action Buttons
              FilledButton.icon(
                onPressed: _editTask,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Task'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.redAccent),
                ),
                onPressed: _deleteTask,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete Task'),
              ),
            ],
          ),
          if (_isUpdating)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}