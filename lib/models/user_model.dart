import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable(createToJson: false)
class UserModel {
  final Address? address;
  final int? id;
  final String? email;
  final String? username;
  final String? password;
  final Name? name;
  final String? phone;
  int v;

  UserModel({
    this.address,
    this.id,
    this.email,
    this.username,
    this.password,
    this.name,
    this.phone,
    this.v = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  static List<UserModel> fromList(List<dynamic> data) =>
      data.map((e) => UserModel.fromJson(e)).toList();

  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }
}

@JsonSerializable(createToJson: false)
class Address {
  final String? city;
  final String? street;
  final int? number;
  final String? zipcode;
  final Geolocation? geo;

  Address({this.city, this.street, this.number, this.zipcode, this.geo});

  factory Address.fromJson(Map<String, dynamic> json) {
    return _$AddressFromJson(json);
  }
}

@JsonSerializable(createToJson: false)
class Geolocation {
  final String? lat;
  final String? long;

  Geolocation({this.lat, this.long});

  factory Geolocation.fromJson(Map<String, dynamic> json) {
    return _$GeolocationFromJson(json);
  }
}

@JsonSerializable(createToJson: false)
class Name {
  final String? firstname;
  final String? lastname;

  Name({this.firstname, this.lastname});

  factory Name.fromJson(Map<String, dynamic> json) {
    return _$NameFromJson(json);
  }
}
