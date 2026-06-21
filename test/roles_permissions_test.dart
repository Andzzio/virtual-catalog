import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_catalog_app/domain/entities/role_entity.dart';
import 'package:virtual_catalog_app/domain/entities/user_entity.dart';
import 'package:virtual_catalog_app/domain/repos/role_repository.dart';
import 'package:virtual_catalog_app/domain/repos/user_repository.dart';
import 'package:virtual_catalog_app/domain/usecases/create_role.dart';
import 'package:virtual_catalog_app/domain/usecases/delete_role.dart';
import 'package:virtual_catalog_app/domain/usecases/get_roles.dart';
import 'package:virtual_catalog_app/domain/usecases/update_role.dart';
import 'package:virtual_catalog_app/domain/usecases/update_role_positions.dart';
import 'package:virtual_catalog_app/domain/usecases/create_user.dart';
import 'package:virtual_catalog_app/domain/usecases/delete_user.dart';
import 'package:virtual_catalog_app/domain/usecases/get_users.dart';
import 'package:virtual_catalog_app/domain/usecases/update_user_role.dart';
import 'package:virtual_catalog_app/presentation/providers/roles_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/users_provider.dart';

// ---------------------------------------------------------------------------
// HELPERS DE PERMISOS — replica la lógica de negocio del sistema de roles
// ---------------------------------------------------------------------------

class PermissionChecker {
  final List<String> activePermissions;

  PermissionChecker(this.activePermissions);

  bool get isAdministrator => activePermissions.contains('administrator');

  bool get canViewCatalog =>
      isAdministrator || activePermissions.contains('catalog:view');

  bool get canManageCatalog =>
      isAdministrator || activePermissions.contains('catalog:manage');

  bool get canViewAllChats =>
      isAdministrator || activePermissions.contains('chats:view_all');

  bool get canViewAssignedChats =>
      isAdministrator ||
      activePermissions.contains('chats:view_assigned') ||
      activePermissions.contains('chats:view_all');

  bool get canRespondChats =>
      isAdministrator || activePermissions.contains('chats:respond');

  bool get canAssignChats =>
      isAdministrator || activePermissions.contains('chats:assign');

  bool get canManageUsers =>
      isAdministrator || activePermissions.contains('users:manage');

  bool get canManageRoles =>
      isAdministrator || activePermissions.contains('roles:manage');

  bool get canManageSettings =>
      isAdministrator || activePermissions.contains('settings:manage');

  bool get canViewAnalytics =>
      isAdministrator || activePermissions.contains('analytics:view');
}

List<String> applyPermissionDependencies(
    List<String> current, String added) {
  final result = List<String>.from(current);
  if (!result.contains(added)) result.add(added);

  if (added == 'catalog:manage' && !result.contains('catalog:view')) {
    result.add('catalog:view');
  }

  if (added == 'chats:respond' && !result.contains('chats:view_assigned')) {
    result.add('chats:view_assigned');
  }

  if (added == 'chats:assign' && !result.contains('chats:view_assigned')) {
    result.add('chats:view_assigned');
  }

  return result;
}

// ---------------------------------------------------------------------------
// MOCKS
// ---------------------------------------------------------------------------

class MockRoleRepository implements RoleRepository {
  List<RoleEntity> _roles = [];
  bool createCalled = false;
  bool updateCalled = false;
  bool deleteCalled = false;
  bool updatePositionsCalled = false;
  bool throwOnCreate = false;
  bool throwOnDelete = false;

  @override
  Future<List<RoleEntity>> getRoles(String businessSlug) async => _roles;

  @override
  Future<void> createRole(String businessSlug, RoleEntity role) async {
    if (throwOnCreate) throw Exception('Error simulado al crear rol');
    createCalled = true;
    _roles.add(role);
  }

  @override
  Future<void> updateRole(String businessSlug, RoleEntity role) async {
    updateCalled = true;
    final idx = _roles.indexWhere((r) => r.id == role.id);
    if (idx != -1) _roles[idx] = role;
  }

  @override
  Future<void> updateRolePositions(
      String businessSlug, List<Map<String, dynamic>> positions) async {
    updatePositionsCalled = true;
  }

  @override
  Future<void> deleteRole(String businessSlug, String roleId) async {
    if (throwOnDelete) throw Exception('Error simulado al eliminar rol');
    deleteCalled = true;
    _roles.removeWhere((r) => r.id == roleId);
  }
}

class MockUserRepository implements UserRepository {
  List<UserEntity> _users = [];
  bool createCalled = false;
  bool deleteCalled = false;
  bool updateRolesCalled = false;
  bool throwOnCreate = false;

  @override
  Future<List<UserEntity>> getUsers(String businessSlug) async => _users;

  @override
  Future<void> createUser({
    required String businessSlug,
    required String name,
    required String email,
    required String password,
    required List<String> roles,
  }) async {
    if (throwOnCreate) throw Exception('Error al crear usuario');
    createCalled = true;
    _users.add(UserEntity(
      id: 'user_${_users.length}',
      email: email,
      name: name,
      roles: roles,
      isOwner: false,
      businessId: businessSlug,
      createdAt: DateTime.now(),
    ));
  }

  @override
  Future<void> deleteUser(String userId) async {
    deleteCalled = true;
    _users.removeWhere((u) => u.id == userId);
  }

  @override
  Future<void> updateUserRoles(String userId, List<String> roles) async {
    updateRolesCalled = true;
    final idx = _users.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      final u = _users[idx];
      _users[idx] = UserEntity(
        id: u.id,
        email: u.email,
        name: u.name,
        roles: roles,
        isOwner: u.isOwner,
        businessId: u.businessId,
        createdAt: u.createdAt,
      );
    }
  }
}

// ---------------------------------------------------------------------------
// FACTORIES
// ---------------------------------------------------------------------------

RoleEntity _makeRole({
  String id = 'r1',
  String name = 'Test',
  List<String> permissions = const [],
  int position = 0,
}) =>
    RoleEntity(
      id: id,
      businessId: 'biz-demo',
      name: name,
      colorValue: 0xFF3B82F6,
      position: position,
      permissions: permissions,
    );

// ---------------------------------------------------------------------------
// TESTS
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  // GRUPO 1: RoleEntity — estructura y propiedades
  // =========================================================================
  group('RoleEntity', () {
    test('se crea correctamente con todos sus campos', () {
      final role = _makeRole(
        id: 'rol-1',
        name: 'Supervisor',
        permissions: ['chats:view_all', 'chats:respond'],
      );

      expect(role.id, 'rol-1');
      expect(role.name, 'Supervisor');
      expect(role.businessId, 'biz-demo');
      expect(role.permissions, contains('chats:view_all'));
      expect(role.permissions, contains('chats:respond'));
      expect(role.permissions.length, 2);
    });

    test('puede tener lista de permisos vacía', () {
      final role = _makeRole(permissions: []);
      expect(role.permissions, isEmpty);
    });

    test('acepta todos los permisos conocidos del sistema', () {
      const allPermissions = [
        'administrator',
        'catalog:view',
        'catalog:manage',
        'chats:view_all',
        'chats:view_assigned',
        'chats:respond',
        'chats:assign',
        'users:manage',
        'roles:manage',
        'settings:manage',
        'analytics:view',
      ];
      final role = _makeRole(permissions: allPermissions);
      expect(role.permissions.length, 11);
    });
  });

  // =========================================================================
  // GRUPO 2: PermissionChecker — Vendedor Estándar
  // =========================================================================
  group('PermissionChecker - Rol Vendedor Estándar', () {
    late PermissionChecker checker;

    setUp(() {
      checker = PermissionChecker(['chats:view_assigned', 'chats:respond']);
    });

    test('puede ver chats asignados', () => expect(checker.canViewAssignedChats, isTrue));
    test('puede responder chats', () => expect(checker.canRespondChats, isTrue));
    test('NO puede ver todos los chats', () => expect(checker.canViewAllChats, isFalse));
    test('NO puede asignar chats', () => expect(checker.canAssignChats, isFalse));
    test('NO puede ver catálogo', () => expect(checker.canViewCatalog, isFalse));
    test('NO puede editar catálogo', () => expect(checker.canManageCatalog, isFalse));
    test('NO puede gestionar usuarios', () => expect(checker.canManageUsers, isFalse));
    test('NO puede gestionar roles', () => expect(checker.canManageRoles, isFalse));
    test('NO puede modificar configuración', () => expect(checker.canManageSettings, isFalse));
    test('NO puede ver analytics', () => expect(checker.canViewAnalytics, isFalse));
    test('NO es administrador', () => expect(checker.isAdministrator, isFalse));
  });

  // =========================================================================
  // GRUPO 3: PermissionChecker — Supervisor de Ventas
  // =========================================================================
  group('PermissionChecker - Rol Supervisor de Ventas', () {
    late PermissionChecker checker;

    setUp(() {
      checker = PermissionChecker([
        'chats:view_all',
        'chats:respond',
        'chats:assign',
        'analytics:view',
      ]);
    });

    test('puede ver TODOS los chats', () => expect(checker.canViewAllChats, isTrue));
    test('puede ver chats asignados (heredado de view_all)', () =>
        expect(checker.canViewAssignedChats, isTrue));
    test('puede responder chats', () => expect(checker.canRespondChats, isTrue));
    test('puede asignar chats', () => expect(checker.canAssignChats, isTrue));
    test('puede ver analytics', () => expect(checker.canViewAnalytics, isTrue));
    test('NO puede editar catálogo', () => expect(checker.canManageCatalog, isFalse));
    test('NO puede gestionar usuarios', () => expect(checker.canManageUsers, isFalse));
    test('NO puede gestionar roles', () => expect(checker.canManageRoles, isFalse));
    test('NO puede modificar configuración', () => expect(checker.canManageSettings, isFalse));
  });

  // =========================================================================
  // GRUPO 4: PermissionChecker — Gestor de Catálogo
  // =========================================================================
  group('PermissionChecker - Rol Gestor de Catálogo', () {
    late PermissionChecker checker;

    setUp(() {
      checker = PermissionChecker(['catalog:view', 'catalog:manage']);
    });

    test('puede ver catálogo', () => expect(checker.canViewCatalog, isTrue));
    test('puede editar catálogo', () => expect(checker.canManageCatalog, isTrue));
    test('NO puede ver chats', () => expect(checker.canViewAssignedChats, isFalse));
    test('NO puede responder chats', () => expect(checker.canRespondChats, isFalse));
    test('NO puede gestionar usuarios', () => expect(checker.canManageUsers, isFalse));
    test('NO puede ver analytics', () => expect(checker.canViewAnalytics, isFalse));
    test('NO puede modificar configuración', () => expect(checker.canManageSettings, isFalse));
  });

  group('PermissionChecker - Solo catalog:view sin manage', () {
    late PermissionChecker checker;

    setUp(() => checker = PermissionChecker(['catalog:view']));

    test('puede ver catálogo', () => expect(checker.canViewCatalog, isTrue));
    test('NO puede EDITAR catálogo sin catalog:manage', () =>
        expect(checker.canManageCatalog, isFalse));
  });

  // =========================================================================
  // GRUPO 5: PermissionChecker — Administrador (permiso maestro)
  // =========================================================================
  group('PermissionChecker - Rol Administrador (permiso maestro)', () {
    late PermissionChecker checker;

    setUp(() => checker = PermissionChecker(['administrator']));

    test('es administrador', () => expect(checker.isAdministrator, isTrue));
    test('puede ver catálogo (heredado)', () => expect(checker.canViewCatalog, isTrue));
    test('puede editar catálogo (heredado)', () => expect(checker.canManageCatalog, isTrue));
    test('puede ver todos los chats (heredado)', () => expect(checker.canViewAllChats, isTrue));
    test('puede responder chats (heredado)', () => expect(checker.canRespondChats, isTrue));
    test('puede asignar chats (heredado)', () => expect(checker.canAssignChats, isTrue));
    test('puede gestionar usuarios (heredado)', () => expect(checker.canManageUsers, isTrue));
    test('puede gestionar roles (heredado)', () => expect(checker.canManageRoles, isTrue));
    test('puede modificar configuración (heredado)', () =>
        expect(checker.canManageSettings, isTrue));
    test('puede ver analytics (heredado)', () => expect(checker.canViewAnalytics, isTrue));
  });

  // =========================================================================
  // GRUPO 6: PermissionChecker — Sin permisos
  // =========================================================================
  group('PermissionChecker - Rol sin permisos (acceso cero)', () {
    test('no puede hacer nada con lista vacía', () {
      final checker = PermissionChecker([]);
      expect(checker.isAdministrator, isFalse);
      expect(checker.canViewCatalog, isFalse);
      expect(checker.canManageCatalog, isFalse);
      expect(checker.canViewAllChats, isFalse);
      expect(checker.canViewAssignedChats, isFalse);
      expect(checker.canRespondChats, isFalse);
      expect(checker.canAssignChats, isFalse);
      expect(checker.canManageUsers, isFalse);
      expect(checker.canManageRoles, isFalse);
      expect(checker.canManageSettings, isFalse);
      expect(checker.canViewAnalytics, isFalse);
    });
  });

  group('PermissionChecker - Solo configuración', () {
    late PermissionChecker checker;
    setUp(() => checker = PermissionChecker(['settings:manage']));

    test('puede modificar configuración', () => expect(checker.canManageSettings, isTrue));
    test('NO puede hacer nada más', () {
      expect(checker.canViewCatalog, isFalse);
      expect(checker.canViewAllChats, isFalse);
      expect(checker.canRespondChats, isFalse);
      expect(checker.canManageUsers, isFalse);
      expect(checker.canManageRoles, isFalse);
      expect(checker.canViewAnalytics, isFalse);
    });
  });

  group('PermissionChecker - Solo analytics', () {
    late PermissionChecker checker;
    setUp(() => checker = PermissionChecker(['analytics:view']));

    test('puede ver analytics', () => expect(checker.canViewAnalytics, isTrue));
    test('NO puede modificar nada', () {
      expect(checker.canManageCatalog, isFalse);
      expect(checker.canRespondChats, isFalse);
      expect(checker.canManageUsers, isFalse);
      expect(checker.canManageSettings, isFalse);
    });
  });

  group('PermissionChecker - Solo gestión de usuarios', () {
    late PermissionChecker checker;
    setUp(() => checker = PermissionChecker(['users:manage']));

    test('puede gestionar usuarios', () => expect(checker.canManageUsers, isTrue));
    test('NO puede gestionar roles (permiso distinto)', () =>
        expect(checker.canManageRoles, isFalse));
    test('NO puede acceder a chats', () => expect(checker.canViewAllChats, isFalse));
  });

  group('PermissionChecker - Solo gestión de roles', () {
    late PermissionChecker checker;
    setUp(() => checker = PermissionChecker(['roles:manage']));

    test('puede gestionar roles', () => expect(checker.canManageRoles, isTrue));
    test('NO puede gestionar usuarios (permiso distinto)', () =>
        expect(checker.canManageUsers, isFalse));
  });

  // =========================================================================
  // GRUPO 7: Dependencias automáticas de permisos
  // =========================================================================
  group('Dependencias automáticas de permisos', () {
    test('catalog:manage agrega catalog:view automáticamente', () {
      final result = applyPermissionDependencies([], 'catalog:manage');
      expect(result, contains('catalog:manage'));
      expect(result, contains('catalog:view'));
    });

    test('catalog:manage no duplica catalog:view si ya estaba', () {
      final result = applyPermissionDependencies(['catalog:view'], 'catalog:manage');
      expect(result.where((p) => p == 'catalog:view').length, 1);
    });

    test('catalog:view no agrega catalog:manage', () {
      final result = applyPermissionDependencies([], 'catalog:view');
      expect(result, contains('catalog:view'));
      expect(result, isNot(contains('catalog:manage')));
    });

    test('chats:respond agrega chats:view_assigned automáticamente', () {
      final result = applyPermissionDependencies([], 'chats:respond');
      expect(result, contains('chats:respond'));
      expect(result, contains('chats:view_assigned'));
    });

    test('chats:respond no duplica chats:view_assigned si ya estaba', () {
      final result =
          applyPermissionDependencies(['chats:view_assigned'], 'chats:respond');
      expect(result.where((p) => p == 'chats:view_assigned').length, 1);
    });

    test('chats:assign agrega chats:view_assigned automáticamente', () {
      final result = applyPermissionDependencies([], 'chats:assign');
      expect(result, contains('chats:assign'));
      expect(result, contains('chats:view_assigned'));
    });

    test('chats:view_assigned no agrega otros permisos', () {
      final result = applyPermissionDependencies([], 'chats:view_assigned');
      expect(result, equals(['chats:view_assigned']));
    });

    test('administrator no agrega otros permisos explícitos', () {
      final result = applyPermissionDependencies([], 'administrator');
      expect(result, equals(['administrator']));
    });

    test('los permisos existentes se conservan al agregar uno nuevo con dependencia', () {
      final existing = ['analytics:view', 'settings:manage'];
      final result = applyPermissionDependencies(existing, 'catalog:manage');
      expect(result, contains('analytics:view'));
      expect(result, contains('settings:manage'));
      expect(result, contains('catalog:manage'));
      expect(result, contains('catalog:view'));
    });
  });

  // =========================================================================
  // GRUPO 8: RolesProvider — CRUD con mock repository
  // =========================================================================
  group('RolesProvider', () {
    late MockRoleRepository mockRepo;
    late RolesProvider provider;

    setUp(() {
      mockRepo = MockRoleRepository();
      provider = RolesProvider(
        getRolesUseCase: GetRoles(mockRepo),
        createRoleUseCase: CreateRole(mockRepo),
        updateRoleUseCase: UpdateRole(mockRepo),
        updateRolePositionsUseCase: UpdateRolePositions(mockRepo),
        deleteRoleUseCase: DeleteRole(mockRepo),
      );
    });

    test('estado inicial es lista vacía y sin carga', () {
      expect(provider.roles, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMsg, '');
    });

    test('loadRoles carga los roles del repositorio', () async {
      mockRepo._roles = [
        _makeRole(id: 'r1', name: 'Vendedor'),
        _makeRole(id: 'r2', name: 'Supervisor'),
      ];

      await provider.loadRoles('biz-demo');

      expect(provider.roles.length, 2);
      expect(provider.roles.first.name, 'Vendedor');
      expect(provider.isLoading, isFalse);
    });

    test('createRole agrega un rol y recarga la lista', () async {
      final role = _makeRole(id: 'nuevo', name: 'Nuevo Rol',
          permissions: ['catalog:view']);

      final success = await provider.createRole('biz-demo', role);

      expect(success, isTrue);
      expect(mockRepo.createCalled, isTrue);
      expect(provider.roles.any((r) => r.id == 'nuevo'), isTrue);
    });

    test('createRole retorna false y guarda error si falla', () async {
      mockRepo.throwOnCreate = true;
      final role = _makeRole();

      final success = await provider.createRole('biz-demo', role);

      expect(success, isFalse);
      expect(provider.errorMsg, isNotEmpty);
    });

    test('updateRole modifica un rol existente', () async {
      mockRepo._roles = [_makeRole(id: 'r1', name: 'Original')];

      final updated = _makeRole(id: 'r1', name: 'Modificado',
          permissions: ['chats:view_all']);
      final success = await provider.updateRole('biz-demo', updated);

      expect(success, isTrue);
      expect(mockRepo.updateCalled, isTrue);
      expect(provider.roles.first.name, 'Modificado');
      expect(provider.roles.first.permissions, contains('chats:view_all'));
    });

    test('deleteRole elimina el rol y recarga la lista', () async {
      mockRepo._roles = [
        _makeRole(id: 'r1', name: 'A Eliminar'),
        _makeRole(id: 'r2', name: 'Permanente'),
      ];

      final success = await provider.deleteRole('biz-demo', 'r1');

      expect(success, isTrue);
      expect(mockRepo.deleteCalled, isTrue);
      expect(provider.roles.any((r) => r.id == 'r1'), isFalse);
      expect(provider.roles.any((r) => r.id == 'r2'), isTrue);
    });

    test('deleteRole retorna false y guarda error si falla', () async {
      mockRepo._roles = [_makeRole(id: 'r1')];
      mockRepo.throwOnDelete = true;

      final success = await provider.deleteRole('biz-demo', 'r1');

      expect(success, isFalse);
      expect(provider.errorMsg, isNotEmpty);
    });

    test('updateRolePositions llama al repositorio correctamente', () async {
      final positions = [
        {'id': 'r1', 'position': 0},
        {'id': 'r2', 'position': 1},
      ];

      final success = await provider.updateRolePositions('biz-demo', positions);

      expect(success, isTrue);
      expect(mockRepo.updatePositionsCalled, isTrue);
    });

    test('isLoading es false después de cada operación completada', () async {
      await provider.loadRoles('biz-demo');
      expect(provider.isLoading, isFalse);

      await provider.createRole('biz-demo', _makeRole());
      expect(provider.isLoading, isFalse);

      await provider.deleteRole('biz-demo', 'r1');
      expect(provider.isLoading, isFalse);
    });
  });

  // =========================================================================
  // GRUPO 9: UsersProvider — CRUD con mock repository
  // =========================================================================
  group('UsersProvider', () {
    late MockUserRepository mockRepo;
    late UsersProvider provider;

    setUp(() {
      mockRepo = MockUserRepository();
      provider = UsersProvider(
        getUsersUseCase: GetUsers(mockRepo),
        createUserUseCase: CreateUser(mockRepo),
        deleteUserUseCase: DeleteUser(mockRepo),
        updateUserRoleUseCase: UpdateUserRoles(mockRepo),
      );
    });

    test('estado inicial es lista vacía', () {
      expect(provider.users, isEmpty);
      expect(provider.isLoading, isFalse);
    });

    test('loadUsers obtiene usuarios del repositorio', () async {
      mockRepo._users = [
        UserEntity(
          id: 'u1',
          email: 'ana@demo.com',
          name: 'Ana García',
          roles: ['rol-vendedor'],
          isOwner: false,
          businessId: 'biz-demo',
          createdAt: DateTime.now(),
        ),
      ];

      await provider.loadUsers('biz-demo');

      expect(provider.users.length, 1);
      expect(provider.users.first.name, 'Ana García');
    });

    test('createUser crea un usuario y recarga la lista', () async {
      final success = await provider.createUser(
        businessSlug: 'biz-demo',
        name: 'Carlos',
        email: 'carlos@demo.com',
        password: 'pass123',
        roles: ['rol-vendedor'],
      );

      expect(success, isTrue);
      expect(mockRepo.createCalled, isTrue);
      expect(provider.users.any((u) => u.email == 'carlos@demo.com'), isTrue);
    });

    test('createUser retorna false si el repositorio lanza error', () async {
      mockRepo.throwOnCreate = true;

      final success = await provider.createUser(
        businessSlug: 'biz-demo',
        name: 'Error',
        email: 'err@demo.com',
        password: '123',
        roles: [],
      );

      expect(success, isFalse);
      expect(provider.errorMsg, isNotEmpty);
    });

    test('deleteUser elimina al usuario correcto', () async {
      mockRepo._users = [
        UserEntity(
          id: 'u1',
          email: 'a@demo.com',
          name: 'A',
          roles: [],
          isOwner: false,
          businessId: 'biz-demo',
          createdAt: DateTime.now(),
        ),
        UserEntity(
          id: 'u2',
          email: 'b@demo.com',
          name: 'B',
          roles: [],
          isOwner: false,
          businessId: 'biz-demo',
          createdAt: DateTime.now(),
        ),
      ];

      final success = await provider.deleteUser('biz-demo', 'u1');

      expect(success, isTrue);
      expect(mockRepo.deleteCalled, isTrue);
      expect(provider.users.any((u) => u.id == 'u1'), isFalse);
      expect(provider.users.any((u) => u.id == 'u2'), isTrue);
    });

    test('updateUserRoles actualiza los roles del usuario', () async {
      mockRepo._users = [
        UserEntity(
          id: 'u1',
          email: 'test@demo.com',
          name: 'Test',
          roles: ['rol-vendedor'],
          isOwner: false,
          businessId: 'biz-demo',
          createdAt: DateTime.now(),
        ),
      ];

      final success = await provider.updateUserRoles(
          'biz-demo', 'u1', ['rol-supervisor', 'rol-catalog']);

      expect(success, isTrue);
      expect(mockRepo.updateRolesCalled, isTrue);
      expect(provider.users.first.roles, contains('rol-supervisor'));
      expect(provider.users.first.roles, contains('rol-catalog'));
      expect(provider.users.first.roles, isNot(contains('rol-vendedor')));
    });

    test('isLoading es false al terminar cualquier operación', () async {
      await provider.loadUsers('biz-demo');
      expect(provider.isLoading, isFalse);

      await provider.createUser(
        businessSlug: 'biz-demo',
        name: 'X',
        email: 'x@x.com',
        password: 'x',
        roles: [],
      );
      expect(provider.isLoading, isFalse);
    });
  });

  // =========================================================================
  // GRUPO 10: Escenarios de negocio reales
  // =========================================================================
  group('Escenarios de negocio reales', () {
    test('vendedor con respond y assign puede hacer ambas cosas', () {
      final checker = PermissionChecker([
        'chats:view_assigned',
        'chats:respond',
        'chats:assign',
      ]);

      expect(checker.canViewAssignedChats, isTrue);
      expect(checker.canRespondChats, isTrue);
      expect(checker.canAssignChats, isTrue);
      expect(checker.canViewAllChats, isFalse);
    });

    test('usuario con roles catálogo Y chats puede usar ambas secciones', () {
      final checker = PermissionChecker([
        'catalog:view',
        'catalog:manage',
        'chats:view_assigned',
        'chats:respond',
      ]);

      expect(checker.canViewCatalog, isTrue);
      expect(checker.canManageCatalog, isTrue);
      expect(checker.canViewAssignedChats, isTrue);
      expect(checker.canRespondChats, isTrue);
      expect(checker.canViewAllChats, isFalse);
      expect(checker.canManageUsers, isFalse);
    });

    test('administrador tiene todos los permisos con solo el permiso maestro', () {
      final checker = PermissionChecker(['administrator']);

      expect(checker.canViewCatalog, isTrue);
      expect(checker.canManageCatalog, isTrue);
      expect(checker.canViewAllChats, isTrue);
      expect(checker.canViewAssignedChats, isTrue);
      expect(checker.canRespondChats, isTrue);
      expect(checker.canAssignChats, isTrue);
      expect(checker.canManageUsers, isTrue);
      expect(checker.canManageRoles, isTrue);
      expect(checker.canManageSettings, isTrue);
      expect(checker.canViewAnalytics, isTrue);
    });

    test('view_all incluye acceso a chats asignados también', () {
      final checker = PermissionChecker(['chats:view_all']);
      expect(checker.canViewAllChats, isTrue);
      expect(checker.canViewAssignedChats, isTrue);
    });

    test('view_assigned NO otorga acceso a ver todos los chats', () {
      final checker = PermissionChecker(['chats:view_assigned']);
      expect(checker.canViewAssignedChats, isTrue);
      expect(checker.canViewAllChats, isFalse);
    });

    test('usuario recién creado sin roles no puede acceder a nada', () {
      final user = UserEntity(
        id: 'u-nuevo',
        email: 'nuevo@demo.com',
        name: 'Nuevo Vendedor',
        roles: [],
        isOwner: false,
        businessId: 'biz-demo',
        createdAt: DateTime.now(),
      );
      final checker = PermissionChecker(
          user.roles.expand<String>((_) => []).toList());

      expect(checker.isAdministrator, isFalse);
      expect(checker.canViewCatalog, isFalse);
      expect(checker.canRespondChats, isFalse);
    });

    test('el campo isOwner del usuario es independiente de sus roles', () {
      final owner = UserEntity(
        id: 'owner-1',
        email: 'dueno@negocio.com',
        name: 'Dueño',
        roles: [],
        isOwner: true,
        businessId: 'biz-demo',
        createdAt: DateTime.now(),
      );

      expect(owner.isOwner, isTrue);
    });
  });

  // =========================================================================
  // GRUPO 11: Jerarquía y posición de roles
  // =========================================================================
  group('Jerarquía de roles por posición', () {
    test('los roles se ordenan por campo position correctamente', () {
      final roles = [
        _makeRole(id: 'r3', name: 'Tercero', position: 2),
        _makeRole(id: 'r1', name: 'Primero', position: 0),
        _makeRole(id: 'r2', name: 'Segundo', position: 1),
      ];

      final sorted = List<RoleEntity>.from(roles)
        ..sort((a, b) => a.position.compareTo(b.position));

      expect(sorted[0].name, 'Primero');
      expect(sorted[1].name, 'Segundo');
      expect(sorted[2].name, 'Tercero');
    });

    test('el rol de menor posición tiene mayor jerarquía', () {
      final topRole = _makeRole(id: 'r0', name: 'Director', position: 0);
      final lowRole = _makeRole(id: 'r5', name: 'Asistente', position: 5);

      expect(topRole.position < lowRole.position, isTrue);
    });

    test('dos roles con la misma posición son considerados iguales en jerarquía', () {
      final roleA = _makeRole(id: 'rA', name: 'A', position: 3);
      final roleB = _makeRole(id: 'rB', name: 'B', position: 3);

      expect(roleA.position.compareTo(roleB.position), 0);
    });
  });
}
