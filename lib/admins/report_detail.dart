import 'package:e_vandalism/models/report_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:e_vandalism/admins/admin_dashboard.dart';

class ReportDetail extends StatelessWidget {
  final ReportData report;

  const ReportDetail({super.key, required this.report});

  Future<void> _updateStatus(String newStatus) async {
    try {
      // Update the status in Firestore
      await FirebaseFirestore.instance
          .collection('ReportData')
          .doc(report.id)
          .update({'status': newStatus});
    } catch (e) {
      print('Failed to update status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Details ${report.id}'),
        backgroundColor: Colors.red,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Email or Contact Number Section
              const Text(
                'Email or Contact Number',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: TextEditingController(text: report.emailOrContactNo),
                readOnly: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),

              // Image Section
              Center(
                child: report.picture.isNotEmpty
                    ? Image.network(
                        report.picture,
                        height: 200.0,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child; // Image is fully loaded
                          return const Center(
                            child: CircularProgressIndicator(), // Show spinner while loading
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Text('Failed to load image'), // Show error message if loading fails
                          );
                        },
                      )
                    : const Text('No image available'),
              ),
              const SizedBox(height: 16.0),

              // Location
              const Text(
                'Location',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: TextEditingController(text: report.location),
                readOnly: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),

              // Date
              const Text(
                'Date',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: TextEditingController(text: DateFormat('dd/MM/yyyy').format(report.date),),
                readOnly: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),

              // Description
              const Text(
                'Descriptions (Optional)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: TextEditingController(text: report.description),
                readOnly: true,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),

              // Status
              const Text(
                'Status',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: TextEditingController(text: report.status),
                readOnly: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _updateStatus('Under Investigation');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Status updated to Under Investigation')),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminDashboard()
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Under Investigation', style: TextStyle(color: Colors.white, fontSize: 18.0),),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _updateStatus('Case Closed');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Status updated to Case Closed')),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminDashboard()
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Case Closed', style: TextStyle(color: Colors.white, fontSize: 18.0),),
                  ),
                ],
              ),
            ],
          ),
        ),
      )
    );
  }
}