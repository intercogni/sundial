import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sundial/models/daily_solar_data.dart';

class DailySolarDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add daily solar data
  Future<void> addDailySolarData(DailySolarData dailySolarData) async {
    await _firestore.collection('dailySolarData').add(dailySolarData.toFirestore());
  }

  // Fetch daily solar data for a specific date
  Future<DailySolarData?> getDailySolarDataForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final querySnapshot = await _firestore
        .collection('dailySolarData')
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return DailySolarData.fromFirestore(querySnapshot.docs.first);
    }
    return null;
  }

  // Fetch daily solar data for a date range
  Stream<List<DailySolarData>> getDailySolarDataStream(DateTime startDate, DateTime endDate) {
    return _firestore
        .collection('dailySolarData')
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThanOrEqualTo: endDate)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => DailySolarData.fromFirestore(doc)).toList());
  }

  // Update daily solar data
  Future<void> updateDailySolarData(DailySolarData dailySolarData) async {
    if (dailySolarData.id == null) {
      throw Exception("Cannot update daily solar data without an ID");
    }
    await _firestore.collection('dailySolarData').doc(dailySolarData.id).update(dailySolarData.toFirestore());
  }

  // Delete daily solar data
  Future<void> deleteDailySolarData(String id) async {
    await _firestore.collection('dailySolarData').doc(id).delete();
  }
}
