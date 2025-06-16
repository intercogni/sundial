import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sundial/models/daily_solar_data.dart';

class DailySolarDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add or update daily solar data
  Future<void> addDailySolarData(DailySolarData dailySolarData) async {
    final existingData = await getDailySolarDataForDate(dailySolarData.date);

    if (existingData != null) {
      // Data for this date already exists, update it
      dailySolarData.id = existingData.id; // Set the ID for the update
      await updateDailySolarData(dailySolarData);
    } else {
      // Data for this date does not exist, add new data
      await _firestore.collection('dailySolarData').add(dailySolarData.toFirestore());
    }
  }

  // Fetch daily solar data for a specific date
  Future<DailySolarData?> getDailySolarDataForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final querySnapshot = await _firestore
        .collection('dailySolarData')
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
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

  // Delete all daily solar data
  Future<void> deleteAllDailySolarData() async {
    final querySnapshot = await _firestore.collection('dailySolarData').get();
    for (final doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }
}
