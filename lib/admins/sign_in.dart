import 'package:e_vandalism/admins/admin_dashboard.dart';
import 'package:e_vandalism/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:e_vandalism/screens/home.dart';


class SignIn extends StatefulWidget {

  // final Function toggleView;
  // const SignIn({ super.key, required this.toggleView });
  const SignIn({ super.key,});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  // text field state
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        automaticallyImplyLeading: false,
        elevation: 0.0,
        title: Text(
          'Welcome Back',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 40.0),
              
              // Email section
              const Text(
                  'Email',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),

              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  fillColor: Colors.white,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.pink, width: 2.0),
                  )
                ),
                validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                onChanged: (val) {
                  setState(() => email = val);
                },
              ),
              SizedBox(height: 20.0),

              // Password section
              const Text(
                'Password',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  fillColor: Colors.white,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.pink, width: 2.0),
                  )
                  ),
                obscureText: true,
                validator: (val) => val!.length < 6 ? 'Enter a password 6+ chars long' : null,
                onChanged: (val) {
                  setState(() => password = val);
                },
              ),
              SizedBox(height: 12.0),

              Center(
              child: Text(
                  error,
                  style: TextStyle(color: Colors.red, fontSize: 14.0),
                ),
              ),
              const Spacer(), // Pushes the button to the bottom
              Padding(
                padding: const EdgeInsets.only(bottom: 30.0), // Elevate the button
                child: Center(
                  child: Column(
                    children: [
                      // Login button  
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink[400], // Background color
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(color: Colors.white, fontSize: 20.0),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // Show Loading Spinner
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            );
                            dynamic result = await _auth.signInWithEmailAndPassword(
                                email, password);
                            if (result == null) {
                              setState(() {
                                error = 'Could not login with those credentials';
                              });
                            } else {
                              // Navigate to Home after successful sign-in
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AdminDashboard()
                                ),
                              );
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 12.0),
                  
                      // Back button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink[400],
                        ),
                        child: const Text(
                          'Back',
                          style: TextStyle(color: Colors.white, fontSize: 20.0),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const Home())
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}