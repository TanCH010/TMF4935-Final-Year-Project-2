import 'package:e_vandalism/screens/new_report.dart';
import 'package:e_vandalism/screens/view_report.dart';
import 'package:e_vandalism/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Main content in a Column
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Row with Sign In button at the top-right
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to admin login page
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Wrapper()),
                        );
                      },
                      child: const Text('Admin'),
                    ),
                  ],
                ),

                // Spacer between Sign In and Title
                const SizedBox(height: 40.0),

                // Centered Title
                const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome',
                        style: TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'eVandalism: A Smart Mobile\nReporting Application',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Spacer between title and form button
                const SizedBox(height: 150.0),

                // Centered Create New Report Form button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to form page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NewReport()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(
                      'Create New Report',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ),

                // Spacer between New Report button and View Report button
                const SizedBox(height: 20.0),
                
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to view reports
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ViewReport())
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(
                      'View Report',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Exit button at the bottom center
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: ElevatedButton(
                  onPressed: () {
                    SystemNavigator.pop(); // Exit the app
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                  ),
                  child: const Text(
                    'Exit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}