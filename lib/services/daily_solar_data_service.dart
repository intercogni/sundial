import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sundial/models/daily_solar_data.dart';

class DailySolarDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  
  Future<void> addDailySolarData(DailySolarData dailySolarData) async {
    final existingData = await getDailySolarDataForDate(dailySolarData.date);

    if (existingData != null) {
      
      dailySolarData.id = existingData.id; 
      await updateDailySolarData(dailySolarData);
    } else {
      
      await _firestore.collection('dailySolarData').add(dailySolarData.toFirestore());
    }
  }

  
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

  
  Stream<List<DailySolarData>> getDailySolarDataStream(DateTime startDate, DateTime endDate) {
    return _firestore
        .collection('dailySolarData')
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThanOrEqualTo: endDate)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => DailySolarData.fromFirestore(doc)).toList());
  }

  
  Future<void> updateDailySolarData(DailySolarData dailySolarData) async {
    if (dailySolarData.id == null) {
      throw Exception("Cannot update daily solar data without an ID");
    }
    await _firestore.collection('dailySolarData').doc(dailySolarData.id).update(dailySolarData.toFirestore());
  }

  
  Future<void> deleteDailySolarData(String id) async {
    await _firestore.collection('dailySolarData').doc(id).delete();
  }

  
  Future<void> deleteAllDailySolarData() async {
    final querySnapshot = await _firestore.collection('dailySolarData').get();
    for (final doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }
}
