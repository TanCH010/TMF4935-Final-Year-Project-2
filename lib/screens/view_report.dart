import 'package:e_vandalism/models/report_data.dart';
import 'package:e_vandalism/screens/view_report_details.dart';
import 'package:e_vandalism/services/database.dart';
import 'package:flutter/material.dart';

class ViewReport extends StatefulWidget {
  const ViewReport({super.key});

  @override
  State<ViewReport> createState() => _ViewReportState();
}

class _ViewReportState extends State<ViewReport> {
  final DatabaseService _databaseService = DatabaseService(id: '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Report Status',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report List',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: StreamBuilder<List<ReportData>>(
                stream: _databaseService.reports,
                builder: (context, snapshot){
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center (
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty){
                    return const Center (
                      child: Text('No reports available.'),
                    );
                  }

                  final reports = snapshot.data!;

                  return ListView.builder(
                    itemCount: reports.length,
                    itemBuilder: (context, index){
                      final report = reports[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text('Report Id: ${report.id}'),
                          subtitle: Text('Status: ${report.status}'),
                          trailing: ElevatedButton(
                            onPressed: () {
                              // Navigate to report details page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewReportDetails(report: report,),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            child: const Text('View'),
                          ),
                        ),
                      );
                    }
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}