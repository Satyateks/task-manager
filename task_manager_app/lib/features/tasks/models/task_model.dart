class TaskModel {
  final int id;
  final String title;
  final String? description;
  final String status;
  final int? assigneeId;
  final String? assigneeName;
  final String? assigneeEmail;
  final String? dueDate;
  final int? createdBy;
  final String? createdAt;
  final String? updatedAt;
  final bool isOffline;
  final bool hasMore;

  const TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    this.assigneeId,
    this.assigneeName,
    this.assigneeEmail,
    this.dueDate,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.isOffline = false, 
    this.hasMore = true,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      assigneeId: json['assignee_id'] as int?,
      assigneeName: json['assignee_name'] as String?,
      assigneeEmail: json['assignee_email'] as String?,
      dueDate: json['due_date'] as String?,
      createdBy: json['created_by'] as int?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}
