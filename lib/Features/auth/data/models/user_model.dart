class UserModel {
  final String uid;
  final String token; //! For Testing
  final String name;
  final String email;
  final String image;
  final List<dynamic> followers;
  final List<dynamic> followings;
  final List<dynamic> userChatsIds;

  UserModel({
    required this.uid,
    required this.token,
    required this.name,
    required this.email,
    required this.image,
    required this.followers,
    required this.followings,
    required this.userChatsIds,
  });
  factory UserModel.formJson(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'],
      token: data['token'],
      name: data['name'],
      email: data['email'],
      image: data['image'],
      followers: data['followers'],
      followings: data['followings'],
      userChatsIds:
          data['userChatsIds'].map((e) => e['userIdMessageWith']).toList(),
    );
  }
}
