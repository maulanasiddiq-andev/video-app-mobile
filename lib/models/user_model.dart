class UserModel {
  final String id;
  final String name;
  final String username;
  final String email;
  final String recordStatus;
  final int? videosCount;
  String? profileImage;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.recordStatus,
    this.videosCount,
    this.profileImage
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'], 
    name: json['name'], 
    username: json['username'], 
    email: json['email'], 
    recordStatus: json['recordStatus'],
    profileImage: json['profileImage'],
    videosCount: json['videosCount']
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'username': username,
    'email': email,
    'recordStatus': recordStatus,
    'profileImage': profileImage,
    'videosCount': videosCount
  };
}