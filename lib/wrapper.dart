import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:e_vandalism/admins/admin_dashboard.dart';
import 'package:e_vandalism/admins/sign_in.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    
    // Check if the user is signed in
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is logged in, redirect to AdminDashboard
      return const AdminDashboard();
    } else {
      // User is not logged in, redirect to SignIn
      return const SignIn();
    }
  }
}