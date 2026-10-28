import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/task_model.dart';
import 'bloc/task_cubit.dart';

class TaskFormScreen extends StatefulWidget {
  final TaskModel? task;

  const TaskFormScreen({
    super.key,
    this.task,
  });

  bool get isEdit => task != null;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  String _status = 'Todo';
  int? _assigneeId;
  DateTime? _dueDate;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');

    _status = widget.task?.status ?? 'Todo';
    _assigneeId = widget.task?.assigneeId;

    if (widget.task?.dueDate != null) {
      _dueDate = DateTime.tryParse(widget.task!.dueDate!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (selectedDate != null) {
      setState(() {
        _dueDate = selectedDate;
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final repository = context.read<TaskCubit>().taskRepository;

      if (widget.isEdit) {
        await repository.updateTask(
          id: widget.task!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          status: _status,
          assigneeId: _assigneeId,
          dueDate: _dueDate?.toIso8601String(),
        );
      } else {
        await repository.createTask(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          status: _status,
          assigneeId: _assigneeId,
          dueDate: _dueDate?.toIso8601String(),
        );
      }

      if (!mounted) return;
      await context.read<TaskCubit>().loadTasks();

      if (!mounted) return;
      Navigator.of(context).pop(true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEdit ? 'Task updated successfully' : 'Task created successfully',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save task: $error'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Task' : 'Create Task'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Section 1: Core Information
              Text(
                'Task Details',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  hintText: 'What needs to be done?',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  if (value.trim().length < 3) {
                    return 'Title must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Add any extra details or notes...',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.description_outlined),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Section 2: Task Properties & Status
              Text(
                'Properties',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Status Segmented Button
              Text(
                'Status',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
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
                  onSelectionChanged: (newSelection) {
                    setState(() => _status = newSelection.first);
                  },
                ),
              ),

              const SizedBox(height: 18),

              DropdownButtonFormField<int?>(
                value: _assigneeId,
                decoration: const InputDecoration(
                  labelText: 'Assignee',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Unassigned'),
                  ),
                ],
                onChanged: (value) => setState(() => _assigneeId = value),
              ),

              const SizedBox(height: 18),

              // Improved Due Date Picker Field with full-area ink ripple
              InkWell(
                onTap: _selectDueDate,
                borderRadius: BorderRadius.circular(4),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Due Date',
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                    border: const OutlineInputBorder(),
                    suffixIcon: _dueDate != null
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () => setState(() => _dueDate = null),
                            tooltip: 'Clear date',
                          )
                        : null,
                  ),
                  child: Text(
                    _dueDate == null
                        ? 'Select due date'
                        : '${_dueDate!.day.toString().padLeft(2, '0')}/'
                            '${_dueDate!.month.toString().padLeft(2, '0')}/'
                            '${_dueDate!.year}',
                    style: TextStyle(
                      color: _dueDate == null ? theme.hintColor : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // Action Button
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _saveTask,
                  icon: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(widget.isEdit ? Icons.save : Icons.add),
                  label: Text(
                    widget.isEdit ? 'Update Task' : 'Create Task',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}