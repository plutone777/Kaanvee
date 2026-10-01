import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_application/viewmodels/user_viewmodel.dart';
import 'package:fyp_application/views/admin_home_view.dart';
import 'package:fyp_application/views/home_view.dart';
import 'package:fyp_application/views/login_view.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  User? _firebaseUser;
  User? _lastLoadedUser;

  @override
  void initState() {
    super.initState();
    _firebaseUser = FirebaseAuth.instance.currentUser;

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (!mounted) return;

      setState(() {
        _firebaseUser = user;
        _lastLoadedUser = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_firebaseUser == null) {
      return const SignInView();
    }

    return FutureBuilder(
      future: _loadUser(_firebaseUser!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Unable to load user information.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _lastLoadedUser = null;
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final userViewModel = context.read<UserViewModel>();
        final user = userViewModel.getUser(_firebaseUser!.uid);

        if (user == null) {
          return const SignInView();
        }

        if (user.role.trim().toLowerCase() == 'admin') {
          return const AdminHomeView();
        }

        return const HomeView();
      },
    );
  }

  Future<void> _loadUser(User firebaseUser) async {
    if (_lastLoadedUser?.uid == firebaseUser.uid) {
      return;
    }

    await context.read<UserViewModel>().loadUser(
      firebaseUser.uid,
      forceRefresh: true,
    );

    _lastLoadedUser = firebaseUser;
  }
}
