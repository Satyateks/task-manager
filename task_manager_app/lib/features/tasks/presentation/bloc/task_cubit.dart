import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/task_repository.dart';
import '../../models/task_model.dart';
import 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final TaskRepository taskRepository;
  int _currentPage = 1;

  TaskCubit({required this.taskRepository}) : super(const TaskState());

  Future<void> loadTasks() async {
    _currentPage = 1;
    emit(state.copyWith(status: TaskStatus.loading, isOffline: false));

    try {
      final tasks = await taskRepository.getTasks(
        status: state.selectedStatus,
        search: state.search,
        page: _currentPage,
      );

      emit(
        state.copyWith(
          status: TaskStatus.success,
          tasks: tasks,
          errorMessage: null,
          hasMore: tasks.isNotEmpty,
          isOffline: false,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: TaskStatus.error,
          errorMessage: _getErrorMessage(error),
          isOffline: true,
        ),
      );
    }
  }

  Future<void> loadMoreTasks() async {
    if (state.status == TaskStatus.loading || !state.hasMore) return;

    try {
      _currentPage++;
      final moreTasks = await taskRepository.getTasks(
        status: state.selectedStatus,
        search: state.search,
        page: _currentPage,
      );

      if (moreTasks.isEmpty) {
        emit(state.copyWith(hasMore: false));
      } else {
        emit(
          state.copyWith(
            tasks: [...state.tasks, ...moreTasks],
            hasMore: moreTasks.length >= 10,
          ),
        );
      }
    } catch (error) {
      _currentPage--;
    }
  }

  Future<void> filterByStatus(String? status) async {
    emit(state.copyWith(selectedStatus: status == 'All' ? null : status));
    await loadTasks();
  }

  Future<void> searchTasks(String search) async {
    emit(state.copyWith(search: search));

    await loadTasks();
  }

  Future<void> deleteTask(int id) async {
    try {
      await taskRepository.deleteTask(id);

      final updatedTasks = state.tasks.where((task) => task.id != id).toList();

      emit(
        state.copyWith(
          status: TaskStatus.success,
          tasks: updatedTasks,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: TaskStatus.error,
          errorMessage: _getErrorMessage(error),
        ),
      );
    }
  }

  void sortTasks(String sortBy) {
    List<TaskModel> sortedList = List.from(state.tasks);

    switch (sortBy) {
      case 'dueDate':
        sortedList.sort((a, b) => (a.dueDate ?? '').compareTo(b.dueDate ?? ''));
        break;
      case 'title':
        sortedList.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'created':
      default:
        break;
    }

    emit(state.copyWith(tasks: sortedList));
  }

  String _getErrorMessage(dynamic error) {
    return error.toString();
  }
}
