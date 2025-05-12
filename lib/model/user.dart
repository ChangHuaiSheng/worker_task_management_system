class User { //user properties
  String? userId;
  String? userName;
  String? userEmail;
  String? userPassword;
  String? userPhone;
  String? userAddress;

  User( //constructor with named optional parameters
      {this.userId,
      this.userName,
      this.userEmail,
      this.userPassword,
      this.userPhone,
      this.userAddress});

  User.fromJson(Map<String, dynamic> json) {  //named constructor to create a user object from json
    userId = json['id'];
    userName = json['full_name'];
    userEmail = json['email'];
    userPassword = json['password'];
    userPhone = json['phone'];
    userAddress = json['address'];
  }

  Map<String, dynamic> toJson() { //convert the user object into a JSON map
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = userId;
    data['full_name'] = userName;
    data['email'] = userEmail;
    data['password'] = userPassword;
    data['phone'] = userPhone;
    data['address'] = userAddress;
    return data;
  }
}