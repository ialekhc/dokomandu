import 'package:dokomandu/shared/models/user_model.dart';

class DemoAuthUserModel {
  const DemoAuthUserModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.password,
  });

  final String id;
  final String fullName;
  final String phone;
  final String password;

  UserModel toUserModel() {
    return UserModel(id: id, name: fullName, phone: phone);
  }

  factory DemoAuthUserModel.fromJson(Map<String, dynamic> json) {
    return DemoAuthUserModel(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phone': phone,
      'password': password,
    };
  }
}
