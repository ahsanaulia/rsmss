class TaskModel {
  final String id;
  final String taskTypeName;
  final String iconName;
  final String objectName;
  final String fromRoomId; // Tambahkan ini
  final String fromRoom;
  final String toRoom;
  final String status;
  final String priority;
  final String createdBy;

  TaskModel({
    required this.id,
    required this.taskTypeName,
    required this.iconName,
    required this.objectName,
    required this.fromRoomId, // Tambahkan ini
    required this.fromRoom,
    required this.toRoom,
    required this.status,
    required this.priority,
    required this.createdBy,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final taskType = json['ref_task_types'] as Map<String, dynamic>?;
    final fromRoomData = json['from_room'] as Map<String, dynamic>?;
    final toRoomData = json['to_room'] as Map<String, dynamic>?;
    final creatorData = json['creator'] as Map<String, dynamic>?;

    return TaskModel(
      id: json['id'] ?? '',
      taskTypeName: taskType?['task_type_name'] ?? 'Tugas',
      iconName: taskType?['icon_name'] ?? 'assignment_outlined',
      objectName: json['object_name'] ?? '',
      fromRoomId: json['from_room_id'] ?? '', // Ambil ID-nya dari json
      fromRoom: fromRoomData?['room_name'] ?? '-',
      toRoom: toRoomData?['room_name'] ?? '-',
      status: json['status'] ?? 'pending',
      priority: json['priority'] ?? 'normal',
      createdBy: creatorData?['full_name'] ?? 'System',
    );
  }
}