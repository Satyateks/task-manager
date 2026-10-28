import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/task_model.dart';

class TaskRepository {
  final ApiClient apiClient;

  TaskRepository({required this.apiClient});

  Future<List<TaskModel>> getTasks({
    String? status,
    String? search,
    int page = 1,
  }) async {
    final response = await apiClient.dio.get(
      ApiConstants.tasks,
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    final List<dynamic> taskList = response.data['tasks'];

    return taskList
        .map((json) => TaskModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<TaskModel> getTaskById(int id) async {
    final response = await apiClient.dio.get('${ApiConstants.tasks}/$id');
    return TaskModel.fromJson(response.data['task']);
  }

  Future<TaskModel> createTask({
    required String title,
    String? description,
    String? status,
    int? assigneeId,
    String? dueDate,
  }) async {
    final response = await apiClient.dio.post(
      ApiConstants.tasks,
      data: {
        'title': title,
        'description': description,
        'status': status ?? 'Todo',
        'assignee_id': assigneeId,
        'due_date': dueDate,
      },
    );

    return TaskModel.fromJson(response.data['task']);
  }

  Future<TaskModel> updateTask({
    required int id,
    String? title,
    String? description,
    String? status,
    int? assigneeId,
    String? dueDate,
  }) async {
    final response = await apiClient.dio.put(
      '${ApiConstants.tasks}/$id',
      data: {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (status != null) 'status': status,
        if (assigneeId != null) 'assignee_id': assigneeId,
        if (dueDate != null) 'due_date': dueDate,
      },
    );

    return TaskModel.fromJson(response.data['task']);
  }

  Future<void> deleteTask(int id) async {
    await apiClient.dio.delete('${ApiConstants.tasks}/$id');
  }
}
