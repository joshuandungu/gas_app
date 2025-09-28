import 'package:ecommerce_app_fluterr_nodejs/models/user.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(
    id: '',
    name: '',
    email: '',
    password: '',
    address: '',
    type: '',
    token: '',
    cart: [],
    followers: [],
    following: [],
  );

  User get user => _user;

  void setUser(String user) {
    _user = User.fromJson(user);
    notifyListeners();
  }

  void setUserFromModel(User user) {
    _user = user;
    notifyListeners();
  }

  // Method to follow the seller
  void followSeller(String sellerId) {
    if (!_user.following.contains(sellerId)) {
      _user = _user.copyWith(
        following: [..._user.following, sellerId],
        phoneNumber: null,
      );
      notifyListeners();
    }
  }

  // Method to unfollow a seller
  void unfollowSeller(String sellerId) {
    _user = _user.copyWith(
      following: _user.following.where((id) => id != sellerId).toList(),
      phoneNumber: null,
    );
    notifyListeners();
  }

  // Method to update a list of followers folling a seller
  void updateFollowing(List<String> following) {
    _user = _user.copyWith(following: following, phoneNumber: null);
    notifyListeners();
  }

  
  void updateFollowers(List<String> followers) {
    _user = _user.copyWith(followers: followers, phoneNumber: null);
    notifyListeners();
  }

  
  bool isFollowing(String sellerId) {
    return _user.following.contains(sellerId);
  }
}
