// user.dart (model)
class User {
  String? userId;
  String? userName;
  String? userEmail;
  String? userPassword;
  String? userPhone;
  String? userAddress;
  String? userImage; // base64 image

  User({
    this.userId,
    this.userName,
    this.userEmail,
    this.userPassword,
    this.userPhone,
    this.userAddress,
    this.userImage,
  });

  User.fromJson(Map<String, dynamic> json) {
    userId = json['worker_id']?.toString();
    userName = json['full_name'];
    userEmail = json['email'];
    userPassword = json['password'];
    userPhone = json['phone'];
    userAddress = json['address'];
    userImage = json['image'];
  }

  Map<String, dynamic> toJson() => {
        'worker_id': userId,
        'full_name': userName,
        'email': userEmail,
        'password': userPassword,
        'phone': userPhone,
        'address': userAddress,
        'image': userImage,
      };
}