import '../../models/task_model.dart';

enum TaskStatus { initial, loading, success, error }

class TaskState {
  final TaskStatus status;
  final List<TaskModel> tasks;
  final String? errorMessage;
  final String? selectedStatus;
  final String search;
  final bool isOffline;
  final bool hasMore;

  const TaskState({
    this.status = TaskStatus.initial,
    this.tasks = const [],
    this.errorMessage,
    this.selectedStatus,
    this.search = '',
    this.isOffline = false,
    this.hasMore = true,
  });

  TaskState copyWith({
    TaskStatus? status,
    List<TaskModel>? tasks,
    String? errorMessage,
    String? selectedStatus,
    String? search,
    bool? isOffline,
    bool? hasMore,
  }) {
    return TaskState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      errorMessage: errorMessage,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      search: search ?? this.search,
      isOffline: isOffline ?? this.isOffline,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}