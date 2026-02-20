class QueueModel {
  final String id;
  final String actionType;
  final String payload;
  final String idempotencyKey;
  final int retryCount;
  final String status;
  final int createdAt;

  QueueModel({
    required this.id,
    required this.actionType,
    required this.payload,
    required this.idempotencyKey,
    required this.retryCount,
    required this.status,
    required this.createdAt,
  });
}
