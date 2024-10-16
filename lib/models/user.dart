import 'dart:convert';

class User {
  final String? idToken;
  final String? name;
  final String? nickname;
  final String? email;
  final String? profileUrl;
  final String? pictureUrl;
  final String? gender;
  final String? birthdate;
  final String? city;
  final String? country;
  final String? areaOfInterest;
  final String? profession;

  User({
    this.idToken,
    this.name,
    this.nickname,
    this.email,
    this.profileUrl,
    this.pictureUrl,
    this.gender,
    this.birthdate,
    this.city,
    this.country,
    this.areaOfInterest,
    this.profession,
  });

  Map<String, dynamic> toMap() {
    return {
      'idToken': idToken,
      'name': name,
      'nickname': nickname,
      'email': email,
      'profileUrl': profileUrl?.toString(),
      'pictureUrl': pictureUrl?.toString(),
      'gender': gender,
      'birthdate': birthdate,
      'city': city,
      'country': country,
      'areaOfInterest': areaOfInterest,
      'profession': profession,
    };
  }

  String toJson() => json.encode(toMap());

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      idToken: map['idToken'],
      name: map['name'],
      nickname: map['nickname'],
      email: map['email'],
      profileUrl: map['profileUrl'],
      pictureUrl: map['pictureUrl'],
      gender: map['gender'],
      birthdate: map['birthdate'],
      city: map['city'],
      country: map['country'],
      areaOfInterest: map['areaOfInterest'],
      profession: map['profession'],
    );
  }

  // factory User.fromJson(String source) => User.fromMap(json.decode(source));

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      idToken: json['idToken'],
      name: json['name'],
      nickname: json['nickname'],
      email: json['email'],
      profileUrl: json['profileUrl'],
      pictureUrl: json['pictureUrl'],
      gender: json['gender'],
      birthdate: json['birthdate'],
      city: json['city'],
      country: json['country'],
      areaOfInterest: json['areaOfInterest'],
      profession: json['profession'],
    );
  }
}
