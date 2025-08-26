
import 'package:flutter/foundation.dart';
import 'package:gas/models/user_model.dart';

class UserService {
  // Simulate fetching a user by ID
  Future<UserModel?> getUserById(String userId) async {
    // In a real app, you would fetch this from your API or a local database
    await Future.delayed(Duration(seconds: 1));
    // Dummy data
    if (userId == '1') {
      return UserModel(id: '1', fullName: 'Test Buyer', email: 'buyer@test.com', role: 'buyer', createdAt: DateTime.now());
    }
    return null;
  }

  // Simulate updating a user's profile
  Future<void> updateUser(UserModel user) async {
    // In a real app, you would make an API call to update the user data
    await Future.delayed(Duration(seconds: 1));
    debugPrint('User ${user.id} updated successfully.');
  }
}
