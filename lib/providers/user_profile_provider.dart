import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class UserProfileProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserProfile? _userProfile;

  UserProfile? get userProfile => _userProfile;

  Future<void> loadUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _userProfile = UserProfile.fromMap(doc.data()!..['uid'] = user.uid);
      } else {
        // Create new profile if it doesn't exist
        final newProfile = UserProfile(
          uid: user.uid,
          displayName: user.displayName ?? 'Petugas',
          email: user.email ?? '',
          photoURL: user.photoURL,
          role: 'Petugas',
          joinDate: DateTime.now(),
        );
        await _firestore.collection('users').doc(user.uid).set(newProfile.toMap());
        _userProfile = newProfile;
      }
      notifyListeners();
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  Future<void> updateProfile(UserProfile updatedProfile) async {
    try {
      await _firestore
          .collection('users')
          .doc(updatedProfile.uid)
          .update(updatedProfile.toMap());
      _userProfile = updatedProfile;
      notifyListeners();
    } catch (e) {
      print('Error updating user profile: $e');
      throw e;
    }
  }
}