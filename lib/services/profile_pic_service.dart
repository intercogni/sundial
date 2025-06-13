import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePicManager {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseDatabase.instance;
  final _picker = ImagePicker();

  Future<String?> uploadAndSaveProfilePic() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return null;

    final file = File(picked.path);
    final bytes = await file.readAsBytes();
    final base64Image = base64Encode(bytes);

    await _db.ref('users/${user.uid}/photoBase64').set(base64Image);
    return base64Image;
  }

  Future<void> deleteProfilePic() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db.ref('users/${user.uid}/photoBase64').remove();
  }

  Widget profilePicWidget({double radius = 40}) {
    final user = _auth.currentUser;
    if (user == null) return _placeholder(radius);

    return StreamBuilder<DatabaseEvent>(
      stream: _db.ref('users/${user.uid}/photoBase64').onValue,
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.data!.snapshot.value is String &&
            snapshot.data!.snapshot.value != null) {
          try {
            final base64 = snapshot.data!.snapshot.value as String;
            Uint8List bytes = base64Decode(base64);
            return CircleAvatar(
              radius: radius,
              backgroundImage: MemoryImage(bytes),
            );
          } catch (_) {
            return _placeholder(radius);
          }
        } else {
          return _placeholder(radius);
        }
      },
    );
  }

  Widget _placeholder(double radius) {
    return CircleAvatar(
      radius: radius,
      child: Icon(Icons.person, size: radius),
    );
  }
}
