// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      address: json['address'] == null
          ? null
          : Address.fromJson(json['address'] as Map<String, dynamic>),
      id: (json['id'] as num?)?.toInt(),
      email: json['email'] as String?,
      username: json['username'] as String?,
      password: json['password'] as String?,
      name: json['name'] == null
          ? null
          : Name.fromJson(json['name'] as Map<String, dynamic>),
      phone: json['phone'] as String?,
      v: (json['v'] as num?)?.toInt() ?? 0,
    );

Address _$AddressFromJson(Map<String, dynamic> json) => Address(
      city: json['city'] as String?,
      street: json['street'] as String?,
      number: (json['number'] as num?)?.toInt(),
      zipcode: json['zipcode'] as String?,
      geo: json['geo'] == null
          ? null
          : Geolocation.fromJson(json['geo'] as Map<String, dynamic>),
    );

Geolocation _$GeolocationFromJson(Map<String, dynamic> json) =>
    Geolocation(lat: json['lat'] as String?, long: json['long'] as String?);

Name _$NameFromJson(Map<String, dynamic> json) => Name(
      firstname: json['firstname'] as String?,
      lastname: json['lastname'] as String?,
    );
