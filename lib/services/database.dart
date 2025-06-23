import 'package:e_vandalism/models/report_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class DatabaseService {

  final String id;
  DatabaseService( {required this.id});
  //collection reference
  final CollectionReference reportCollection = FirebaseFirestore.instance.collection('ReportData');

  final DocumentReference counterDoc = FirebaseFirestore.instance.collection('Counters').doc('reportCounter');

  Future<int> getAndIncrementReportID() async {
    try {
      final snapshot = await counterDoc.get();

      if (snapshot.exists) {
        // increment the counter atomically
        await counterDoc.update({
          'currentId': FieldValue.increment(1),
        });

        // return the incremented value
        return snapshot.get('currentId') + 1;
      } else {
        // if the counter document does not exist, create it with an initial value
        await counterDoc.set({'currentId': 1});
        return 1;
      }
    } catch (e) {
        throw Exception('Failed to get and increment ReportID: $e');
    }
  }
  

  // add a new report
  Future addReport(ReportData report) async {
    try {
      await reportCollection.doc(report.id).set({
        'reportId': report.id,
        'emailOrContactNo': report.emailOrContactNo,
        'picture': report.picture,
        'location': report.location,
        'date': report.date,
        'description': report.description,
        'status': report.status,
        'createdAt': report.createdAt.toIso8601String(),
        'updatedAt': report.updatedAt.toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to add report: $e');
    }
  }

  // Report list from snapshot
List<ReportData> _reportListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map<ReportData>((doc) {
      return ReportData(
          id: doc.id,
          emailOrContactNo: doc.get('emailOrContactNo') ?? "",
          picture: doc.get('picture') ?? "",
          location: doc.get('location') ?? "",
          date: (doc.get('date') as Timestamp).toDate(),
          description: doc.get('description') ?? "",
          status: doc.get('status') ?? "",
          createdAt: DateTime.parse(doc.get('createdAt') ?? DateTime.now().toIso8601String()),
          updatedAt: DateTime.parse(doc.get('updatedAt') ?? DateTime.now().toIso8601String()),
          );
    }).toList();
  }



  // get reports stream
  Stream<List<ReportData>> get reports {
    return reportCollection.snapshots().map(_reportListFromSnapshot);
  }


}