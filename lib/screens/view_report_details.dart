import 'package:flutter/material.dart';
import 'package:e_vandalism/models/report_data.dart';
import 'package:intl/intl.dart';

class ViewReportDetails extends StatelessWidget {
  final ReportData report;

  const ViewReportDetails({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Details: ${report.id}'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              controller: TextEditingController(
                text: DateFormat('dd/MM/yyyy').format(report.date),
              ),
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
          ],
        ),
      ),
    );
  }
}