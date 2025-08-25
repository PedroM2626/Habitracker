import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hbitolar/models/user_model.dart';
import 'package:hbitolar/repositories/base_repository.dart';
import 'package:hbitolar/firestore/firestore_data_schema.dart';

class UserRepository extends BaseRepository {
  static const String _collection = FirestoreSchema.usersCollection;
  
  /// Create a new user document
  Future<void> createUser(UserModel user) async {
    try {
      await firestore.collection(_collection).doc(user.uid).set({
        UserSchema.email: user.email,
        UserSchema.name: user.name,
        UserSchema.bio: user.bio,
        UserSchema.photoUrl: user.photoUrl,
        UserSchema.totalXp: user.totalXp,
        UserSchema.level: user.level,
        UserSchema.createdAt: dateTimeToTimestamp(user.createdAt),
        UserSchema.updatedAt: dateTimeToTimestamp(user.updatedAt),
        UserSchema.currentStreak: 0,
        UserSchema.longestStreak: 0,
      });
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }
  
  /// Get a user by their ID
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await firestore.collection(_collection).doc(userId).get();
      
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      return UserModel(
        uid: userId,
        email: data[UserSchema.email] ?? '',
        name: data[UserSchema.name] ?? '',
        bio: data[UserSchema.bio],
        photoUrl: data[UserSchema.photoUrl],
        totalXp: data[UserSchema.totalXp] ?? 0,
        level: data[UserSchema.level] ?? 1,
        createdAt: timestampToDateTime(data[UserSchema.createdAt]) ?? DateTime.now(),
        updatedAt: timestampToDateTime(data[UserSchema.updatedAt]) ?? DateTime.now(),
      );
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }
  
  /// Update user profile
  Future<void> updateUser(UserModel user) async {
    try {
      await firestore.collection(_collection).doc(user.uid).update({
        UserSchema.email: user.email,
        UserSchema.name: user.name,
        UserSchema.bio: user.bio,
        UserSchema.photoUrl: user.photoUrl,
        UserSchema.totalXp: user.totalXp,
        UserSchema.level: user.level,
        UserSchema.updatedAt: dateTimeToTimestamp(user.updatedAt),
      });
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }
  
  /// Stream user data changes
  Stream<UserModel?> streamUser(String userId) {
    return firestore.collection(_collection).doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      return UserModel(
        uid: userId,
        email: data[UserSchema.email] ?? '',
        name: data[UserSchema.name] ?? '',
        bio: data[UserSchema.bio],
        photoUrl: data[UserSchema.photoUrl],
        totalXp: data[UserSchema.totalXp] ?? 0,
        level: data[UserSchema.level] ?? 1,
        createdAt: timestampToDateTime(data[UserSchema.createdAt]) ?? DateTime.now(),
        updatedAt: timestampToDateTime(data[UserSchema.updatedAt]) ?? DateTime.now(),
      );
    });
  }
  
  /// Update user XP and level
  Future<void> updateUserXp(String userId, int additionalXp) async {
    try {
      await firestore.runTransaction((transaction) async {
        final userRef = firestore.collection(_collection).doc(userId);
        final userDoc = await transaction.get(userRef);
        
        if (!userDoc.exists) {
          throw Exception('User document not found');
        }
        
        final currentXp = userDoc.data()![UserSchema.totalXp] ?? 0;
        final newTotalXp = currentXp + additionalXp;
        final newLevel = _calculateLevel(newTotalXp);
        
        transaction.update(userRef, {
          UserSchema.totalXp: newTotalXp,
          UserSchema.level: newLevel,
          UserSchema.updatedAt: dateTimeToTimestamp(DateTime.now()),
        });
      });
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }
  
  /// Update user streak
  Future<void> updateUserStreak(String userId, int currentStreak) async {
    try {
      await firestore.runTransaction((transaction) async {
        final userRef = firestore.collection(_collection).doc(userId);
        final userDoc = await transaction.get(userRef);
        
        if (!userDoc.exists) {
          throw Exception('User document not found');
        }
        
        final currentLongestStreak = userDoc.data()![UserSchema.longestStreak] ?? 0;
        final newLongestStreak = currentStreak > currentLongestStreak ? currentStreak : currentLongestStreak;
        
        transaction.update(userRef, {
          UserSchema.currentStreak: currentStreak,
          UserSchema.longestStreak: newLongestStreak,
          UserSchema.updatedAt: dateTimeToTimestamp(DateTime.now()),
        });
      });
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }
  
  /// Delete user account
  Future<void> deleteUser(String userId) async {
    try {
      await firestore.collection(_collection).doc(userId).delete();
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }
  
  /// Calculate user level based on XP
  int _calculateLevel(int totalXp) {
    if (totalXp < 100) return 1;
    if (totalXp < 300) return 2;
    if (totalXp < 600) return 3;
    if (totalXp < 1000) return 4;
    if (totalXp < 1500) return 5;
    if (totalXp < 2500) return 6;
    if (totalXp < 4000) return 7;
    if (totalXp < 6000) return 8;
    if (totalXp < 9000) return 9;
    if (totalXp < 13000) return 10;
    return 10 + ((totalXp - 13000) ~/ 2000);
  }
}