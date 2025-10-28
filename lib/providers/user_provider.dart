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
    status: '',
    token: '',
    cart: [],
    followers: [],
    following: [],
    latitude: 0.0,
    longitude: 0.0,
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
      );
      notifyListeners();
    }
  }

  // Method to unfollow a seller
  void unfollowSeller(String sellerId) {
    _user = _user.copyWith(
      following: _user.following.where((id) => id != sellerId).toList(),
    );
    notifyListeners();
  }

  // Method to update a list of followers folling a seller
  void updateFollowing(List<String> following) {
    _user = _user.copyWith(following: following);
    notifyListeners();
  }

  
  void updateFollowers(List<String> followers) {
    _user = _user.copyWith(followers: followers);
    notifyListeners();
  }

  
  bool isFollowing(String sellerId) {
    return _user.following.contains(sellerId);
  }
}
