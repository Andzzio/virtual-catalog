import 'package:virtual_catalog_app/domain/entities/contact_entity.dart';

class ContactModel extends ContactEntity {
  ContactModel({
    required super.name,
    required super.phoneId,
  });

  factory ContactModel.fromMap(Map<String, dynamic> map) {
    return ContactModel(
      name: map['name'] ?? '',
      phoneId: map['phoneId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneId': phoneId,
    };
  }
}
