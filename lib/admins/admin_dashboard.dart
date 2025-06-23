import 'package:e_vandalism/admins/report_detail.dart';
import 'package:flutter/material.dart';
import 'package:e_vandalism/services/database.dart';
import 'package:e_vandalism/models/report_data.dart';
import 'package:e_vandalism/services/auth.dart';
import 'package:e_vandalism/admins/sign_in.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final DatabaseService _databaseService = DatabaseService(id: '');
  final AuthService _authService = AuthService();
  String selectedFilter = 'All';
  String graphFilter = 'Weekly';

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

  DateTime currentWeekStartDate = DateTime.now();
  int currentYear = DateTime.now().year;

  void _initializeLocalNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/launcher_icon');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  void initState() {
    super.initState();
    _initializeLocalNotifications();
    _requestNotificationPermission();
    _setupForegroundNotificationListener();

    // Set the currentWeekStartDate to the start of the of the current week (Monday)
    currentWeekStartDate = _getStartOfWeek(DateTime.now());
  }

  Future<void> _requestNotificationPermission() async{
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request notification permission
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional notification permission');
    } else {
      print('User denied notification permission');
    }
  }

  void _setupForegroundNotificationListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
        );
      }
    });
  }

  // Get the start of the week (Monday) for a given date
  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  // Navigate to the previous week
  void _goToPreviousWeek() {
    setState(() {
      currentWeekStartDate = currentWeekStartDate.subtract(const Duration(days: 7));
    });
  }

  // Navigate to the next week
  void _goToNextWeek() {
    setState(() {
      currentWeekStartDate = currentWeekStartDate.add(const Duration(days: 7));
    });
  }

  // Navigate to previous year
  void _goToPreviousYear() {
    setState(() {
      currentYear--;
    });
  }

  // Navigate to next year
  void _goToNextYear() {
    setState(() {
      currentYear++;
    });
  }



  // Get the end of the current week
  DateTime _getEndOfWeek(DateTime startDate) {
    return startDate.add(const Duration(days: 6));
  }

  // Function to process the data for the graph
  List<FlSpot> _processLineChartData(List<ReportData> reports) {
    if (graphFilter == 'Weekly'){
    // Filter reports for the current week
    final startDate = currentWeekStartDate;
    final endDate = _getEndOfWeek(startDate);
    
    final filteredReports = reports.where((report) {
      final reportDate = report.createdAt;
      return reportDate.isAfter(startDate.subtract(const Duration (days: 1))) &&
        reportDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();

    // Group reports by day of the week
    Map<int, int> groupedData = {for (int i = 1; i <= 7; i++) i: 0}; // Initialize for Mon-Sun

    for (var report in filteredReports) {
      final weekday = report.createdAt.weekday;
      groupedData[weekday] = (groupedData[weekday] ?? 0) + 1;
    }

    // Convert grouped data into a list of FlSpot objects
    return groupedData.entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.toDouble());
    }).toList();
  } else {
    // Monthly logic (filtered by current year)
    final filteredReports = reports.where((report) {
      return report.createdAt.year == currentYear;
    }).toList();

    // Group reports by month
    Map<int, int> groupedData = {for (int i = 1; i <= 12; i++) i: 0};

    for (var report in filteredReports) {
      final month = report.createdAt.month;
      groupedData[month] = (groupedData[month] ?? 0) + 1;
    }

    // Convert grouped data into a list of FlSpot objects
    return groupedData.entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.toDouble());
    }).toList();
  }
}
  @override
  Widget build(BuildContext context) {
    final startDate = currentWeekStartDate;
    final endDate = _getEndOfWeek(startDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red,
        automaticallyImplyLeading: false,
        actions: [
          Icon(
            Icons.account_circle,
            color: Colors.black,
            size: 40.0,
          ),
          IconButton(
            icon: const Icon(
              Icons.logout,
              size: 40.0,
              color: Colors.black,
            ),
            tooltip: 'Log Out',
            onPressed: () async {
              await _authService.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SignIn()),
              );
            },
          ),
          const SizedBox(width: 10.0),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Graph Section
            // Filter for weekly
            if (graphFilter == 'Weekly')
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _goToPreviousWeek,
                  ),
                  Text(
                    '${startDate.day}/${startDate.month}/${startDate.year} - ${endDate.month}/${endDate.year}',
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: _goToNextWeek
                  ),
                ],
              ),
            //Filter for monthly
            if (graphFilter == 'Monthly')
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _goToPreviousYear,
                  ),
                  Text(
                    '$currentYear',
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: _goToNextYear
                  ),
                ],
              ),
            const SizedBox(height: 16.0),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Reports Graph',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButton(
                  value: graphFilter,
                  items: <String>['Weekly', 'Monthly'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      graphFilter = newValue!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0,),
            FutureBuilder<List<ReportData>>(
              future: _databaseService.reports.first,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No reports available'));
                }

                // Process data for the graph
                final data = _processLineChartData(snapshot.data!);
                return Container(
                  height: 200.0,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: data,
                          barWidth: 4,
                          isStrokeCapRound: true,
                          belowBarData: BarAreaData(show: true), // Disable area under the line
                        ),
                      ],
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40.0,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 12.0),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40.0,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              if (graphFilter == 'Weekly') {
                                // Days of the week for weekly filter
                                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                if (value >= 1 && value <= 7) {
                                  return Text(
                                    days[value.toInt() - 1],
                                    style: const TextStyle(fontSize: 12.0),
                                  );
                                } else {
                                  return const Text('');
                                }
                              } else {
                                // Months for monthly filter
                                const months = [
                                  'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
                                  'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
                                ];
                                if (value >= 1 && value <= 12) {
                                  return Text(
                                    months[value.toInt() - 1],
                                    style: const TextStyle(fontSize: 12.0),
                                  );
                                } else {
                                  return const Text('');
                                }
                              }
                            },
                          ),
                        ),
                      ),
                      gridData: FlGridData(show: true), // Show grid lines
                      borderData: FlBorderData(
                        show: true,
                        border: const Border(
                          left: BorderSide(color: Colors.black, width: 1),
                          bottom: BorderSide(color: Colors.black, width: 1),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16.0),

            // Filter Section for Reports List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter:',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButton<String>(
                  value: selectedFilter,
                  items: <String>['All', 'Pending', 'Under Investigation', 'Case Closed'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedFilter = newValue!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Report List Section
            const Text(
              'Report List',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: StreamBuilder<List<ReportData>>(
                stream: _databaseService.reports,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No reports available.'));
                  }

                  // Filter reports based on the selected filter
                  final reports = snapshot.data!.where((report) {
                    if (selectedFilter == 'All') return true;
                    return report.status == selectedFilter;
                  }).toList();

                  return ListView.builder(
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text('Report ID: ${report.id}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Location: ${report.location}'),
                              Text('Status: ${report.status}'),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              // Navigate to detailed report view
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReportDetail(report: report),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            child: const Text(
                              'View',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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