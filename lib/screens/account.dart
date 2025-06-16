import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/profile_pic_service.dart';
import '../services/daily_solar_data_service.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  static final _picManager = ProfilePicManager();

  Future<void> _showChangeUsernameDialog(BuildContext context) async {
    String newUsername = '';
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Username'),
          content: TextField(
            onChanged: (value) {
              newUsername = value;
            },
            decoration: const InputDecoration(hintText: 'Enter new username'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.currentUser?.updateDisplayName(newUsername);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Username updated successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update username: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    String newPassword = '';
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: TextField(
            onChanged: (value) {
              newPassword = value;
            },
            obscureText: true,
            decoration: const InputDecoration(hintText: 'Enter new password'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.currentUser?.updatePassword(newPassword);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password updated successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update password: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: ListView(
        children: <Widget>[
          const SizedBox(height: 20),

          Center(child: _picManager.profilePicWidget(radius: 50)),
          const SizedBox(height: 10),

          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Upload / Change Profile Picture'),
            onTap: () async {
              await _picManager.uploadAndSaveProfilePic();
            },
          ),

          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete Profile Picture'),
            onTap: () async {
              await _picManager.deleteProfilePic();
            },
          ),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Change Username'),
            onTap: () {
              _showChangeUsernameDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            onTap: () {
              _showChangePasswordDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Delete All Solar Data'),
            onTap: () async {
              final dailySolarDataService = DailySolarDataService();
              await dailySolarDataService.deleteAllDailySolarData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All daily solar data deleted.')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log Out'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', false);
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
