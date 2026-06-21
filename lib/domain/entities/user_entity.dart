class UserEntity {
  final String id;
  final String email;
  final String name;
  final List<String> roles;
  final bool isOwner;
  final String businessId;
  final DateTime createdAt;

  UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.roles,
    required this.isOwner,
    required this.businessId,
    required this.createdAt,
  });
}
