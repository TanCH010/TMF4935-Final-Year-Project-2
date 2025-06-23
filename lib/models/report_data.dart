class ReportData {

  final String id;
  final String emailOrContactNo;
  final String picture;
  final String location;
  final DateTime date;
  final String description;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReportData ({ 
    required this.id,
    required this.emailOrContactNo,
    required this.picture,
    required this.location,
    required this.date,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

}