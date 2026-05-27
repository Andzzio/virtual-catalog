class UserEntity {
  final String id;
  final String email;
  final String name;
  final String role;
  final String businessId;
  final DateTime createdAt;

  UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.businessId,
    required this.createdAt,
  });
}
