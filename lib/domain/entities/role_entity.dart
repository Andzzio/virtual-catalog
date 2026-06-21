class RoleEntity {
  final String id;
  final String businessId;
  final String name;
  final int colorValue;
  final int position;
  final List<String> permissions;

  RoleEntity({
    required this.id,
    required this.businessId,
    required this.name,
    required this.colorValue,
    required this.position,
    required this.permissions,
  });
}
