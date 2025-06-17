import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sundial/models/daily_solar_data.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DailySolarDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  
  Future<void> addDailySolarData(DailySolarData dailySolarData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      dailySolarData = DailySolarData(
        id: dailySolarData.id,
        date: dailySolarData.date,
        latitude: dailySolarData.latitude,
        longitude: dailySolarData.longitude,
        locationName: dailySolarData.locationName,
        userId: user.uid,
        sunrise: dailySolarData.sunrise,
        sunset: dailySolarData.sunset,
        solarNoon: dailySolarData.solarNoon,
        astronomicalTwilightBegin: dailySolarData.astronomicalTwilightBegin,
        astronomicalTwilightEnd: dailySolarData.astronomicalTwilightEnd,
        nauticalTwilightBegin: dailySolarData.nauticalTwilightBegin,
        nauticalTwilightEnd: dailySolarData.nauticalTwilightEnd,
      );
      final existingData = await getDailySolarDataForDate(dailySolarData.date, user.uid);

      if (existingData != null) {
        dailySolarData.id = existingData.id;
        await updateDailySolarData(dailySolarData);
      } else {
        await _firestore.collection('dailySolarData').add(dailySolarData.toFirestore());
      }
    }
  }

  Future<DailySolarData?> getDailySolarDataForDate(DateTime date, String userId) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final querySnapshot = await _firestore
        .collection('dailySolarData')
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .where('userId', isEqualTo: userId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return DailySolarData.fromFirestore(querySnapshot.docs.first);
    }
    return null;
  }

  Stream<List<DailySolarData>> getDailySolarDataStream(DateTime startDate, DateTime endDate) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return _firestore
          .collection('dailySolarData')
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThanOrEqualTo: endDate)
          .where('userId', isEqualTo: user.uid)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => DailySolarData.fromFirestore(doc)).toList());
    } else {
      return Stream.value([]);
    }
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
